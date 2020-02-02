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

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_certi/api/ahgora/ahgora_exceptions.dart';
import 'package:my_certi/api/session.dart';

class AhgoraDay {
  List<String> timestamps;
}

class Ahgora {
  static const _ahgoraAddress = 'https://www.ahgora.com.br';
  int userId;
  String password;
  String companyId;
  String jwt;

  String get _loginAddress => '$_ahgoraAddress/externo/login';
  String get _timestampsAddress => '$_ahgoraAddress/externo/batidas';
  String getTimestampsAddress(DateTime month) =>
      '$_timestampsAddress/${DateFormat("MM-yyyy").format(month)}';

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
    } else {
      return false;
    }
  }
}
