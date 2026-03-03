
import 'package:dio/dio.dart';
import '../utils/source_storage_service.dart';


class AuthInterceptor extends Interceptor {
  final VoidCallback? onUnauthorized;

  AuthInterceptor({this.onUnauthorized});

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await SecureStorageService.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers["Authorization"] = "Bearer $token";
    }
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      await SecureStorageService.deleteToken();
      onUnauthorized?.call();
    }
    super.onError(err, handler);
  }
}

typedef VoidCallback = void Function();