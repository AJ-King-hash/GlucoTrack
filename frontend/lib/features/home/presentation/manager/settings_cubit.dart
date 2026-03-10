import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:untitled10/core/api/api_service.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final ApiService apiService;
  SettingsCubit(this.apiService) : super(SettingsInitial.initial());

  Future<void> toggleSugarReminder(bool value) async {
    emit(SettingsLoading());
    try {
      if (state is SettingsInitial) {
        final current = state as SettingsInitial;
        final updated = current.copyWith(sugarReminder: value);
        emit(updated);

        // Call API to update sugar reminder
        final result = await apiService.updateReminders(
          glucoTime: value ? "08:00" : null,
        );

        result.fold(
          (failure) {
            // Revert state on failure directly to failure state
            emit(
              SettingsFailure(
                message: failure.message,
                sugarReminder: current.sugarReminder,
                medicineReminder: current.medicineReminder,
                failedSetting: FailedSetting.sugarReminder,
              ),
            );
          },
          (_) {
            // Success - state already updated above
          },
        );
      }
    } catch (e) {
      emit(
        SettingsFailure(
          message: e.toString(),
          sugarReminder: (state as SettingsInitial).sugarReminder,
          medicineReminder: (state as SettingsInitial).medicineReminder,
          failedSetting: FailedSetting.sugarReminder,
        ),
      );
    }
  }

  Future<void> toggleMedicineReminder(bool value) async {
    emit(SettingsLoading());
    try {
      if (state is SettingsInitial) {
        final current = state as SettingsInitial;
        final updated = current.copyWith(medicineReminder: value);
        emit(updated);

        // Call API to update medicine reminder
        final result = await apiService.updateReminders(
          medicineTime: value ? "20:00" : null,
        );

        result.fold(
          (failure) {
            // Revert state on failure directly to failure state
            emit(
              SettingsFailure(
                message: failure.message,
                sugarReminder: current.sugarReminder,
                medicineReminder: current.medicineReminder,
                failedSetting: FailedSetting.medicineReminder,
              ),
            );
          },
          (_) {
            // Success - state already updated above
          },
        );
      }
    } catch (e) {
      emit(
        SettingsFailure(
          message: e.toString(),
          sugarReminder: (state as SettingsInitial).sugarReminder,
          medicineReminder: (state as SettingsInitial).medicineReminder,
          failedSetting: FailedSetting.medicineReminder,
        ),
      );
    }
  }
}
