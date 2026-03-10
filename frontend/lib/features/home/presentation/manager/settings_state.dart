import 'package:equatable/equatable.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

class SettingsInitial extends SettingsState {
  final bool sugarReminder;
  final bool medicineReminder;

  const SettingsInitial({
    required this.sugarReminder,
    required this.medicineReminder,
  });

  factory SettingsInitial.initial() {
    return const SettingsInitial(sugarReminder: true, medicineReminder: false);
  }

  SettingsInitial copyWith({bool? sugarReminder, bool? medicineReminder}) {
    return SettingsInitial(
      sugarReminder: sugarReminder ?? this.sugarReminder,
      medicineReminder: medicineReminder ?? this.medicineReminder,
    );
  }

  @override
  List<Object> get props => [sugarReminder, medicineReminder];
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
  final FailedSetting failedSetting;

  const SettingsFailure({
    required this.message,
    this.sugarReminder = true,
    this.medicineReminder = false,
    this.failedSetting = FailedSetting.none,
  });

  SettingsFailure copyWith({
    String? message,
    bool? sugarReminder,
    bool? medicineReminder,
    FailedSetting? failedSetting,
  }) {
    return SettingsFailure(
      message: message ?? this.message,
      sugarReminder: sugarReminder ?? this.sugarReminder,
      medicineReminder: medicineReminder ?? this.medicineReminder,
      failedSetting: failedSetting ?? this.failedSetting,
    );
  }

  @override
  List<Object?> get props => [
    message,
    sugarReminder,
    medicineReminder,
    failedSetting,
  ];
}
