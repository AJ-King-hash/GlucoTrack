import 'package:untitled10/core/utils/either.dart';
import 'package:untitled10/core/errors/failure.dart';
import 'package:untitled10/core/api/api_service.dart';
import 'package:untitled10/core/utils/source_storage_service.dart';
import 'package:untitled10/features/auth/data/models/user_model.dart';
import 'package:untitled10/features/user/repo/user_repo.dart';

class UserRepositoryImpl implements UserRepository {
  final ApiService apiService;
  UserRepositoryImpl(this.apiService);

  //function for create user
  @override
  Future<Either<Failure, UserModel?>> createUser(
    String name,
    String email,
    String password,
  ) async {
    final result = await apiService.createUser({
      'name': name,
      'email': email,
      'password': password,
    });

    return result.fold((failure) => Left(failure), (data) {
      final responseData = data as Map<String, dynamic>;
      if (responseData['data'] != null) {
        final user = UserModel.fromJson(responseData['data']);
        if (user.token != null) {
          SecureStorageService.saveToken(user.token!);
        }
        return Right(user);
      }
      return Left(
        ServerFailure(message: responseData['message'] ?? 'Create user failed'),
      );
    });
  }

  //function for get user data
  @override
  Future<Either<Failure, UserModel?>> getUser() async {
    final token = await SecureStorageService.getToken();
    if (token == null) return const Right(null);

    final result = await apiService.getUser();

    return result.fold((failure) => Left(failure), (data) {
      final user = UserModel.fromJson(data['user']);
      return Right(user);
    });
  }

  //function for update user data
  @override
  Future<Either<Failure, UserModel?>> updateUser(
    String name,
    String email,
    String password, {
    String? oldPassword,
  }) async {
    final data = {"name": name, "email": email, "password": password};
    if (oldPassword != null) {
      data["old_password"] = oldPassword;
    }
    final result = await apiService.updateUser(data);

    return result.fold((failure) => Left(failure), (data) {
      final responseData = data as Map<String, dynamic>;
      if (responseData['user'] != null) {
        final updateUser = UserModel.fromJson(responseData['user']);
        return Right(updateUser);
      }
      return Left(
        ServerFailure(message: responseData['message'] ?? 'Update user failed'),
      );
    });
  }
}
