import 'source_storage_service.dart';

/// Token management wrapper that delegates to SecureStorageService.
///
/// This class provides a consistent interface for token storage operations
/// while using FlutterSecureStorage for secure token persistence.
/// All token operations are delegated to [SecureStorageService] to ensure
/// consistent secure storage across the application.
class PrefHelper {
  /// Saves the authentication token securely.
  ///
  /// Delegates to [SecureStorageService.saveToken] for secure storage.
  static Future<void> saveToken(String token) async {
    await SecureStorageService.saveToken(token);
  }

  /// Retrieves the stored authentication token.
  ///
  /// Delegates to [SecureStorageService.getToken] for secure retrieval.
  /// Returns null if no token is stored.
  static Future<String?> getToken() async {
    return await SecureStorageService.getToken();
  }

  /// Clears the stored authentication token.
  ///
  /// Delegates to [SecureStorageService.deleteToken] for secure deletion.
  static Future<void> clearToken() async {
    await SecureStorageService.deleteToken();
  }

  /// Saves the user ID securely.
  ///
  /// Delegates to [SecureStorageService.saveUserId] for secure storage.
  static Future<void> saveUserId(String userId) async {
    await SecureStorageService.saveUserId(userId);
  }

  /// Retrieves the stored user ID.
  ///
  /// Delegates to [SecureStorageService.getUserId] for secure retrieval.
  /// Returns null if no user ID is stored.
  static Future<String?> getUserId() async {
    return await SecureStorageService.getUserId();
  }

  /// Clears the stored user ID.
  ///
  /// Delegates to [SecureStorageService.deleteUserId] for secure deletion.
  static Future<void> clearUserId() async {
    await SecureStorageService.deleteUserId();
  }

  /// Clears all user-related data from secure storage.
  ///
  /// Delegates to [SecureStorageService.clearAll] to delete both the token and user ID.
  static Future<void> clearAll() async {
    await SecureStorageService.clearAll();
  }
}
