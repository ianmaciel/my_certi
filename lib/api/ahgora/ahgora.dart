/*
 * Copyright (c) 2020 Ian Koerich Maciel
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart' as dom;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_certi/api/ahgora/ahgora_day.dart';
import 'package:my_certi/api/ahgora/ahgora_exceptions.dart';
import 'package:my_certi/api/session.dart';

class Ahgora {
  static const _ahgoraAddress = 'https://www.ahgora.com.br';
  int userId;
  String password;
  String companyId;
  String jwt;

  String get _loginAddress => '$_ahgoraAddress/externo/login';
  String get _timestampsAddress => '$_ahgoraAddress/externo/batidas';
  bool get isLoggedIn => session != null;

  @visibleForTesting
  Session session;

  Future<bool> login(
      {@required String companyId,
      @required int userId,
      @required String password}) async {
    this.userId = userId;
    this.password = password;
    this.companyId = companyId;

    // Save login session.
    session = Session();

    http.Response response = await session.post(_loginAddress,
        "empresa=$companyId&origin=portal&matricula=$userId&senha=$password");

    if (response.body.isNotEmpty) {
      Map<String, dynamic> body = json.decode(response.body);
      if (body['r'] == 'success') {
        jwt = body['jwt'];
        return true;
      }
    }
    return false;
  }

  ///
  /// Ahgora has a report page where user see the "fiscal month" instead of the
  /// month of a timestamp day - it means that when you open a report from
  /// february/2020 you will get a few timestamps from january (the last days,
  /// where the fiscal month of january ends and start february), and the
  /// timestamps will end before the end of the month.
  ///
  /// If you clocked-in on 31/jan/2020, you will probably find this timestamp
  /// on february report.
  /// If you clocked-in on 26/feb/2020, you will probably find this timestamp
  /// on march report.
  ///
  /// To avoid misleading the users, this API will try allow two ways to fetch
  /// data:
  /// 1) The default way [fiscalMonth = false] will try it by fetching the two
  ///    subsequents months (the current and the next one) and show reports in a
  ///    way that users can easily find the desired timestamp.
  /// 2) The optional way [fiscalMonth = true] will allow to calculate the hour
  ///    balance correctly using the values from fiscal month.
  ///
  Future<List<AhgoraDay>> fetchTimestamps(DateTime dateTime,
      {bool fiscalMonth = false}) async {
    if (session == null || jwt == null) {
      throw InexistentSession();
    }

    final DateFormat dateFormat = DateFormat("MM-yyyy");

    List<AhgoraDay> ahgoraDays =
        await _fetchMonthlyReport(dateFormat.format(dateTime), dateTime.year);

    if (!fiscalMonth) {
      // When not fetchin for fiscal reasons, make a second request to the next
      // month. Remove all results that are actually on the next month and add
      // all to our existing list.
      DateTime nextMonth = DateTime(dateTime.year, dateTime.month + 1, 1);

      List<AhgoraDay> nextMonthAhgoraDays = await _fetchMonthlyReport(
          dateFormat.format(nextMonth), nextMonth.year);

      nextMonthAhgoraDays.removeWhere(
          (AhgoraDay day) => day.timestamps.first.month != dateTime.month);
      ahgoraDays.addAll(nextMonthAhgoraDays);
    }

    // Remove days without timestamps (most likely non business days).
    ahgoraDays.removeWhere((AhgoraDay element) => element == null);
    return ahgoraDays;
  }

  Future<List<AhgoraDay>> _fetchMonthlyReport(String monthUrl, int year) async {
    final http.Response response =
        await session.get('$_timestampsAddress/$monthUrl');

    if (response.body.isNotEmpty) {
      dom.Document document = parse(response.body);

      // The Ahgora timestamp page has two tables with this class name. The
      // first is de summary, the second is the daily log.
      List<dom.Element> elements = document.getElementsByClassName(
          'table table-bordered table-striped table-batidas');

      // Check if the table was found.
      if (elements.length < 2) {
        print(
            "MY_CERTI: Coudn't parse ahgora page. Reason: table-batidas not found.");
        return null;
      }

      // On second table, select the last element (tbody).
      dom.Element tbody = elements.last.children.last;
      List<AhgoraDay> ahgoraDays = tbody.children
          .map((dom.Element row) => _mapTimestampTableRow(row, year))
          .toList();

      return ahgoraDays;
    } else {
      return null;
    }
  }

  AhgoraDay _mapTimestampTableRow(dom.Element row, int year) {
    final String dayAndMonth = '${row.children.elementAt(0).text.trim()}';
    AhgoraDay ahgoraDay = AhgoraDay();

    // Breake the timestamp list using comma as divider.
    List<String> textTimestamps =
        row.children.elementAt(2).text.trim().split(',');

    if (textTimestamps.first.isNotEmpty) {
      ahgoraDay.addAllTimestamps(textTimestamps
          .map((String textTimestamp) =>
              _parseTimestamp(dayAndMonth, textTimestamp.trim(), year))
          .toList());
      return ahgoraDay;
    }
    return null;
  }

  ///
  /// Parse dd/MM in a datetime.
  ///
  DateTime _parseTimestamp(String dayAndMonth, String textTimestamp, int year) {
    // Dateformat how Ahgora list the date.
    DateFormat dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    /// Append day, month and year to create the full datetime.
    DateTime timestamp = dateFormat.parse('$dayAndMonth/$year $textTimestamp');
    return timestamp;
  }
}
