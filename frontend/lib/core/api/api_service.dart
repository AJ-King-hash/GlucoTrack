import 'package:dio/dio.dart';
import 'package:untitled10/core/api/dio_client.dart';
import 'package:untitled10/core/api/end_point.dart';
import 'package:untitled10/core/errors/failure.dart';
import 'package:untitled10/core/utils/either.dart';

/// Unified API Service for GlucoTrack Application
///
/// This service provides a consistent interface for all backend API calls
/// using the ResponseModel pattern with Either for error handling.
class ApiService {
  final Dio _dio = DioClient().dio;

  Future<Either<Failure, T>> _handleRequest<T>(
    Future<Response<dynamic>> request,
    T Function(dynamic data) converter,
  ) async {
    try {
      final response = await request;
      return Right(converter(response.data));
    } on DioException catch (e) {
      return Left(_mapError(e));
    } catch (e) {
      return Left(UnknownFailure(message: "Unexpected error"));
    }
  }

  Failure _mapError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return NetworkFailure(message: "Connection timeout. Please try again.");
    }

    final status = e.response?.statusCode;
    final message = e.response?.data?.toString() ?? "Network error";

    if (status == 422) return ValidationFailure(message: message, code: status);
    if (status == 401) {
      return UnauthorizedFailure(message: message, code: status);
    }
    if (status == 500) return ServerFailure(message: message, code: status);
    if (status == null) return NetworkFailure(message: "Network error");

    return ServerFailure(message: message, code: status);
  }

  // ================= AUTH =================

  Future<Either<Failure, dynamic>> login(Map<String, dynamic> body) =>
      _handleRequest(_dio.post(ApiEndpoints.login, data: body), (data) => data);

  Future<Either<Failure, dynamic>> logout() =>
      _handleRequest(_dio.post(ApiEndpoints.logout, data: {}), (data) => data);

  // ================= USER =================

  Future<Either<Failure, dynamic>> createUser(Map<String, dynamic> body) =>
      _handleRequest(_dio.post(ApiEndpoints.user, data: body), (data) => data);

  Future<Either<Failure, dynamic>> getUser() =>
      _handleRequest(_dio.get(ApiEndpoints.user), (data) => data);

  Future<Either<Failure, dynamic>> getUserById(int id) =>
      _handleRequest(_dio.get(ApiEndpoints.userById(id)), (data) => data);

  Future<Either<Failure, dynamic>> updateUser(Map<String, dynamic> body) =>
      _handleRequest(
        _dio.put(ApiEndpoints.userUpdate, data: body),
        (data) => data,
      );

  Future<Either<Failure, dynamic>> deleteUser() =>
      _handleRequest(_dio.delete(ApiEndpoints.userDelete), (data) => data);

  // ================= BOT - CONVERSATION =================

  Future<Either<Failure, dynamic>> createConversation(
    Map<String, dynamic> body,
  ) => _handleRequest(
    _dio.post(ApiEndpoints.conversation, data: body),
    (data) => data,
  );

  Future<Either<Failure, dynamic>> getConversation(int id) => _handleRequest(
    _dio.get(ApiEndpoints.conversationById(id)),
    (data) => data,
  );

  Future<Either<Failure, dynamic>> getAllConversations() =>
      _handleRequest(_dio.get(ApiEndpoints.allConversations), (data) => data);

  Future<Either<Failure, dynamic>> deleteConversation(int id) => _handleRequest(
    _dio.delete(ApiEndpoints.conversationById(id)),
    (data) => data,
  );

  // ================= BOT - MESSAGE =================

  Future<Either<Failure, dynamic>> createMessage(Map<String, dynamic> body) =>
      _handleRequest(
        _dio.post(ApiEndpoints.message, data: body),
        (data) => data,
      );

  Future<Either<Failure, dynamic>> getMessages(int conversationId) =>
      _handleRequest(
        _dio.get(ApiEndpoints.allMessages(conversationId)),
        (data) => data,
      );

  // ================= RISK =================
  /// Note: Risk endpoints use current authenticated user from token.
  /// The user ID is extracted from the JWT token on the backend.

  Future<Either<Failure, dynamic>> createRisk(Map<String, dynamic> body) =>
      _handleRequest(_dio.post(ApiEndpoints.risk, data: body), (data) => data);

  Future<Either<Failure, dynamic>> getRisk() =>
      _handleRequest(_dio.get(ApiEndpoints.risk), (data) => data);

  Future<Either<Failure, dynamic>> updateRisk(Map<String, dynamic> body) =>
      _handleRequest(_dio.put(ApiEndpoints.risk, data: body), (data) => data);

  Future<Either<Failure, dynamic>> deleteRisk() =>
      _handleRequest(_dio.delete(ApiEndpoints.risk), (data) => data);

  // ================= MEAL =================
  /// Note: Some meal endpoints use current authenticated user from token.

  Future<Either<Failure, dynamic>> createMeal(Map<String, dynamic> body) =>
      _handleRequest(_dio.post(ApiEndpoints.meal, data: body), (data) => data);

  Future<Either<Failure, dynamic>> getMeal(int id) =>
      _handleRequest(_dio.get(ApiEndpoints.mealById(id)), (data) => data);

  Future<Either<Failure, dynamic>> getAllMeals() =>
      _handleRequest(_dio.get(ApiEndpoints.allMeals), (data) => data);

  // ================= ANALYSIS =================
  /// Note: Analysis endpoints use current authenticated user from token.
  /// The user ID is extracted from the JWT token on the backend.

  Future<Either<Failure, dynamic>> getAllAnalysis() =>
      _handleRequest(_dio.get(ApiEndpoints.allAnalysis), (data) => data);

  Future<Either<Failure, dynamic>> deleteAnalysis(int id) => _handleRequest(
    _dio.delete(ApiEndpoints.deleteAnalysis(id)),
    (data) => data,
  );

  // ================= OTP =================

  Future<Either<Failure, dynamic>> otpCheck() =>
      _handleRequest(_dio.get(ApiEndpoints.otpCheck), (data) => data);

  Future<Either<Failure, dynamic>> forgotPassword(Map<String, dynamic> body) =>
      _handleRequest(
        _dio.post(ApiEndpoints.otpForgotPassword, data: body),
        (data) => data,
      );

  Future<Either<Failure, dynamic>> verifyOtp(Map<String, dynamic> body) =>
      _handleRequest(
        _dio.post(ApiEndpoints.otpVerify, data: body),
        (data) => data,
      );

  Future<Either<Failure, dynamic>> resetPassword(Map<String, dynamic> body) =>
      _handleRequest(
        _dio.post(ApiEndpoints.otpResetPassword, data: body),
        (data) => data,
      );

  // ================= NOTIFICATIONS =================

  /// Update reminder times for the authenticated user
  /// [glucoTime] - Time for glucose check reminder (format: "HH:mm", e.g., "08:00")
  /// [medicineTime] - Time for medicine reminder (format: "HH:mm", e.g., "20:00")
  /// [timezone] - User's timezone (e.g., "Asia/Riyadh")
  Future<Either<Failure, dynamic>> updateReminders({
    String? glucoTime,
    String? medicineTime,
    String? timezone,
  }) {
    final body = <String, dynamic>{};
    if (glucoTime != null) body['gluco_time'] = glucoTime;
    if (medicineTime != null) body['medicine_time'] = medicineTime;
    if (timezone != null) body['timezone'] = timezone;

    return _handleRequest(
      _dio.put(ApiEndpoints.updateReminders, data: body),
      (data) => data,
    );
  }

  /// Update FCM token for push notifications
  Future<Either<Failure, dynamic>> updateFcmToken(String token) =>
      _handleRequest(
        _dio.post(ApiEndpoints.updateFcmToken, data: {'fcm_token': token}),
        (data) => data,
      );

  /// Trigger reminders manually (for testing)
  Future<Either<Failure, dynamic>> triggerReminders() =>
      _handleRequest(_dio.get(ApiEndpoints.triggerReminders), (data) => data);
}
