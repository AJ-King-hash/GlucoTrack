import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:glucotrack/core/utils/global_refresher.dart';
import 'package:glucotrack/features/auth/data/models/user_model.dart';
import 'package:glucotrack/features/home/presentation/manager/settings_state.dart';
import 'package:glucotrack/features/user/presentation/manager/user_cubit.dart';
import 'package:glucotrack/features/user/presentation/manager/user_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final UserCubit userCubit;
  SettingsCubit(this.userCubit) : super(SettingsInitial.initial()) {
    userCubit.stream.listen((userState) {
      if (userState is UserError) {
        final failedSetting =
            state is SettingsFailure
                ? (state as SettingsFailure).failedSetting
                : FailedSetting.none;
        emit(
          SettingsFailure(
            message: userState.message,
            sugarReminder: state.sugarReminder,
            medicineReminder: state.medicineReminder,
            glucoTime: state.glucoTime,
            medicineTime: state.medicineTime,
            failedSetting: failedSetting,
          ),
        );
      } else if (userState is UserSuccess) {
        GetIt.I<GlobalRefresher>().triggerGlobalRefresh();
      }
    });
  }

  void loadSettings(UserModel user) {
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
    print("toggle value: " + value.toString());
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
      final newGlucoTime = value ? '08:00' : "";

      final updated = currentState.copyWith(
        sugarReminder: value,
        glucoTime: newGlucoTime,
      );

      emit(updated);

      await userCubit.updateUser(glucoTime: newGlucoTime);
      emit(updated.copyWith(isSuccess: true));
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
      await userCubit.updateUser(medicineTime: newMedicineTime);
      emit(updated.copyWith(isSuccess: true));
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

      await userCubit.updateUser(glucoTime: timeString);
      emit(updated.copyWith(isSuccess: true));
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

      await userCubit.updateUser(medicineTime: timeString);
      emit(updated.copyWith(isSuccess: true));
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
