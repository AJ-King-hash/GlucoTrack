import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:glucotrack/core/services/notification_service.dart';
import 'package:glucotrack/core/utils/global_refresher.dart';
import 'package:glucotrack/core/utils/toast_utility.dart';
import 'package:glucotrack/features/notification/presentation/manager/notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final NotificationService _notificationService;

  NotificationCubit(this._notificationService) : super(NotificationInitial());

  /// Initialize the notification service
  Future<void> initialize() async {
    emit(NotificationLoading());
    try {
      await _notificationService.initialize();

      // Set up notification received callback
      _notificationService.onNotificationReceived = (data) {
        // Handle notification received
        emit(
          NotificationReceived(
            title: data['title'] ?? 'GlucoTrack',
            body: data['body'] ?? '',
            data: data,
          ),
        );
      };

      emit(NotificationInitial());
    } catch (e) {
      emit(NotificationError('Failed to initialize notifications: $e'));
    }
  }

  /// Update reminder settings
  Future<void> updateReminders({
    String? glucoTime,
    String? medicineTime,
    String? timezone,
  }) async {
    emit(NotificationLoading());
    try {
      final success = await _notificationService.updateReminders(
        glucoTime: glucoTime,
        medicineTime: medicineTime,
        timezone: timezone,
      );

      if (success) {
        ToastUtility.showSuccess('Reminders updated successfully');
        GetIt.I<GlobalRefresher>().triggerGlobalRefresh();
        // Delay to allow UI to show success state before loading new state
        emit(
          ReminderSettingsLoaded(
            glucoTime: glucoTime,
            medicineTime: medicineTime,
            timezone: timezone ?? 'UTC',
          ),
        );
      } else {
        ToastUtility.showError('Failed to update reminders');
        GetIt.I<GlobalRefresher>().triggerGlobalRefresh();
        emit(NotificationError('Failed to update reminders'));
      }
    } catch (e) {
      ToastUtility.showError('Error updating reminders: $e');
      GetIt.I<GlobalRefresher>().triggerGlobalRefresh();
      emit(NotificationError('Error updating reminders: $e'));
    }
  }

  /// Clear reminder (set to null)
  Future<void> clearReminder(String reminderType) async {
    emit(NotificationLoading());
    try {
      final currentState = state;
      String? glucoTime;
      String? medicineTime;
      String timezone = 'UTC';

      if (currentState is ReminderSettingsLoaded) {
        glucoTime = currentState.glucoTime;
        medicineTime = currentState.medicineTime;
        timezone = currentState.timezone;
      }

      bool success;
      if (reminderType == 'gluco') {
        success = await _notificationService.updateReminders(
          medicineTime: medicineTime,
          timezone: timezone,
        );
      } else if (reminderType == 'medicine') {
        success = await _notificationService.updateReminders(
          glucoTime: glucoTime,
          timezone: timezone,
        );
      } else {
        success = false;
      }

      if (success) {
        ToastUtility.showSuccess('Reminder cleared');
        GetIt.I<GlobalRefresher>().triggerGlobalRefresh();
        emit(ReminderSettingsUpdated('Reminder cleared'));
      } else {
        ToastUtility.showError('Failed to clear reminder');
        GetIt.I<GlobalRefresher>().triggerGlobalRefresh();
        emit(NotificationError('Failed to clear reminder'));
      }
    } catch (e) {
      ToastUtility.showError('Error clearing reminder: $e');
      GetIt.I<GlobalRefresher>().triggerGlobalRefresh();
      emit(NotificationError('Error clearing reminder: $e'));
    }
  }

  /// Trigger reminders manually (for testing)
  Future<void> triggerReminders() async {
    emit(NotificationLoading());
    try {
      final success = await _notificationService.triggerReminders();
      if (success) {
        ToastUtility.showSuccess('Reminders triggered');
        GetIt.I<GlobalRefresher>().triggerGlobalRefresh();
        emit(ReminderSettingsUpdated('Reminders triggered'));
      } else {
        ToastUtility.showError('Failed to trigger reminders');
        GetIt.I<GlobalRefresher>().triggerGlobalRefresh();
        emit(NotificationError('Failed to trigger reminders'));
      }
    } catch (e) {
      ToastUtility.showError('Error triggering reminders: $e');
      GetIt.I<GlobalRefresher>().triggerGlobalRefresh();
      emit(NotificationError('Error triggering reminders: $e'));
    }
  }
}
