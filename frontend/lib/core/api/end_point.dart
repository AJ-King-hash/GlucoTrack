// file: api_endpoints.dart

/// Backend API Endpoints Configuration
///
/// Base URL: http://192.168.251.59:8000
/// All endpoints are prefixed with the base URL
class ApiEndpoints {
  ApiEndpoints._();

  // ==================== AUTH ====================
  static const String login = "/auth/login";
  static const String logout = "/auth/logout";

  // ==================== USER ====================
  static const String user = "/user/";
  static String userById(int id) => "/user/$id";
  static const String userUpdate = "/user/";
  static const String userDelete = "/user/";

  // ==================== BOT - CONVERSATION ====================
  static const String conversation = "/bot/conversation";
  static String conversationById(int id) => "/bot/conversation/$id";
  static const String allConversations = "/bot/conversation/all/";

  // ==================== BOT - MESSAGE ====================
  static const String message = "/bot/message";
  static String allMessages(int convId) => "/bot/message/all/$convId";

  // ==================== RISK ====================
  /// Note: Risk endpoints use current authenticated user
  /// Backend routes: POST /risk/, GET /risk/, PUT /risk/, DELETE /risk/
  static const String risk = "/risk/";

  // ==================== MEAL ====================
  static const String meal = "/meal/";
  static String mealById(int id) => "/meal/$id";
  static const String allMeals = "/meal/all/";

  // ==================== ANALYSIS ====================
  static const String allAnalysis = "/analyse/all/";
  static String deleteAnalysis(int id) => "/analyse/$id";

  // ==================== OTP ====================
  static const String otpCheck = "/otp/check";
  static const String otpForgotPassword = "/otp/forgot-password";
  static const String otpVerify = "/otp/verify-otp";
  static const String otpResetPassword = "/otp/reset-password";

  // ==================== NOTIFICATIONS ====================
  /// Update user reminder times (medicine_time, gluco_time)
  static const String updateReminders = "/notification/reminders";

  /// Update FCM token for push notifications
  static const String updateFcmToken = "/notification/fcm-token";

  /// Trigger reminders manually (for testing)
  static const String triggerReminders = "/notification/trigger-reminders";
}
