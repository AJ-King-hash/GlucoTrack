import 'package:dio/dio.dart';
import 'package:untitled10/core/api/dio_client.dart';
import 'package:untitled10/core/api/end_point.dart';
import 'package:untitled10/core/errors/failure.dart';
import 'package:untitled10/core/utils/either.dart';

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
      _handleRequest(_dio.post("/logout", data: {}), (data) => data);

  // ================= USER =================

  Future<Either<Failure, dynamic>> createUser(Map<String, dynamic> body) =>
      _handleRequest(_dio.post(ApiEndpoints.user, data: body), (data) => data);

  Future<Either<Failure, dynamic>> getUser() =>
      _handleRequest(_dio.get("/user"), (data) => data);

  Future<Either<Failure, dynamic>> updateUser(Map<String, dynamic> body) =>
      _handleRequest(_dio.put("/user/update", data: body), (data) => data);

  Future<Either<Failure, dynamic>> getUserById(int id) =>
      _handleRequest(_dio.get(ApiEndpoints.userById(id)), (data) => data);

  // ================= BOT =================

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
  /// Note: Risk endpoints use current authenticated user from token

  Future<Either<Failure, dynamic>> createRisk(Map<String, dynamic> body) =>
      _handleRequest(_dio.post(ApiEndpoints.risk, data: body), (data) => data);

  Future<Either<Failure, dynamic>> getRisk() =>
      _handleRequest(_dio.get(ApiEndpoints.risk), (data) => data);

  Future<Either<Failure, dynamic>> updateRisk(Map<String, dynamic> body) =>
      _handleRequest(_dio.put(ApiEndpoints.risk, data: body), (data) => data);

  Future<Either<Failure, dynamic>> deleteRisk() =>
      _handleRequest(_dio.delete(ApiEndpoints.risk), (data) => data);

  // ================= MEAL =================

  Future<Either<Failure, dynamic>> createMeal(Map<String, dynamic> body) =>
      _handleRequest(_dio.post(ApiEndpoints.meal, data: body), (data) => data);

  Future<Either<Failure, dynamic>> getMeal(int id) =>
      _handleRequest(_dio.get(ApiEndpoints.mealById(id)), (data) => data);

  // ================= ANALYSIS =================
  /// Note: Analysis endpoints use current authenticated user from token

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

  // ================= MEAL =================
  /// Note: Meal endpoints use current authenticated user from token

  Future<Either<Failure, dynamic>> getAllMeals() =>
      _handleRequest(_dio.get(ApiEndpoints.allMeals), (data) => data);

  // ================= USER =================

  Future<Either<Failure, dynamic>> deleteUser() =>
      _handleRequest(_dio.delete(ApiEndpoints.userDelete), (data) => data);
}
