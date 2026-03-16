import 'package:equatable/equatable.dart';

abstract class NotificationState extends Equatable {
  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class ReminderSettingsLoaded extends NotificationState {
  final String? glucoTime;
  final String? medicineTime;
  final String timezone;

  ReminderSettingsLoaded({
    this.glucoTime,
    this.medicineTime,
    this.timezone = 'UTC',
  });

  @override
  List<Object?> get props => [glucoTime, medicineTime, timezone];
}

class ReminderSettingsUpdated extends NotificationState {
  final String message;

  ReminderSettingsUpdated(this.message);

  @override
  List<Object?> get props => [message];
}

class NotificationError extends NotificationState {
  final String message;

  NotificationError(this.message);

  @override
  List<Object?> get props => [message];
}

class NotificationReceived extends NotificationState {
  final String title;
  final String body;
  final Map<String, dynamic>? data;

  NotificationReceived({required this.title, required this.body, this.data});

  @override
  List<Object?> get props => [title, body, data];
}
