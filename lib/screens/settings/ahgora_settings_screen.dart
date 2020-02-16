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

import 'package:ahgora_api/ahgora_api.dart';
import 'package:flutter/material.dart';
import 'package:my_certi/api/app_settings.dart';

class AhgoraSettingsScreen extends StatefulWidget {
  @override
  _AhgoraSettingsStateScreen createState() => _AhgoraSettingsStateScreen();
}

class _AhgoraSettingsStateScreen extends State<AhgoraSettingsScreen> {
  bool _savePassword = false;
  bool _keepSession = true;
  bool connected = _settings.isConnectedToAhgora;

  static AppSettings _settings = AppSettings();

  // Text controller used to clear the email typed.
  final TextEditingController _userIDController =
      TextEditingController(text: '${_settings.ahgoraUserId}');
  final TextEditingController _passwordController =
      TextEditingController(text: _settings.ahgoraPassword);
  final TextEditingController _companyController =
      TextEditingController(text: 'a128879');

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('Ahgora Account'),
        ),
        body: ListView(
          children: <Widget>[
            TextField(
              controller: _companyController,
              decoration: InputDecoration(
                labelText: 'Company ID',
              ),
            ),
            SizedBox(height: 12.0),
            TextField(
              controller: _userIDController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'User ID',
              ),
            ),
            SizedBox(height: 12.0),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
              ),
              obscureText: true,
            ),
            SizedBox(height: 12.0),
            ListTile(
              subtitle: Row(
                children: <Widget>[
                  Text('Save password'),
                  Switch.adaptive(
                    value: _savePassword,
                    onChanged: _onChangeSavePassword,
                  ),
                ],
              ),
            ),
            ListTile(
              subtitle: Row(
                children: <Widget>[
                  Text('Keep session'),
                  Switch.adaptive(
                    value: _keepSession,
                    onChanged: _onChangeKeepSession,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                alignment: Alignment.bottomCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    RaisedButton(
                      child: Text(connected ? 'Connected!' : 'Connect'),
                      onPressed: _connect,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );

  void _onChangeSavePassword(bool save) {
    setState(() {
      _savePassword = save;
    });
  }

  void _onChangeKeepSession(bool keep) {
    setState(() {
      _keepSession = keep;
    });
  }

  void _connect() async {
    Ahgora ahgora = Ahgora();
    bool result = await ahgora.login(_companyController.text,
        int.parse(_userIDController.text), _passwordController.text);

    if (result) {
      _settings.ahgoraJwt = ahgora.jwt;
      _settings.ahgoraJwtExpiration = ahgora.expirationDate;
    } else {
      // Find the Scaffold in the widget tree and use it to show a SnackBar.
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text("Couldn't login. Double check info."),
      ));
      return;
    }
    if (_keepSession) {
      _settings.saveAhgoraJwt(ahgora.jwt);
      _settings.saveAhgoraJwtExpiration(ahgora.expirationDate);
    }
    if (_savePassword) {
      _settings.saveAhgoraCompanyId(_companyController.text);
      _settings.saveAhgoraUserId(int.parse(_userIDController.text));
      _settings.saveAhgoraPassword(_passwordController.text);
    }
  }
}
