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
  AuthRepoImpl(this.apiService, this._currentUser, this.userRepository);
  //Login method

  @override
  Future<Either<Failure, UserModel?>> login(
    String email,
    String password,
  ) async {
    final result = await apiService.login({
      'email': email,
      'password': password,
    });

    return result.fold((failure) => Left(failure), (data) {
      final responseData = data as Map<String, dynamic>;
      if (responseData['code'] == 200 && responseData['data'] != null) {
        final user = UserModel.fromJson(responseData['data']);
        if (user.token != null) {
          SecureStorageService.saveToken(user.token!);
        }
        _currentUser = user;
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
      final userResult = await userRepository?.getUser();
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
  UserModel? get currentUser => _currentUser;
  //get isLoggedIn
  bool get isLoggedIn => _currentUser != null;
}
