import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:untitled10/core/api/api_error.dart';
import 'package:untitled10/features/auth/presentaion/manager/auth_state.dart';
import 'package:untitled10/features/auth/repo/auth_repo.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository authRepository;
  AuthCubit(this.authRepository) : super(AuthInitial());

  Future<void> login({required String email, required String password}) async {
    emit(AuthLoading());
    try {
      final result = await authRepository.login(email, password);
      result.fold((failure) => emit(AuthError(failure.message)), (user) {
        if (user != null) {
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
      result.fold(
        (failure) => emit(AuthError(failure.message)),
        (_) => emit(AuthSuccess("Logout Successfully")),
      );
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
