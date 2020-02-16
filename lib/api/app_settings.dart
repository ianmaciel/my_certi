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

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AppSettings {
  Map<String, String> _allValues;
  final storage = new FlutterSecureStorage();

  /// Read-only status - indicate when all the keys are loaded.
  static bool _ready = false;
  static bool get ready => _ready;

  // List of listeners to notify when ready.
  static List<Function> initListeners = List<Function>();

  // Allow only one instance of AppSettings.
  // Singleton
  static final AppSettings _singleton = AppSettings._internal();
  factory AppSettings({Function listener}) {
    // Add to the listeners list if this is not ready yet.
    // If already ready, then notify.
    if (listener != null) {
      if (ready) {
        listener();
      } else {
        initListeners.add(listener);
      }
    }
    return _singleton;
  }
  AppSettings._internal() {
    // Read all values
    storage.readAll().then(_readAllCompleted);
  }

  _readAllCompleted(Map<String, String> values) {
    _allValues = values ?? Map<String, String>();
    _ready = true;

    // Notifiy all listeners and cleanup the list.
    initListeners.forEach((Function listener) => listener());
    initListeners = List<Function>();
  }

  String _readKey(String key) {
    if (!_ready) {
      print('MyCERTI: ERROR: AppSettings() can not read key before read all');
      return null;
    }

    if (_allValues.containsKey(key)) {
      return _allValues[key];
    }
    return null;
  }

  // Setter/getters for ahgora authentication.
  String get ahgoraCompany => _readKey(_StoreKeys.ahgoraCompany);
  set ahgoraCompany(String value) =>
      _allValues[_StoreKeys.ahgoraCompany] = value;
  int get ahgoraUserId => int.parse(_readKey(_StoreKeys.ahgoraUserId));
  set ahgoraUserId(int value) => _allValues[_StoreKeys.ahgoraUserId] = '$value';
  String get ahgoraPassword => _readKey(_StoreKeys.ahgoraPassword);
  set ahgoraPassword(String value) =>
      _allValues[_StoreKeys.ahgoraPassword] = value;
  String get ahgoraJwt => _readKey(_StoreKeys.ahgoraJwt);
  set ahgoraJwt(String value) => _allValues[_StoreKeys.ahgoraJwt] = value;
  DateTime get ahgoraJwtExpiration =>
      DateTime.parse(_readKey(_StoreKeys.ahgoraJwtExpiration));
  set ahgoraJwtExpiration(DateTime value) =>
      _allValues[_StoreKeys.ahgoraJwtExpiration] = value.toString();

  void saveAhgoraCompanyId(String value) async {
    ahgoraCompany = value;
    await storage.write(key: _StoreKeys.ahgoraCompany, value: value);
  }

  void saveAhgoraUserId(int value) async {
    ahgoraUserId = value;
    await storage.write(key: _StoreKeys.ahgoraUserId, value: '$value');
  }

  void saveAhgoraPassword(String value) async {
    ahgoraPassword = value;
    await storage.write(key: _StoreKeys.ahgoraPassword, value: value);
  }

  void saveAhgoraJwt(String value) async {
    ahgoraJwt = value;
    await storage.write(key: _StoreKeys.ahgoraJwt, value: value);
  }

  void saveAhgoraJwtExpiration(DateTime value) async {
    ahgoraJwtExpiration = value;
    await storage.write(
        key: _StoreKeys.ahgoraJwtExpiration, value: value.toString());
  }

  bool get isConnectedToAhgora =>
      ahgoraJwt != null && ahgoraJwtExpiration.isAfter(DateTime.now());
  bool get hasAhgoraCredentials =>
      ahgoraCompany != null && ahgoraUserId != null && ahgoraPassword != null;
}

class _StoreKeys {
  static const String ahgoraJwt = 'ahgoraJwt';
  static const String ahgoraJwtExpiration = 'ahgoraJwtExpiration';
  static const String ahgoraUserId = 'ahgoraUserId';
  static const String ahgoraPassword = 'ahgoraPassword';
  static const String ahgoraCompany = 'ahgoraCompany';
}
