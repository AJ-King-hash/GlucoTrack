class AuthUiState {
  final bool isPasswordVisible;
  const AuthUiState({ this.isPasswordVisible=false});
  AuthUiState copyWith({bool? isPasswordVisible}){
    return AuthUiState(
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
    );
  }
}