// file: api_endpoints.dart

class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const String login = "/auth/login";

  // User
  static const String user = "/user/";
  static String userById(int id) => "/user/$id";

  // Bot - Conversation
  static const String conversation = "/bot/conversation";
  static String conversationById(int id) => "/bot/conversation/$id";
  static String allConversations(int userId) =>
      "/bot/conversation/all/$userId";

  // Bot - Message
  static const String message = "/bot/message";
  static String allMessages(int convId) =>
      "/bot/message/all/$convId";

  // Risk
  static const String risk = "/risk/";
  static String riskById(int id) => "/risk/$id";

  // Meal
  static const String meal = "/meal/";
  static String mealById(int id) => "/meal/$id";

  // Analysis
  static String allAnalysis(int id) => "/analyse/all/$id";
  static String deleteAnalysis(int id) => "/analyse/$id";

  // OTP
  static const String otpCheck = "/otp/check";
  static const String otpForgotPassword = "/otp/forgot-password";
  static const String otpVerify = "/otp/verify-otp";
  static const String otpResetPassword = "/otp/reset-password";
}