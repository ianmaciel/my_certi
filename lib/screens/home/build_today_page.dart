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

import 'package:ahgora_api/ahgora_api.dart';
import 'package:my_certi/api/app_settings.dart';
import 'package:my_certi/screens/home/today_page.dart';

class BuildTodayPage extends StatefulWidget {
  @override
  _BuildTodayPageState createState() => _BuildTodayPageState();
}

class _BuildTodayPageState extends State<BuildTodayPage> {
  Ahgora _ahgora = Ahgora();
  MonthlyReport _monthlyReport;
  AppSettings _settings;

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _settings = AppSettings(listener: initSettingsCallback);
  }

  ///
  /// Called when AppSettings finish loading settings.
  ///
  void initSettingsCallback() {
    _loading = true;
    if (_settings.isConnectedToAhgora) {
      _ahgora.jwt = _settings.ahgoraJwt;
      _updateMonthlyReport();
      return;
    }

    if (_settings.hasAhgoraCredentials) {
      _ahgora
          .login(
            _settings.ahgoraCompany,
            _settings.ahgoraUserId,
            _settings.ahgoraPassword,
          )
          .then(_loginCallback);
    }
  }

  void _loginCallback(bool result) {
    if (result) {
      _updateMonthlyReport();
    } else {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _updateMonthlyReport() async {
    MonthlyReport report =
        await _ahgora.getMonthlyReport(DateTime.now(), fiscalMonth: false);
    setState(() {
      _monthlyReport = report;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) => _loading
      ? Center(child: CircularProgressIndicator())
      : RefreshIndicator(
          child: TodayPage(_monthlyReport),
          onRefresh: _updateMonthlyReport,
        );
}
