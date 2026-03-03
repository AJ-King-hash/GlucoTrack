import 'package:dio/dio.dart';

String handleError(DioException e) {
  if (e.response != null) {
    // تحقق من وجود بيانات في الـ response
    final responseData = e.response!.data;

    if (responseData is Map<String, dynamic>) {
      // إذا كان الـ response يحتوي على تفاصيل خطأ
      if (responseData.containsKey('detail')) {
        final detail = responseData['detail'];

        if (detail is String) {
          return detail;
        } else if (detail is List) {
          // معالجة قائمة الأخطاء
          return detail.map((error) {
            if (error is Map<String, dynamic>) {
              return error['msg'] ?? 'Validation error';
            }
            return error.toString();
          }).join('\n');
        } else if (detail is Map<String, dynamic>) {
          return detail['msg'] ?? 'Validation error';
        }
      }
    }

    // رسائل خطأ عامة بناءً على status code
    switch (e.response!.statusCode) {
      case 400:
        return 'Bad request. Please check your data.';
      case 401:
        return 'Unauthorized. Please login again.';
      case 403:
        return 'Forbidden. You don\'t have permission.';
      case 404:
        return 'Resource not found.';
      case 422:
        return 'Validation error. Please check your input.';
      case 500:
        return 'Internal server error. Please try again later.';
      default:
        return 'An error occurred: ${e.response!.statusCode}';
    }
  } else {
    // أخطاء الشبكة
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout. Please check your internet.';
      case DioExceptionType.sendTimeout:
        return 'Send timeout. Please try again.';
      case DioExceptionType.receiveTimeout:
        return 'Receive timeout. Please try again.';
      case DioExceptionType.badCertificate:
        return 'Bad certificate. Please check your connection.';
      case DioExceptionType.badResponse:
        return 'Bad response from server.';
      case DioExceptionType.cancel:
        return 'Request cancelled.';
      case DioExceptionType.connectionError:
        return 'Connection error. Please check your internet.';
      case DioExceptionType.unknown:
        return 'Unknown error: ${e.message}';
    }
  }
}
