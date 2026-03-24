import 'package:equatable/equatable.dart';
import 'package:glucotrack/features/auth/data/models/user_model.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final String message;
  final UserModel? user;
  AuthSuccess(this.message, {this.user});
  @override
  List<Object?> get props => [message, user];
}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
  @override
  List<Object?> get props => [message];
}
