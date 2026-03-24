import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glucotrack/core/api/api_error.dart';
import 'package:glucotrack/features/auth/presentaion/manager/auth_state.dart';
import 'package:glucotrack/features/auth/repo/auth_repo.dart';
import 'package:glucotrack/core/utils/pref_helper.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository authRepository;
  AuthCubit(this.authRepository) : super(AuthInitial());

  Future<void> login({required String email, required String password}) async {
    emit(AuthLoading());
    try {
      final result = await authRepository.login(email, password);
      result.fold((failure) => emit(AuthError(failure.message)), (user) {
        if (user != null) {
          // Save user ID to secure storage
          if (user.id != null) {
            PrefHelper.saveUserId(user.id.toString());
          }
          emit(AuthSuccess("Login successful"));
        } else {
          emit(AuthError("Invalid credentials"));
        }
      });
    } catch (e) {
      String errMsg = "Error in Login";
      if (e is ApiError) {
        errMsg = e.message;
      }
      emit(AuthError(errMsg));
    }
  }

  Future<void> logout() async {
    emit(AuthLoading());
    try {
      final result = await authRepository.logout();
      result.fold((failure) => emit(AuthError(failure.message)), (_) {
        PrefHelper.clearToken();
        PrefHelper.clearUserId();
        emit(AuthInitial()); // Reset to initial state after logout
      });
    } catch (e) {
      String errMsg = "Error in Logout";
      if (e is ApiError) {
        errMsg = e.message;
      }
      emit(AuthError(errMsg));
    }
  }

  Future<void> verifyOtp(String email, String otp) async {
    emit(AuthLoading());
    try {
      final result = await authRepository.verifyOtp(email, otp);
      result.fold(
        (failure) => emit(AuthError(failure.message)),
        (_) => emit(AuthSuccess("OTP verified successfully")),
      );
    } catch (e) {
      String errMsg = "Error in OTP verification";
      if (e is ApiError) {
        errMsg = e.message;
      }
      emit(AuthError(errMsg));
    }
  }
}
