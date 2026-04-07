import 'package:equatable/equatable.dart';
import 'package:glucotrack/features/auth/data/models/user_model.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

// Specific success state for the Login flow
class AuthLoginSuccess extends AuthState {
  final String message;
  final UserModel? user;
  const AuthLoginSuccess(this.message, {this.user});

  @override
  List<Object?> get props => [message, user];
}

// Specific success state for Requesting OTP (Forgot Password)
class AuthOtpSentSuccess extends AuthState {
  final String message;
  const AuthOtpSentSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

// Specific success state for Verifying OTP
class AuthOtpVerifiedSuccess extends AuthState {
  final String message;
  const AuthOtpVerifiedSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

// Specific success state for final Password Reset
class AuthPasswordResetSuccess extends AuthState {
  final String message;
  const AuthPasswordResetSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
