// file: secure_storage_service.dart

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  SecureStorageService._();

  static const _storage = FlutterSecureStorage();
  static const _tokenKey = "access_token";
  static const _isFirstTimeKey = "is_first_time";
  static const _userIdKey = "user_id";
  static const _userDataKey = "user_data";

  /// Clears all user-related data from secure storage.
  ///
  /// This method deletes the authentication token and user ID from secure storage,
  /// effectively logging the user out.
  /// Returns true if all data was successfully cleared, false otherwise.
  static Future<bool> clearAll() async {
    try {
      await _storage.delete(key: _tokenKey);
      await _storage.delete(key: _userIdKey);
      return true;
    } catch (e) {
      return false;
    }
  }

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

  static Future<bool> saveUserId(String userId) async {
    try {
      await _storage.write(key: _userIdKey, value: userId);
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<String?> getUserId() async {
    try {
      return await _storage.read(key: _userIdKey);
    } catch (e) {
      return null;
    }
  }

  static Future<bool> deleteUserId() async {
    try {
      await _storage.delete(key: _userIdKey);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Save user data as JSON string
  static Future<bool> saveUserData(String userDataJson) async {
    try {
      await _storage.write(key: _userDataKey, value: userDataJson);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get saved user data as JSON string
  static Future<String?> getUserData() async {
    try {
      return await _storage.read(key: _userDataKey);
    } catch (e) {
      return null;
    }
  }

  /// Delete saved user data
  static Future<bool> deleteUserData() async {
    try {
      await _storage.delete(key: _userDataKey);
      return true;
    } catch (e) {
      return false;
    }
  }
}
