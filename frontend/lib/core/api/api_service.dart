import 'package:dio/dio.dart';
import 'package:glucotrack/core/api/dio_client.dart';
import 'package:glucotrack/core/api/end_point.dart';
import 'package:glucotrack/core/errors/failure.dart';
import 'package:glucotrack/core/utils/either.dart';

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
      return NetworkFailure(
        message:
            "Connection timeout. Please check your internet connection and try again.",
      );
    }

    if (e.type == DioExceptionType.connectionError) {
      return NetworkFailure(
        message:
            "Unable to connect to server. Please check your internet connection.",
      );
    }

    final status = e.response?.statusCode;
    final dynamic responseData = e.response?.data;
    String message;

    // Try to extract meaningful error message from response
    if (responseData != null) {
      if (responseData is Map) {
        message =
            responseData['detail']?.toString() ??
            responseData['message']?.toString() ??
            responseData.toString();
      } else {
        message = responseData.toString();
      }
    } else {
      message = "An unexpected error occurred";
    }

    if (status == 422) {
      return ValidationFailure(
        message: _formatValidationError(message),
        code: status,
      );
    }
    if (status == 401) {
      // Preserve specific error message if available (e.g., "Incorrect old password")
      // Otherwise use generic message
      return UnauthorizedFailure(
        message:
            message != "An unexpected error occurred"
                ? message
                : "Session expired. Please login again.",
        code: status,
      );
    }
    if (status == 403) {
      return UnauthorizedFailure(
        message: "You don't have permission to perform this action.",
        code: status,
      );
    }
    if (status == 404) {
      return ServerFailure(
        message: "The requested resource was not found.",
        code: status,
      );
    }
    if (status == 500) {
      return ServerFailure(
        message: "Server error. Please try again later.",
        code: status,
      );
    }
    if (status == null) {
      return NetworkFailure(
        message: "Network error. Please check your connection.",
      );
    }

    return ServerFailure(message: message, code: status);
  }

  String _formatValidationError(String message) {
    // Clean up validation error messages
    if (message.contains('detail=')) {
      final regex = RegExp(r'"detail":\s*"([^"]+)"');
      final match = regex.firstMatch(message);
      if (match != null) {
        return match.group(1) ?? message;
      }
    }
    return message;
  }

  // ================= AUTH =================

  Future<Either<Failure, dynamic>> login(Map<String, dynamic> body) {
    // Convert body to form-urlencoded format
    final formData = FormData.fromMap(body);
    return _handleRequest(
      _dio.post(
        ApiEndpoints.login,
        data: formData,
        options: Options(contentType: Headers.formUrlEncodedContentType),
      ),
      (data) => data,
    );
  }

  Future<Either<Failure, dynamic>> logout() =>
      _handleRequest(_dio.delete(ApiEndpoints.logout), (data) => data);

  // ================= USER =================

  Future<Either<Failure, dynamic>> createUser(Map<String, dynamic> body) =>
      _handleRequest(_dio.post(ApiEndpoints.user, data: body), (data) => data);

  Future<Either<Failure, dynamic>> getUser(int userId) =>
      _handleRequest(_dio.get(ApiEndpoints.userById(userId)), (data) => data);

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

  /// Get all conversations with pagination and search
  Future<Either<Failure, dynamic>> getAllConversations() {
    return _handleRequest(
      _dio.get(ApiEndpoints.allConversations),
      (data) => data,
    );
  }

  /// Get total count of conversations for pagination
  Future<Either<Failure, dynamic>> getConversationCount() =>
      _handleRequest(_dio.get(ApiEndpoints.conversationCount), (data) => data);

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

  /// Get messages with pagination
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

  /// Get the most recent meal for the authenticated user
  /// Returns the first meal from the list (most recent) or null if no meals
  Future<Either<Failure, dynamic>> getLastMeal() async {
    final result = await _handleRequest(
      _dio.get(ApiEndpoints.allMeals),
      (data) => data,
    );

    // Return first meal if available
    return result.fold((failure) => Left(failure), (data) {
      final meals = data as List<dynamic>;
      if (meals.isEmpty) return const Right(null);
      return Right(meals.first); // Most recent (first in ordered list)
    });
  }

  Future<Either<Failure, dynamic>> updateMeal(
    int id,
    Map<String, dynamic> body,
  ) => _handleRequest(
    _dio.put(ApiEndpoints.mealById(id), data: body),
    (data) => data,
  );

  // ================= ANALYSIS =================
  /// Note: Analysis endpoints use current authenticated user from token.
  /// The user ID is extracted from the JWT token on the backend.

  /// Get all analysis with pagination, search, and filtering
  Future<Either<Failure, dynamic>> getAllAnalysis({
    int page = 1,
    int limit = 10,
    String? search,
    String? sortBy,
    String sortOrder = 'desc',
    String? riskFilter,
  }) {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
      'sort_by': sortBy ?? 'analysed_at',
      'sort_order': sortOrder,
    };
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }
    if (riskFilter != null && riskFilter.isNotEmpty) {
      queryParams['risk_filter'] = riskFilter;
    }

    return _handleRequest(
      _dio.get(ApiEndpoints.allAnalysis, queryParameters: queryParams),
      (data) => data,
    );
  }

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
