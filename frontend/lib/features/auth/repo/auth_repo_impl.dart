import 'package:untitled10/core/utils/either.dart';
import 'package:untitled10/core/errors/failure.dart';
import 'package:untitled10/core/api/api_service.dart';
import 'package:untitled10/core/utils/source_storage_service.dart';
import 'package:untitled10/features/auth/data/models/user_model.dart';
import 'package:untitled10/features/auth/repo/auth_repo.dart';
import 'package:untitled10/features/user/repo/user_repo.dart';

class AuthRepoImpl extends AuthRepository {
  final ApiService apiService;
  UserModel? _currentUser;
  final UserRepository? userRepository;

  AuthRepoImpl(this.apiService, this.userRepository);
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
      _currentUser = null;
      return const Right(null);
    });
  }

  @override
  Future<Either<Failure, void>> verifyOtp(String email, String otp) async {
    final result = await apiService.verifyOtp({'email': email, 'otp': otp});

    return result.fold((failure) => Left(failure), (_) => const Right(null));
  }

  //function for auto login
  Future<Either<Failure, UserModel?>> autoLogin() async {
    final token = await SecureStorageService.getToken();
    if (token == null) {
      _currentUser = null;
      return const Right(null);
    }
    try {
      final userResult = await userRepository?.getUser(
        0,
      ); // TODO: Pass actual userId when available
      return userResult?.fold((failure) => Left(failure), (user) {
            _currentUser = user;
            return Right(user);
          }) ??
          const Right(null);
    } catch (_) {
      await SecureStorageService.deleteToken();
      _currentUser = null;
      return const Right(null);
    }
  }

  //get currentUser;
  @override
  UserModel? get currentUser => _currentUser;
  //get isLoggedIn
  @override
  bool get isLoggedIn => _currentUser != null;
}
