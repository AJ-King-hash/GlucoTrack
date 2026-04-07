/// Application-wide constants
class AppConstants {
  AppConstants._();

  // App Information
  static const String appName = 'GlucoTrack';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';

  // API Configuration
  static const String apiBaseUrl = 'https://api.glucoTrack.com';
  static const int apiTimeoutSeconds = 30;
  static const int apiMaxRetries = 3;

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';
  static const String localeKey = 'locale';
  static const String themeKey = 'theme_mode';

  // Hive Box Names
  static const String userBoxName = 'user_box';
  static const String glucoseBoxName = 'glucose_box';
  static const String settingsBoxName = 'settings_box';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Glucose Ranges (mg/dL)
  static const double glucoseMinNormal = 70.0;
  static const double glucoseMaxNormal = 140.0;
  static const double glucoseMinLow = 54.0;
  static const double glucoseMaxHigh = 180.0;

  // BMI Categories
  static const double bmiUnderweight = 18.5;
  static const double bmiNormal = 24.9;
  static const double bmiOverweight = 29.9;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Notification Channels
  static const String notificationChannelId = 'glucotrack_notifications';
  static const String notificationChannelName = 'GlucoTrack Notifications';
  static const String notificationChannelDescription =
      'Glucose tracking reminders and alerts';
}
