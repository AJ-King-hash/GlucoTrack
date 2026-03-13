import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:untitled10/core/api/api_error.dart';
import 'package:untitled10/features/auth/data/models/user_model.dart';
import 'package:untitled10/features/auth/repo/auth_repo.dart';
import 'package:untitled10/features/user/presentation/manager/user_state.dart';
import 'package:untitled10/features/user/repo/user_repo.dart';

class UserCubit extends Cubit<UserState> {
  final UserRepository userRepository;
  final AuthRepository authRepository;
  UserCubit(this.userRepository, this.authRepository) : super(UserInitial());

  /// Set user data directly (e.g., from login response) without API call
  void setUser(UserModel user) {
    emit(UserLoaded(user));
  }

  //function for create user
  Future<void> createUser({
    required String name,
    required String email,
    required String password,
  }) async {
    emit(UserLoading());
    try {
      final result = await userRepository.createUser(name, email, password);
      result.fold((failure) => emit(UserError(failure.message)), (user) {
        if (user != null) {
          emit(UserSuccess("Register successful"));
        } else {
          emit(UserError("User creation failed"));
        }
      });
    } catch (e) {
      String errMsg = "Error in Register";
      if (e is ApiError) {
        errMsg = e.message;
      }
      emit(UserError(errMsg));
    }
  }

  //function for get user data
  Future<void> getUser() async {
    emit(UserLoading());
    try {
      // Get current user ID from auth repository
      final currentUser = authRepository.currentUser;
      if (currentUser == null || currentUser.id == null) {
        emit(UserError("User not authenticated"));
        return;
      }

      final result = await userRepository.getUser(currentUser.id!);
      result.fold((failure) => emit(UserError(failure.message)), (user) {
        if (user != null) {
          emit(UserLoaded(user));
        } else {
          emit(UserError("User not found"));
        }
      });
    } catch (e) {
      String errMsg = "Error in Profile";
      if (e is ApiError) {
        errMsg = e.message;
      }
      emit(UserError(errMsg));
    }
  }

  //function for update user data
  Future<void> updateUser({
    required String name,
    required String email,
    required String password,
    String? oldPassword,
  }) async {
    emit(UserLoading());
    try {
      final result = await userRepository.updateUser(
        name,
        email,
        password,
        oldPassword: oldPassword,
      );
      result.fold((failure) => emit(UserError(failure.message)), (user) {
        if (user != null) {
          emit(UserLoaded(user));
        } else {
          emit(UserError("Failed to update profile"));
        }
      });
    } catch (e) {
      String errorMsg = "Error in Update Profile";
      if (e is ApiError) {
        errorMsg = e.message;
      }
      emit(UserError(errorMsg));
    }
  }
}
