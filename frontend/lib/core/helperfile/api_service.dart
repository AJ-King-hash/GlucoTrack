import 'package:dio/dio.dart';
// CHANGE 'gluco_track' to the 'name' found in your pubspec.yaml
import 'package:untitled10/features/auth/data/models/response_model.dart';
import 'package:untitled10/core/helperfile/dio_client.dart';
import 'package:untitled10/core/api/end_point.dart';

class ApiService {
  final Dio _dio = DioClient().dio;

  Future<ResponseModel<T>> _handleRequest<T>(
    Future<Response<dynamic>> request,
    T Function(dynamic data) converter,
  ) async {
    try {
      final response = await request;
      // Static methods like .success and .failure require the import to work
      return ResponseModel.success(
        converter(response.data),
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return ResponseModel.failure(
        _mapError(e),
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ResponseModel.failure("Unexpected error");
    }
  }

  String _mapError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return "Connection timeout. Please try again.";
    }

    final status = e.response?.statusCode;

    if (status == 422) return "Validation error";
    if (status == 401) return "Unauthorized";

    return e.response?.data?.toString() ?? "Network error";
  }

  // ================= BOT =================

  Future<ResponseModel<dynamic>> createConversation(
    Map<String, dynamic> body,
  ) => _handleRequest(
    _dio.post(ApiEndpoints.conversation, data: body),
    (data) => data,
  );

  Future<ResponseModel<dynamic>> getConversation(int id) => _handleRequest(
    _dio.get(ApiEndpoints.conversationById(id)),
    (data) => data,
  );

  Future<ResponseModel<dynamic>> getAllConversations(int userId) =>
      _handleRequest(
        _dio.get(ApiEndpoints.allConversations(userId)),
        (data) => data,
      );

  Future<ResponseModel<dynamic>> deleteConversation(int id) => _handleRequest(
    _dio.delete(ApiEndpoints.conversationById(id)),
    (data) => data,
  );

  Future<ResponseModel<dynamic>> createMessage(Map<String, dynamic> body) =>
      _handleRequest(
        _dio.post(ApiEndpoints.message, data: body),
        (data) => data,
      );

  Future<ResponseModel<dynamic>> getMessages(int conversationId) =>
      _handleRequest(
        _dio.get(ApiEndpoints.allMessages(conversationId)),
        (data) => data,
      );

  // ================= RISK =================

  Future<ResponseModel<dynamic>> createRisk(Map<String, dynamic> body) =>
      _handleRequest(_dio.post(ApiEndpoints.risk, data: body), (data) => data);

  Future<ResponseModel<dynamic>> getRisk(int id) =>
      _handleRequest(_dio.get(ApiEndpoints.riskById(id)), (data) => data);

  Future<ResponseModel<dynamic>> updateRisk(
    int id,
    Map<String, dynamic> body,
  ) => _handleRequest(
    _dio.put(ApiEndpoints.riskById(id), data: body),
    (data) => data,
  );

  Future<ResponseModel<dynamic>> deleteRisk(int id) =>
      _handleRequest(_dio.delete(ApiEndpoints.riskById(id)), (data) => data);

  // ================= MEAL =================

  Future<ResponseModel<dynamic>> createMeal(Map<String, dynamic> body) =>
      _handleRequest(_dio.post(ApiEndpoints.meal, data: body), (data) => data);

  Future<ResponseModel<dynamic>> getMeal(int id) =>
      _handleRequest(_dio.get(ApiEndpoints.mealById(id)), (data) => data);

  // ================= ANALYSIS =================

  Future<ResponseModel<dynamic>> getAllAnalysis(int id, int userId) =>
      _handleRequest(
        _dio.get(
          ApiEndpoints.allAnalysis(id),
          queryParameters: {"user_id": userId},
        ),
        (data) => data,
      );

  Future<ResponseModel<dynamic>> deleteAnalysis(int id) => _handleRequest(
    _dio.delete(ApiEndpoints.deleteAnalysis(id)),
    (data) => data,
  );

  // ================= OTP =================

  Future<ResponseModel<dynamic>> otpCheck() =>
      _handleRequest(_dio.get(ApiEndpoints.otpCheck), (data) => data);

  Future<ResponseModel<dynamic>> forgotPassword(Map<String, dynamic> body) =>
      _handleRequest(
        _dio.post(ApiEndpoints.otpForgotPassword, data: body),
        (data) => data,
      );

  Future<ResponseModel<dynamic>> verifyOtp(Map<String, dynamic> body) =>
      _handleRequest(
        _dio.post(ApiEndpoints.otpVerify, data: body),
        (data) => data,
      );

  Future<ResponseModel<dynamic>> resetPassword(Map<String, dynamic> body) =>
      _handleRequest(
        _dio.post(ApiEndpoints.otpResetPassword, data: body),
        (data) => data,
      );
}
