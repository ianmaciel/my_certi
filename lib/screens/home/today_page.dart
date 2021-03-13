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

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:ahgora_api/ahgora_api.dart';

class TodayPage extends StatelessWidget {
  final MonthlyReport _monthlyReport;
  TodayPage(this._monthlyReport);

  @override
  Widget build(BuildContext context) => Container(
        child: _buildListItems(),
      );

  Widget _buildListItems() {
    if (_monthlyReport.days.length >= 1) {
      return ListView(
          children: _monthlyReport.days.reversed
              .map((Day day) => _AhgoraListTile(day))
              .toList());
    } else {
      return Center(
        child: ListTile(
          title: Text('Nenhuma entrada registrada este mês.'),
        ),
      );
    }
  }
}

class _AhgoraListTile extends StatelessWidget {
  final Day _day;
  _AhgoraListTile(this._day);

  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  final DateFormat _hourFormat = DateFormat('HH:mm');

  @override
  Widget build(BuildContext context) => ListTile(
        title: Text('${_dateFormat.format(_day.reference)}'),
        subtitle: RichText(text: _buildClockTimeList(context)),
      );

  TextSpan _buildClockTimeList(BuildContext context) {
    List<TextSpan> textSpans = _day.clockTimes.map((ClockTime clockTime) {
      TextStyle textStyle = Theme.of(context).textTheme.subtitle1!;

      if (clockTime.type == ClockTimeType.expected) {
        textStyle = textStyle.merge(
          TextStyle(color: Colors.grey),
        );
      }

      return TextSpan(
          text: '${_hourFormat.format(clockTime.time)} ', style: textStyle);
    }).toList();
    return TextSpan(children: textSpans);
  }
}
