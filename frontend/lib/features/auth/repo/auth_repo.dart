import 'package:untitled10/core/utils/either.dart';
import 'package:untitled10/core/errors/failure.dart';
import 'package:untitled10/features/auth/data/models/user_model.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserModel?>> login(String email, String password);
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, void>> verifyOtp(String email, String otp);
  Future<Either<Failure, UserModel?>> autoLogin();

  UserModel? get currentUser;
  bool get isLoggedIn;
}
