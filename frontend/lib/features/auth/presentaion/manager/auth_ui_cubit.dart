import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glucotrack/features/auth/presentaion/manager/auth_ui_state.dart';

class AuthUiCubit extends Cubit<AuthUiState> {
  AuthUiCubit() : super(const AuthUiState());

  void togglePasswordVisibility() {
    emit(state.copyWith(isPasswordVisible: !state.isPasswordVisible));
  }
}
