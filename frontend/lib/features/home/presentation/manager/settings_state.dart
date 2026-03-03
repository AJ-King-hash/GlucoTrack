import 'package:equatable/equatable.dart';

abstract class SettingsState extends Equatable{
  const SettingsState();
  @override
  List<Object?> get props =>[];
}
class SettingsInitial extends SettingsState{
  final bool sugarReminder;
  final bool medicineReminder;
  final bool biometricLogin;

  const SettingsInitial({
    required this.sugarReminder,
    required this.medicineReminder,
    required this.biometricLogin,
  });

  factory SettingsInitial.initial() {
    return const SettingsInitial(
      sugarReminder: true,
      medicineReminder: false,
      biometricLogin: false,
    );
  }
  SettingsInitial copyWith({
    bool? sugarReminder,
    bool? medicineReminder,
    bool? biometricLogin,
  }) {
    return SettingsInitial(
      sugarReminder: sugarReminder ?? this.sugarReminder,
      medicineReminder: medicineReminder ?? this.medicineReminder,
      biometricLogin: biometricLogin ?? this.biometricLogin,
    );
  }

  @override
  List<Object> get props => [
    sugarReminder,
    medicineReminder,
    biometricLogin,
  ];
}
class SettingsLoaded extends SettingsState{

}
class SettingsFailure extends SettingsState{
  final String message;
  const SettingsFailure({required this.message});
  @override
  List<Object?> get props=>[message];
}