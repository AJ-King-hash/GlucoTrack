import 'package:glucotrack/core/utils/either.dart';
import 'package:glucotrack/core/errors/failure.dart';
import 'package:glucotrack/core/api/api_service.dart';
import 'package:glucotrack/core/utils/source_storage_service.dart';
import 'package:glucotrack/features/auth/data/models/user_model.dart';
import 'package:glucotrack/features/user/repo/user_repo.dart';

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
      if (responseData['user'] != null) {
        final user = UserModel.fromJson(responseData['user']);
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
  Future<Either<Failure, UserModel?>> getUser(int userId) async {
    final token = await SecureStorageService.getToken();
    if (token == null) return const Right(null);

    final result = await apiService.getUserById(userId);

    return result.fold((failure) => Left(failure), (data) {
      final user = UserModel.fromJson(data['user']);
      return Right(user);
    });
  }

  //function for update user data
  @override
  Future<Either<Failure, UserModel?>> updateUser(
    String? name,
    String? email,
    String? gender,
    String? glucoTime,
    String? medicineTime,
    String? password, {
    String? oldPassword,
  }) async {
    final Map<String, dynamic> data = {};

    if (name != null) {
      data['name'] = name;
    }

    if (email != null) {
      data['email'] = email;
    }

    if (gender != null) {
      data['gender'] = gender;
    }

    if (oldPassword != null) {
      data["old_password"] = oldPassword;
    }

    if (glucoTime != null) {
      data['gluco_time'] = glucoTime;
    }

    if (medicineTime != null) {
      data['medicine_time'] = medicineTime;
    }

    if (password != null) {
      data['password'] = password;
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
