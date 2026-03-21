import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glucotrack/core/api/api_service.dart';
import 'package:glucotrack/features/auth/data/models/user_model.dart';
import 'package:glucotrack/features/home/presentation/manager/settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final ApiService apiService;
  SettingsCubit(this.apiService) : super(SettingsInitial.initial());

  /// Load settings from user data
  /// This method initializes the settings state with user-specific data
  /// [user] - The user model containing reminder settings
  void loadSettings(UserModel user) {
    // Derive enabled state from presence of time values
    // If time is set, reminder is enabled; otherwise it's disabled
    final sugarReminder = user.glucoTime != null && user.glucoTime!.isNotEmpty;
    final medicineReminder =
        user.medicineTime != null && user.medicineTime!.isNotEmpty;

    emit(
      SettingsInitial(
        sugarReminder: sugarReminder,
        medicineReminder: medicineReminder,
        glucoTime: user.glucoTime ?? '08:00',
        medicineTime: user.medicineTime ?? '20:00',
      ),
    );
  }

  Future<void> toggleSugarReminder(bool value) async {
    // Save the current state before emitting loading
    final currentState = state;
    if (currentState is! SettingsInitial) return;

    emit(
      SettingsLoading(
        sugarReminder: currentState.sugarReminder,
        medicineReminder: currentState.medicineReminder,
        glucoTime: currentState.glucoTime,
        medicineTime: currentState.medicineTime,
      ),
    );

    try {
      // If enabling: use current time or default
      // If disabling: send empty string to disable
      final newGlucoTime = value ? (currentState.glucoTime ?? '08:00') : '';

      final updated = currentState.copyWith(
        sugarReminder: value,
        glucoTime: value ? (currentState.glucoTime ?? '08:00') : null,
        clearGlucoTime: !value,
      );
      emit(updated);

      // Call API to update sugar reminder via user endpoint
      final result = await apiService.updateUser({'gluco_time': newGlucoTime});

      result.fold(
        (failure) {
          emit(
            SettingsFailure(
              message: failure.message,
              sugarReminder: currentState.sugarReminder,
              medicineReminder: currentState.medicineReminder,
              glucoTime: currentState.glucoTime,
              medicineTime: currentState.medicineTime,
              failedSetting: FailedSetting.sugarReminder,
            ),
          );
        },
        (data) {
          // Success - emit updated state with isSuccess flag to trigger UI update
          emit(updated.copyWith(isSuccess: true));
        },
      );
    } catch (e) {
      emit(
        SettingsFailure(
          message: e.toString(),
          sugarReminder: currentState.sugarReminder,
          medicineReminder: currentState.medicineReminder,
          glucoTime: currentState.glucoTime,
          medicineTime: currentState.medicineTime,
          failedSetting: FailedSetting.sugarReminder,
        ),
      );
    }
  }

  Future<void> toggleMedicineReminder(bool value) async {
    // Save the current state before emitting loading
    final currentState = state;
    if (currentState is! SettingsInitial) return;

    emit(
      SettingsLoading(
        sugarReminder: currentState.sugarReminder,
        medicineReminder: currentState.medicineReminder,
        glucoTime: currentState.glucoTime,
        medicineTime: currentState.medicineTime,
      ),
    );

    try {
      // If enabling: use current time or default
      // If disabling: send empty string to disable
      final newMedicineTime =
          value ? (currentState.medicineTime ?? '20:00') : '';

      final updated = currentState.copyWith(
        medicineReminder: value,
        medicineTime: value ? (currentState.medicineTime ?? '20:00') : null,
        clearMedicineTime: !value,
      );
      emit(updated);

      // Call API to update medicine reminder via user endpoint
      final result = await apiService.updateUser({
        'medicine_time': newMedicineTime,
      });

      result.fold(
        (failure) {
          emit(
            SettingsFailure(
              message: failure.message,
              sugarReminder: currentState.sugarReminder,
              medicineReminder: currentState.medicineReminder,
              glucoTime: currentState.glucoTime,
              medicineTime: currentState.medicineTime,
              failedSetting: FailedSetting.medicineReminder,
            ),
          );
        },
        (data) {
          // Success - emit updated state with isSuccess flag
          emit(updated.copyWith(isSuccess: true));
        },
      );
    } catch (e) {
      emit(
        SettingsFailure(
          message: e.toString(),
          sugarReminder: currentState.sugarReminder,
          medicineReminder: currentState.medicineReminder,
          glucoTime: currentState.glucoTime,
          medicineTime: currentState.medicineTime,
          failedSetting: FailedSetting.medicineReminder,
        ),
      );
    }
  }

  Future<void> updateGlucoTime(TimeOfDay time) async {
    final currentState = state;
    if (currentState is! SettingsInitial) return;
    if (!currentState.sugarReminder) return;

    final timeString =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

    emit(
      SettingsLoading(
        sugarReminder: currentState.sugarReminder,
        medicineReminder: currentState.medicineReminder,
        glucoTime: currentState.glucoTime,
        medicineTime: currentState.medicineTime,
      ),
    );

    try {
      final updated = currentState.copyWith(glucoTime: timeString);
      emit(updated);

      final result = await apiService.updateUser({'gluco_time': timeString});

      result.fold(
        (failure) {
          emit(
            SettingsFailure(
              message: failure.message,
              sugarReminder: currentState.sugarReminder,
              medicineReminder: currentState.medicineReminder,
              glucoTime: currentState.glucoTime,
              medicineTime: currentState.medicineTime,
              failedSetting: FailedSetting.sugarReminder,
            ),
          );
        },
        (data) {
          // Success - emit updated state with isSuccess flag
          emit(updated.copyWith(isSuccess: true));
        },
      );
    } catch (e) {
      emit(
        SettingsFailure(
          message: e.toString(),
          sugarReminder: currentState.sugarReminder,
          medicineReminder: currentState.medicineReminder,
          glucoTime: currentState.glucoTime,
          medicineTime: currentState.medicineTime,
          failedSetting: FailedSetting.sugarReminder,
        ),
      );
    }
  }

  Future<void> updateMedicineTime(TimeOfDay time) async {
    final currentState = state;
    if (currentState is! SettingsInitial) return;
    if (!currentState.medicineReminder) return;

    final timeString =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

    emit(
      SettingsLoading(
        sugarReminder: currentState.sugarReminder,
        medicineReminder: currentState.medicineReminder,
        glucoTime: currentState.glucoTime,
        medicineTime: currentState.medicineTime,
      ),
    );

    try {
      final updated = currentState.copyWith(medicineTime: timeString);
      emit(updated);

      final result = await apiService.updateUser({'medicine_time': timeString});

      result.fold(
        (failure) {
          emit(
            SettingsFailure(
              message: failure.message,
              sugarReminder: currentState.sugarReminder,
              medicineReminder: currentState.medicineReminder,
              glucoTime: currentState.glucoTime,
              medicineTime: currentState.medicineTime,
              failedSetting: FailedSetting.medicineReminder,
            ),
          );
        },
        (data) {
          // Success - emit updated state with isSuccess flag
          emit(updated.copyWith(isSuccess: true));
        },
      );
    } catch (e) {
      emit(
        SettingsFailure(
          message: e.toString(),
          sugarReminder: currentState.sugarReminder,
          medicineReminder: currentState.medicineReminder,
          glucoTime: currentState.glucoTime,
          medicineTime: currentState.medicineTime,
          failedSetting: FailedSetting.medicineReminder,
        ),
      );
    }
  }
}
