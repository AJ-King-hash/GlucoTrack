import 'package:equatable/equatable.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

class SettingsInitial extends SettingsState {
  final bool sugarReminder;
  final bool medicineReminder;
  final String? glucoTime;
  final String? medicineTime;

  const SettingsInitial({
    required this.sugarReminder,
    required this.medicineReminder,
    this.glucoTime,
    this.medicineTime,
  });

  factory SettingsInitial.initial() {
    return const SettingsInitial(
      sugarReminder: true,
      medicineReminder: false,
      glucoTime: '08:00',
      medicineTime: '20:00',
    );
  }

  SettingsInitial copyWith({
    bool? sugarReminder,
    bool? medicineReminder,
    String? glucoTime,
    String? medicineTime,
    bool clearGlucoTime = false,
    bool clearMedicineTime = false,
  }) {
    return SettingsInitial(
      sugarReminder: sugarReminder ?? this.sugarReminder,
      medicineReminder: medicineReminder ?? this.medicineReminder,
      glucoTime: clearGlucoTime ? null : (glucoTime ?? this.glucoTime),
      medicineTime:
          clearMedicineTime ? null : (medicineTime ?? this.medicineTime),
    );
  }

  @override
  List<Object?> get props => [
    sugarReminder,
    medicineReminder,
    glucoTime,
    medicineTime,
  ];
}

class SettingsLoading extends SettingsState {
  const SettingsLoading();
}

class SettingsLoaded extends SettingsState {
  const SettingsLoaded();
}

enum FailedSetting { none, sugarReminder, medicineReminder }

class SettingsFailure extends SettingsState {
  final String message;
  final bool sugarReminder;
  final bool medicineReminder;
  final String? glucoTime;
  final String? medicineTime;
  final FailedSetting failedSetting;

  const SettingsFailure({
    required this.message,
    this.sugarReminder = true,
    this.medicineReminder = false,
    this.glucoTime,
    this.medicineTime,
    this.failedSetting = FailedSetting.none,
  });

  SettingsFailure copyWith({
    String? message,
    bool? sugarReminder,
    bool? medicineReminder,
    String? glucoTime,
    String? medicineTime,
    FailedSetting? failedSetting,
  }) {
    return SettingsFailure(
      message: message ?? this.message,
      sugarReminder: sugarReminder ?? this.sugarReminder,
      medicineReminder: medicineReminder ?? this.medicineReminder,
      glucoTime: glucoTime ?? this.glucoTime,
      medicineTime: medicineTime ?? this.medicineTime,
      failedSetting: failedSetting ?? this.failedSetting,
    );
  }

  @override
  List<Object?> get props => [
    message,
    sugarReminder,
    medicineReminder,
    glucoTime,
    medicineTime,
    failedSetting,
  ];
}
