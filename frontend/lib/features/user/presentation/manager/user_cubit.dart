import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:glucotrack/core/api/api_error.dart';
import 'package:glucotrack/core/utils/global_refresher.dart';
import 'package:glucotrack/core/utils/toast_utility.dart';
import 'package:glucotrack/features/auth/data/models/user_model.dart';
import 'package:glucotrack/features/auth/repo/auth_repo.dart';
import 'package:glucotrack/features/user/presentation/manager/user_state.dart';
import 'package:glucotrack/features/user/repo/user_repo.dart';

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
      result.fold(
        (failure) {
          ToastUtility.showError(failure.message);
          emit(UserError(failure.message));
        },
        (user) {
          if (user != null) {
            emit(UserSuccess("Register successful"));
          } else {
            emit(UserError("User creation failed"));
          }
        },
      );
    } catch (e) {
      String errMsg = "Error in Register";
      if (e is ApiError) {
        errMsg = e.message;
      }
      ToastUtility.showError(errMsg);
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
    String? name,
    String? email,
    String? gender,
    String? glucoTime,
    String? medicineTime,
    String? password,
    String? oldPassword,
  }) async {
    print("object");

    emit(UserLoading());
    try {
      final result = await userRepository.updateUser(
        name,
        email,
        gender,
        glucoTime,
        medicineTime,
        password,
        oldPassword: oldPassword,
      );
      result.fold(
        (failure) {
          ToastUtility.showError(failure.message);
          emit(UserError(failure.message));
        },
        (user) {
          if (user != null) {
            // Profile updated successfully - emit only UserLoaded to avoid double rebuild
            ToastUtility.showSuccess("Profile updated successfully");
            emit(UserLoaded(user));

            GetIt.I<GlobalRefresher>().triggerGlobalRefresh();
          } else {
            ToastUtility.showError("Failed to update profile");
            emit(UserError("Failed to update profile"));
            GetIt.I<GlobalRefresher>().triggerGlobalRefresh();
          }
        },
      );
    } catch (e) {
      String errorMsg = "Error in Update Profile";
      if (e is ApiError) {
        errorMsg = e.message;
      }
      ToastUtility.showError(errorMsg);
      emit(UserError(errorMsg));
    }
  }
}
