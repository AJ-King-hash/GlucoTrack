//for handle and display error message to user

import 'package:dio/dio.dart';
import 'package:untitled10/core/api/api_error.dart';

class ApiExceptions {
  static ApiError handleError(DioException error) {
    final statusCode = error.response?.statusCode;
    final data = error.response?.data;
    if (data is Map<String, dynamic> && data['message'] != null) {
      return ApiError(message: data['message'], statusCode: statusCode);
    }
    print(statusCode);
    print(data);
    if (statusCode == 302) {
      return ApiError(message: "This email already taken");
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return ApiError(message: "Bad Connection");
      case DioExceptionType.badResponse:
        return ApiError(message: error.toString());
      case DioExceptionType.cancel:
        return ApiError(message: "Request Cancelled");
      case DioExceptionType.connectionError:
        return ApiError(message: "No Internet Connection");
      case DioExceptionType.sendTimeout:
        return ApiError(message: "Request Timeout");
      case DioExceptionType.receiveTimeout:
        return ApiError(message: "Response Timeout");
      default:
        return ApiError(message: "SomeThing Went Wrong");
    }
  }
}
