import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glucotrack/core/api/api_error.dart';
import 'package:glucotrack/features/auth/presentaion/manager/auth_state.dart';
import 'package:glucotrack/features/auth/repo/auth_repo.dart';
import 'package:glucotrack/core/utils/pref_helper.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository authRepository;
  AuthCubit(this.authRepository) : super(AuthInitial());

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

  Future<void> login({required String email, required String password}) async {
    emit(AuthLoading());
    final result = await authRepository.login(email, password);
    result.fold((failure) => emit(AuthError(failure.message)), (user) {
      if (user != null && user.id != null) {
        PrefHelper.saveUserId(user.id.toString());
      }
      // Emit Login specific success
      emit(AuthLoginSuccess("Login successful", user: user));
    });
  }

  Future<void> forgotPassword({required String email}) async {
    emit(AuthLoading());
    final result = await authRepository.forgotPassword(email);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (success) => emit(AuthOtpSentSuccess("OTP sent to your email")),
    );
  }

  Future<void> verifyOtp({required String email, required String otp}) async {
    emit(AuthLoading());
    final result = await authRepository.verifyOtp(email, otp);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (success) => emit(AuthOtpVerifiedSuccess("OTP verified successfully")),
    );
  }

  Future<void> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    emit(AuthLoading());
    final result = await authRepository.resetPassword(email, newPassword);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (success) =>
          emit(AuthPasswordResetSuccess("Password reset successfully")),
    );
  }
}
