// file: secure_storage_service.dart

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  SecureStorageService._();

  static const _storage = FlutterSecureStorage();
  static const _tokenKey = "access_token";
  static const _isFirstTimeKey = "is_first_time";

  static Future<bool> saveToken(String token) async {
    try {
      await _storage.write(key: _tokenKey, value: token);
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<String?> getToken() async {
    try {
      return await _storage.read(key: _tokenKey);
    } catch (e) {
      return null;
    }
  }

  static Future<bool> deleteToken() async {
    try {
      await _storage.delete(key: _tokenKey);
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> saveIsFirstTime(bool isFirstTime) async {
    try {
      await _storage.write(key: _isFirstTimeKey, value: isFirstTime.toString());
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> getIsFirstTime() async {
    try {
      final value = await _storage.read(key: _isFirstTimeKey);
      return value == null ? true : value.toLowerCase() != 'false';
    } catch (e) {
      return true;
    }
  }
}
