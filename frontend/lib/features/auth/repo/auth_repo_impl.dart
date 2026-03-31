import 'dart:convert';

import 'package:glucotrack/core/services/notification_service.dart';
import 'package:glucotrack/core/utils/either.dart';
import 'package:glucotrack/core/errors/failure.dart';
import 'package:glucotrack/core/api/api_service.dart';
import 'package:glucotrack/core/utils/source_storage_service.dart';
import 'package:glucotrack/features/auth/data/models/user_model.dart';
import 'package:glucotrack/features/auth/repo/auth_repo.dart';
import 'package:glucotrack/features/user/repo/user_repo.dart';

class AuthRepoImpl extends AuthRepository {
  final ApiService apiService;
  UserModel? _currentUser;
  final UserRepository? userRepository;
  final NotificationService _notificationService;

  AuthRepoImpl(this.apiService, this.userRepository, this._notificationService);
  //Login method

  @override
  Future<Either<Failure, UserModel?>> login(
    String email,
    String password,
  ) async {
    final result = await apiService.login({
      'username': email,
      'password': password,
    });

    return await result.fold((failure) async => Left(failure), (data) async {
      final responseData = data as Map<String, dynamic>;
      if (responseData['user'] != null &&
          responseData['access_token'] != null) {
        // Create UserModel from the response data
        final userData = responseData['user'] as Map<String, dynamic>;

        // Combine user and token data - backend returns access_token at top level
        final combinedData = {
          ...userData,
          'token': responseData['access_token'],
        };

        final user = UserModel.fromJson(combinedData);
        if (user.token != null) {
          final tokenSaved = await SecureStorageService.saveToken(user.token!);
          if (!tokenSaved) {
            return Left(ServerFailure(message: 'Failed to save token'));
          }
        } else {
          return Left(ServerFailure(message: 'No token received'));
        }
        _currentUser = user;
        // Set isFirstTime to false after successful login
        await SecureStorageService.saveIsFirstTime(false);
        // Save user data to secure storage for offline access
        await _saveUserData(user);

        await _notificationService.registerFcmTokenAfterLogin();
        return Right(user);
      }
      return Left(
        ServerFailure(message: responseData['message'] ?? 'Login failed'),
      );
    });
  }

  //logout methods
  @override
  Future<Either<Failure, void>> logout() async {
    final result = await apiService.logout();

    return result.fold((failure) => Left(failure), (_) {
      SecureStorageService.deleteToken();
      SecureStorageService.deleteUserData();
      _currentUser = null;
      return const Right(null);
    });
  }

  @override
  Future<Either<Failure, void>> verifyOtp(String email, String otp) async {
    final result = await apiService.verifyOtp({'email': email, 'otp': otp});

    return result.fold((failure) => Left(failure), (_) => const Right(null));
  }

  @override
  Future<Either<Failure, void>> forgotPassword(String email) async {
    final result = await apiService.forgotPassword({'email': email});
    return result.fold((failure) => Left(failure), (_) => const Right(null));
  }

  @override
  Future<Either<Failure, void>> resetPassword(String email, String newPassword) async {
    final result = await apiService.resetPassword({'email': email, 'new_password': newPassword});
    return result.fold((failure) => Left(failure), (_) => const Right(null));
  }

  //function for auto login
  @override
  Future<Either<Failure, UserModel?>> autoLogin() async {
    final token = await SecureStorageService.getToken();
    if (token == null) {
      _currentUser = null;
      return const Right(null);
    }

    // First try to load from local storage for faster startup
    final cachedUser = await _loadUserData();
    if (cachedUser != null) {
      _currentUser = cachedUser;

      // Also refresh from API in background (but don't wait for it)
      _refreshUserFromApi();

      return Right(cachedUser);
    }

    // Fallback to API call if no cached data
    try {
      final userResult = await userRepository?.getUser(
        0,
      ); // TODO: Pass actual userId when available
      return userResult?.fold((failure) => Left(failure), (user) {
            if (user != null) {
              _currentUser = user;
              // Save to local storage for future use
              _saveUserData(user);
            }
            return Right(user);
          }) ??
          const Right(null);
    } catch (_) {
      await SecureStorageService.deleteToken();
      _currentUser = null;
      return const Right(null);
    }
  }

  /// Refresh user data from API in background
  Future<void> _refreshUserFromApi() async {
    try {
      final userResult = await userRepository?.getUser(0);
      userResult?.fold((failure) => null, (user) {
        if (user != null) {
          _currentUser = user;
          _saveUserData(user);
        }
      });
    } catch (_) {
      // Silently fail - we already have cached data
    }
  }

  //get currentUser;
  @override
  UserModel? get currentUser => _currentUser;
  //get isLoggedIn
  @override
  bool get isLoggedIn => _currentUser != null;

  /// Update the current user data (used for local cache sync after profile updates)
  void updateCurrentUser(UserModel user) {
    _currentUser = user;
    // Also persist to secure storage
    _saveUserData(user);
  }

  /// Save user data to secure storage
  Future<void> _saveUserData(UserModel user) async {
    try {
      final userJson = json.encode({
        'name': user.name,
        'email': user.email,
        'gender': user.gender,
        'glucoTime': user.glucoTime,
        'medicineTime': user.medicineTime,
        'sugarReminder': user.sugarReminder,
        'medicineReminder': user.medicineReminder,
        'timezone': user.timezone,
      });
      await SecureStorageService.saveUserData(userJson);
    } catch (e) {
      // Silently fail - user data persistence is optional
    }
  }

  /// Load user data from secure storage
  Future<UserModel?> _loadUserData() async {
    try {
      final userDataJson = await SecureStorageService.getUserData();
      if (userDataJson != null) {
        final userMap = json.decode(userDataJson) as Map<String, dynamic>;
        return UserModel.fromJson(userMap);
      }
    } catch (e) {
      // Silently fail - will fallback to API call
    }
    return null;
  }
}
