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
import 'package:flutter/foundation.dart' show kIsWeb;

class _SafeFlutterSecureStorage extends FlutterSecureStorage {
  const _SafeFlutterSecureStorage() : super();

  /// Decrypts and returns all keys with associated values.
  ///
  /// [iOptions] optional iOS options
  /// [aOptions] optional Android options
  /// [lOptions] optional Linux options
  /// Can throw a [PlatformException].
  @override
  Future<Map<String, String>> readAll({
    IOSOptions? iOptions = IOSOptions.defaultOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
  }) async {
    // Secure storage is not available for web yet.
    // Return an empty map.
    if (kIsWeb) {
      return <String, String>{};
    }

    return super.readAll(
      iOptions: iOptions,
      aOptions: aOptions,
      lOptions: lOptions,
    );
  }

  /// Encrypts and saves the [key] with the given [value].
  ///
  /// If the key was already in the storage, its associated value is changed.
  /// If the value is null, deletes associated value for the given [key].
  /// [key] shouldn't be null.
  /// [value] required value
  /// [iOptions] optional iOS options
  /// [aOptions] optional Android options
  /// [lOptions] optional Linux options
  /// Can throw a [PlatformException].
  @override
  Future<void> write({
    required String key,
    required String? value,
    IOSOptions? iOptions = IOSOptions.defaultOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
  }) {
    if (kIsWeb) {
      return Future.value();
    }

    return super.write(
      key: key,
      value: value,
      iOptions: iOptions,
      aOptions: aOptions,
      lOptions: lOptions,
    );
  }
}

class AppSettings {
  Map<String, String?> _allValues = Map<String, String?>();
  final storage = new _SafeFlutterSecureStorage();

  /// Read-only status - indicate when all the keys are loaded.
  static bool _ready = false;
  static bool get ready => _ready;

  // List of listeners to notify when ready.
  static List<Function> initListeners = <Function>[];

  // Allow only one instance of AppSettings.
  // Singleton
  static final AppSettings _singleton = AppSettings._internal();
  factory AppSettings({Function? listener}) {
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
    _allValues = values;
    _ready = true;

    // Notifiy all listeners and cleanup the list.
    initListeners.forEach((Function listener) => listener());
    initListeners = <Function>[];
  }

  String? _readKey(String key) {
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
  String? get ahgoraCompany => _readKey(_StoreKeys.ahgoraCompany);
  set _ahgoraCompany(String value) =>
      _allValues[_StoreKeys.ahgoraCompany] = value;
  void saveAhgoraCompanyId(String value) async {
    _ahgoraCompany = value;
    if (ahgoraSaveCredentials!) {
      await storage.write(key: _StoreKeys.ahgoraCompany, value: value);
    }
  }

  int? get ahgoraUserId =>
      int.tryParse(_readKey(_StoreKeys.ahgoraUserId) ?? '');
  set _ahgoraUserId(int value) =>
      _allValues[_StoreKeys.ahgoraUserId] = '$value';
  void saveAhgoraUserId(int value) async {
    _ahgoraUserId = value;
    if (ahgoraSaveCredentials!) {
      await storage.write(key: _StoreKeys.ahgoraUserId, value: '$value');
    }
  }

  String? get ahgoraPassword => _readKey(_StoreKeys.ahgoraPassword);
  set _ahgoraPassword(String value) =>
      _allValues[_StoreKeys.ahgoraPassword] = value;
  void saveAhgoraPassword(String value) async {
    _ahgoraPassword = value;
    if (ahgoraSaveCredentials!) {
      await storage.write(key: _StoreKeys.ahgoraPassword, value: value);
    }
  }

  String? get ahgoraJwt => _readKey(_StoreKeys.ahgoraJwt);
  set ahgoraJwt(String? value) => _allValues[_StoreKeys.ahgoraJwt] = value;
  void saveAhgoraJwt(String value) async {
    ahgoraJwt = value;
    if (ahgoraKeepSession!) {
      await storage.write(key: _StoreKeys.ahgoraJwt, value: value);
    }
  }

  DateTime get ahgoraJwtExpiration =>
      DateTime.parse(_readKey(_StoreKeys.ahgoraJwtExpiration)!);
  set ahgoraJwtExpiration(DateTime value) =>
      _allValues[_StoreKeys.ahgoraJwtExpiration] = value.toString();
  void saveAhgoraJwtExpiration(DateTime value) async {
    ahgoraJwtExpiration = value;
    await storage.write(
        key: _StoreKeys.ahgoraJwtExpiration, value: value.toString());
  }

  bool? get ahgoraKeepSession =>
      _readKey(_StoreKeys.ahgoraKeepSession) == 'true';
  set _ahgoraKeepSession(bool value) =>
      _allValues[_StoreKeys.ahgoraKeepSession] = value.toString();
  void saveAhgoraKeepSession(bool value) async {
    _ahgoraKeepSession = value;
    await storage.write(
        key: _StoreKeys.ahgoraKeepSession, value: value.toString());
  }

  bool? get ahgoraSaveCredentials =>
      _readKey(_StoreKeys.ahgoraSaveCredentials) == 'true';
  set _ahgoraSaveCredentials(bool value) =>
      _allValues[_StoreKeys.ahgoraSaveCredentials] = value.toString();
  void saveAhgoraSaveCredentials(bool value) async {
    _ahgoraSaveCredentials = value;
    await storage.write(
        key: _StoreKeys.ahgoraSaveCredentials, value: value.toString());
  }

  bool? get ahgoraUseFiscalMonth =>
      _readKey(_StoreKeys.ahgoraUseFiscalMonth) == 'true';
  set _ahgoraUseFiscalMonth(bool value) =>
      _allValues[_StoreKeys.ahgoraUseFiscalMonth] = value.toString();
  void saveAhgoraUseFiscalMonth(bool value) async {
    _ahgoraUseFiscalMonth = value;
    await storage.write(
        key: _StoreKeys.ahgoraUseFiscalMonth, value: value.toString());
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
  static const String ahgoraKeepSession = 'ahgoraKeepSession';
  static const String ahgoraSaveCredentials = 'ahgoraSaveCredentials';
  static const String ahgoraUseFiscalMonth = 'ahgoraUseFiscalMonth';
}
