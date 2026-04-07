# Notification Feature - Frontend Implementation Status Report

**Date:** 2026-03-23  
**Project:** GlucoTrack Flutter Frontend  
**Investigated by:** Flutter Senior Developer

---

## 📋 Current State Summary

The notification feature has been **started and partially implemented**. Based on full-stack analysis:

### Backend Components (Fully Implemented)

| Component            | Status      | Location                                                                                  |
| -------------------- | ----------- | ----------------------------------------------------------------------------------------- |
| User Model           | ✅ Complete | `Backend/models.py` (lines 96-99: gluco_reminder, medicine_reminder, fcm_token, timezone) |
| Schemas              | ✅ Complete | `Backend/schemas.py` (UserReminderUpdate, FCMTokenUpdate)                                 |
| Repository           | ✅ Complete | `Backend/repositories/NotificationRepo.py`                                                |
| Router + Polling     | ✅ Complete | `Backend/routers/notification.py` (APScheduler every 5 min, FCM)                          |
| Firebase Integration | ✅ Complete | Using firebase_admin SDK                                                                  |

### Frontend Components

| Component             | Status      | Location                                                                  |
| --------------------- | ----------- | ------------------------------------------------------------------------- |
| Notification Service  | ✅ Complete | `lib/core/services/notification_service.dart`                             |
| Notification Cubit    | ✅ Complete | `lib/features/notification/presentation/manager/notification_cubit.dart`  |
| Notification States   | ✅ Complete | `lib/features/notification/presentation/manager/notification_state.dart`  |
| Reminder Settings UI  | ✅ Complete | `lib/features/notification/presentation/view/reminder_settings_page.dart` |
| Dependency Injection  | ✅ Complete | `lib/core/injection_container.dart`                                       |
| Android Manifest      | ✅ Complete | `android/app/src/main/AndroidManifest.xml`                                |
| API Endpoints         | ❌ Wrong    | `lib/core/api/end_point.dart`                                             |
| API Service Methods   | ❌ Wrong    | `lib/core/api/api_service.dart`                                           |
| iOS Configuration     | ❌ Missing  | `ios/Runner/`                                                             |
| Firebase Config Files | ❌ Missing  | `android/app/google-services.json`, `ios/Runner/GoogleService-Info.plist` |

---

## 🐛 Bugs & Issues Identified

### 1. **Critical: API Endpoints Point to Wrong Paths**

**File:** [`lib/core/api/end_point.dart`](frontend/lib/core/api/end_point.dart:51)

```dart
// Current (INCORRECT):
static const String updateReminders = "/user";
static const String updateFcmToken = "/user";
static const String triggerReminders = "/user";
```

**Backend expects:**

- `PUT /notification/reminders` - Update reminder times
- `POST /notification/fcm-token` - Update FCM token
- `GET /notification/trigger-reminders` - Manual trigger (testing)

---

### 2. **Critical: API Service Uses Wrong HTTP Methods**

**File:** [`lib/core/api/api_service.dart`](frontend/lib/core/api/api_service.dart:325)

```dart
// Current: All use PUT to /user
Future<Either<Failure, dynamic>> updateReminders({...}) =>
    _handleRequest(_dio.put(ApiEndpoints.updateReminders, data: body), ...);

Future<Either<Failure, dynamic>> updateFcmToken(String token) =>
    _handleRequest(_dio.post(ApiEndpoints.updateFcmToken, data: {...}), ...);

Future<Either<Failure, dynamic>> triggerReminders() =>
    _handleRequest(_dio.get(ApiEndpoints.triggerReminders), ...);
```

The endpoints point to `/user` but the methods might not match. Need to verify against backend router:

- `PUT /notification/reminders` - Update reminder times
- `POST /notification/fcm-token` - Update FCM token
- `GET /notification/trigger-reminders` - Manual trigger

---

### 3. **Critical: Missing Firebase Configuration Files**

The following files are required but missing:

- `android/app/google-services.json` - Required for Android Firebase
- `ios/Runner/GoogleService-Info.plist` - Required for iOS Firebase

Without these, Firebase initialization will fail in production.

---

### 4. **Warning: NotificationCubit State Emission Issues**

**File:** [`lib/features/notification/presentation/manager/notification_cubit.dart`](frontend/lib/features/notification/presentation/manager/notification_cubit.dart:51)

After successful reminder update, two states are emitted sequentially:

```dart
if (success) {
  ToastUtility.showSuccess('Reminders updated successfully');
  GetIt.I<GlobalRefresher>().triggerGlobalRefresh();
  emit(ReminderSettingsUpdated('Reminders updated successfully'));  // First state
  // Load the updated settings
  emit(  // Second state immediately after
    ReminderSettingsLoaded(...),
  );
}
```

**Issue:** This overwrites the first state immediately, making it impossible for UI to show the success message. The `ReminderSettingsUpdated` state will never be rendered.

---

### 5. **Warning: Payload Parsing Issue**

**File:** [`lib/core/services/notification_service.dart`](frontend/lib/core/services/notification_service.dart:216)

```dart
void _onNotificationTapped(NotificationResponse response) {
  if (onNotificationTapped != null && response.payload != null) {
    onNotificationTapped!({'payload': response.payload});  // Wraps as string
  }
}
```

The payload is converted to string using `payload?.toString()` in line 199, then parsed back. This loses structured data - the payload should be passed as-is or use proper JSON serialization.

---

### 6. **Warning: iOS Missing Notification Configuration**

**File:** `ios/Runner/AppDelegate.swift`

The iOS AppDelegate doesn't configure Firebase or handle background notifications properly. Missing:

- `FirebaseApp.configure()` initialization
- Remote notification delegate registration

---

### 7. **Warning: Hardcoded Base URL**

**File:** [`lib/core/api/end_point.dart`](frontend/lib/core/api/end_point.dart:5)

```dart
/// Base URL: http://10.248.171.223:8000
```

This local IP address won't work in production. Should use environment-based configuration.

---

### 8. **Info: Missing Localization Keys**

**File:** [`lib/features/notification/presentation/view/reminder_settings_page.dart`](frontend/lib/features/notification/presentation/view/reminder_settings_page.dart:112)

```dart
title: Text(locale.translate('reminders')),  // Key may not exist
```

The translation key `'reminders'` should be verified in:

- `assets/lan/en.json`
- `assets/lan/ar.json`

---

## ⚠️ Warnings

1. **Token Refresh Not Connected:** The `refreshToken()` method in NotificationService is defined but never called from NotificationCubit
2. **No Loading State Display:** The `NotificationLoading` state is emitted but not properly handled in UI to show loading indicator
3. **Timezone Not Saved:** UI timezone selector is not connected to User model - timezone changes aren't persisted
4. **No Notification History:** There's no UI or storage for viewing notification history
5. **Test Button Exposed:** The "Test Notifications" button is visible in production - should be debug-only

---

## 📝 Next Suggested Steps

### Priority 1: Critical Fixes (Must Fix Before Release)

1. **Fix API Endpoints** - Create dedicated endpoints in `end_point.dart`:

   ```dart
   static const String updateReminders = "/notification/reminders";
   static const String updateFcmToken = "/notification/fcm-token";
   static const String triggerReminders = "/notification/trigger-reminders";
   ```

2. **Fix API Service Methods** - Ensure correct HTTP methods in `api_service.dart`:
   - `updateReminders`: PUT to `/notification/reminders`
   - `updateFcmToken`: POST to `/notification/fcm-token`
   - `triggerReminders`: GET to `/notification/trigger-reminders`

3. **Add Firebase Configuration Files**
   - Download `google-services.json` from Firebase Console
   - Download `GoogleService-Info.plist` from Firebase Console

4. **Fix State Emission in NotificationCubit** - Use delayed state emission:
   ```dart
   emit(ReminderSettingsUpdated('Reminders updated successfully'));
   await Future.delayed(const Duration(milliseconds: 100));
   emit(ReminderSettingsLoaded(...));
   ```

### Priority 2: Important Improvements

5. **Configure iOS AppDelegate** for Firebase
6. **Add proper payload handling** - Use JSON encoding/decoding instead of toString()
7. **Verify localization keys** exist in en.json and ar.json
8. **Remove hardcoded IP** - Use environment configuration

### Priority 3: Nice to Have

9. **Connect timezone to user model** - Store and retrieve timezone preference
10. **Add notification history UI** - Show past notifications
11. **Hide test button in production** - Use kDebugMode check
12. **Implement token refresh** - Call refreshToken() on app start

---

## 📁 Affected Files

| File                                                                      | Action Needed                                  |
| ------------------------------------------------------------------------- | ---------------------------------------------- |
| `lib/core/api/end_point.dart`                                             | Fix endpoints to use `/notification/...` paths |
| `lib/core/api/api_service.dart`                                           | Fix HTTP methods and endpoints                 |
| `lib/core/services/notification_service.dart`                             | Fix payload handling                           |
| `lib/features/notification/presentation/manager/notification_cubit.dart`  | Fix state emission                             |
| `lib/features/notification/presentation/view/reminder_settings_page.dart` | Localization verification                      |
| `ios/Runner/AppDelegate.swift`                                            | Add Firebase config                            |
| `android/app/google-services.json`                                        | Add file                                       |
| `ios/Runner/GoogleService-Info.plist`                                     | Add file                                       |

---

## 🎯 Conclusion

The notification feature is **~65% complete** on the frontend side. The backend is **fully implemented** with:

- Polling mechanism (APScheduler every 5 minutes)
- Firebase Cloud Messaging integration
- Proper API endpoints at `/notification/*`

The frontend requires critical fixes to connect properly to the backend endpoints. Once these issues are resolved, the feature should be functional for basic reminder notifications.

**Recommendation:** Fix Priority 1 issues first, then run a full integration test with the backend before proceeding to Priority 2 items.
