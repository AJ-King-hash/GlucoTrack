import 'package:equatable/equatable.dart';
import 'package:glucotrack/features/auth/data/models/user_model.dart';

abstract class UserState extends Equatable {
  @override
  List<Object?> get props => [];
}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final UserModel userModel;
  UserLoaded(this.userModel);
  @override
  List<Object?> get props => [userModel];
}

class UserSuccess extends UserState {
  final String message;
  UserSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class UserError extends UserState {
  final String message;
  UserError(this.message);
  @override
  List<Object?> get props => [message];
}
