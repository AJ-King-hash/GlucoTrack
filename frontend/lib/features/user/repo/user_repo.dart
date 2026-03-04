import 'package:untitled10/core/utils/either.dart';
import 'package:untitled10/core/errors/failure.dart';
import 'package:untitled10/features/auth/data/models/user_model.dart';

abstract class UserRepository {
  Future<Either<Failure, UserModel?>> createUser(
    String name,
    String email,
    String password,
  );
  Future<Either<Failure, UserModel?>> getUser();
  Future<Either<Failure, UserModel?>> updateUser(
    String name,
    String email,
    String password,
  );
}
