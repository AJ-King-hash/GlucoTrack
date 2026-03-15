import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:untitled10/core/api/api_service.dart';
import 'package:untitled10/features/auth/data/models/user_model.dart';
import 'package:untitled10/features/home/presentation/manager/settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final ApiService apiService;
  SettingsCubit(this.apiService) : super(SettingsInitial.initial());

  /// Load settings from user data
  /// This method initializes the settings state with user-specific data
  ///
  /// [user] - The user model containing reminder settings
  void loadSettings(UserModel user) {
    // Use user data if available, otherwise use defaults
    final sugarReminder = user.sugarReminder ?? true;
    final medicineReminder = user.medicineReminder ?? false;

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

    emit(SettingsLoading());
    try {
      final updated = currentState.copyWith(
        sugarReminder: value,
        glucoTime: value ? (currentState.glucoTime ?? '08:00') : null,
        clearGlucoTime: !value,
      );
      emit(updated);

      // Call API to update sugar reminder via user endpoint
      final result = await apiService.updateUser({
        'gluco_time': value ? (currentState.glucoTime ?? '08:00') : '',
      });

      result.fold((failure) {
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
      }, (data) async {});
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

    emit(SettingsLoading());
    try {
      final updated = currentState.copyWith(
        medicineReminder: value,
        medicineTime: value ? (currentState.medicineTime ?? '20:00') : null,
        clearMedicineTime: !value,
      );
      emit(updated);

      // Call API to update medicine reminder via user endpoint
      final result = await apiService.updateUser({
        'medicine_time': value ? (currentState.medicineTime ?? '20:00') : '',
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
        (_) {
          emit(currentState.copyWith(medicineReminder: value, isSuccess: true));
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

    emit(SettingsLoading());
    try {
      final updated = currentState.copyWith(glucoTime: timeString);
      emit(updated);

      final result = await apiService.updateUser({'gluco_time': timeString});

      result.fold((failure) {
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
      }, (_) {});
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

    emit(SettingsLoading());
    try {
      final updated = currentState.copyWith(medicineTime: timeString);
      emit(updated);

      final result = await apiService.updateUser({'medicine_time': timeString});

      result.fold((failure) {
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
      }, (_) {});
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
