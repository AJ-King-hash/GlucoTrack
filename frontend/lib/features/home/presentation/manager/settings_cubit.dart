import 'package:flutter_bloc/flutter_bloc.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(SettingsInitial.initial());

  void toggleSugarReminder(bool value) {
    if (state is SettingsInitial) {
      final current = state as SettingsInitial;
      emit(current.copyWith(sugarReminder: value));
    }
  }

  void toggleMedicineReminder(bool value) {
    if (state is SettingsInitial) {
      final current = state as SettingsInitial;
      emit(current.copyWith(medicineReminder: value));
    }
  }

  void toggleBiometric(bool value) {
    if (state is SettingsInitial) {
      final current = state as SettingsInitial;
      emit(current.copyWith(biometricLogin: value));
    }
  }
}
