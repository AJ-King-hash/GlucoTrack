import 'package:glucotrack/core/utils/either.dart';
import 'package:glucotrack/core/errors/failure.dart';
import 'package:glucotrack/features/auth/data/models/user_model.dart';

abstract class UserRepository {
  Future<Either<Failure, UserModel?>> createUser(
    String name,
    String email,
    String password,
  );
  Future<Either<Failure, UserModel?>> getUser(int userId);
  Future<Either<Failure, UserModel?>> updateUser(
    String? name,
    String? email,
    String? gender,
    String? password,
    String? glucoTime,
    String? medicineTime, {
    String? oldPassword,
  });
}
