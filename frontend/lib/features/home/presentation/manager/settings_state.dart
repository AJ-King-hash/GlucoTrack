import 'package:equatable/equatable.dart';

enum FailedSetting { none, sugarReminder, medicineReminder }

abstract class SettingsState extends Equatable {
  final bool sugarReminder;
  final bool medicineReminder;
  final String? glucoTime;
  final String? medicineTime;
  final bool isSuccess; // New flag for toast triggers

  const SettingsState({
    this.sugarReminder = true,
    this.medicineReminder = false,
    this.glucoTime,
    this.medicineTime,
    this.isSuccess = false,
  });

  @override
  List<Object?> get props => [
    sugarReminder,
    medicineReminder,
    glucoTime,
    medicineTime,
    isSuccess,
  ];
}

class SettingsInitial extends SettingsState {
  const SettingsInitial({
    required super.sugarReminder,
    required super.medicineReminder,
    super.glucoTime,
    super.medicineTime,
    super.isSuccess,
  });

  factory SettingsInitial.initial() {
    return const SettingsInitial(
      sugarReminder: true,
      medicineReminder: false,
      glucoTime: '08:00',
      medicineTime: '20:00',
      isSuccess: false,
    );
  }

  SettingsInitial copyWith({
    bool? sugarReminder,
    bool? medicineReminder,
    String? glucoTime,
    String? medicineTime,
    bool clearGlucoTime = false,
    bool clearMedicineTime = false,
    bool? isSuccess,
  }) {
    return SettingsInitial(
      sugarReminder: sugarReminder ?? this.sugarReminder,
      medicineReminder: medicineReminder ?? this.medicineReminder,
      glucoTime: clearGlucoTime ? null : (glucoTime ?? this.glucoTime),
      medicineTime:
          clearMedicineTime ? null : (medicineTime ?? this.medicineTime),
      isSuccess: isSuccess ?? false,
    );
  }
}

class SettingsLoading extends SettingsState {
  const SettingsLoading({
    super.sugarReminder,
    super.medicineReminder,
    super.glucoTime,
    super.medicineTime,
  });
}

class SettingsFailure extends SettingsState {
  final String message;
  final FailedSetting failedSetting;

  const SettingsFailure({
    required this.message,
    super.sugarReminder,
    super.medicineReminder,
    super.glucoTime,
    super.medicineTime,
    this.failedSetting = FailedSetting.none,
  });

  @override
  List<Object?> get props => [...super.props, message, failedSetting];
}
