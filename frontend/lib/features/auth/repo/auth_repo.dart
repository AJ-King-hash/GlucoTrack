import 'package:glucotrack/core/utils/either.dart';
import 'package:glucotrack/core/errors/failure.dart';
import 'package:glucotrack/features/auth/data/models/user_model.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserModel?>> login(String email, String password);
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, void>> verifyOtp(String email, String otp);
  Future<Either<Failure, UserModel?>> autoLogin();

  UserModel? get currentUser;
  bool get isLoggedIn;
}
