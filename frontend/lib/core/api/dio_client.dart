import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'auth_interceptor.dart';

class DioClient {
  DioClient._internal();

  static const String baseUrl = "http://10.248.171.223:8000";
  static final DioClient _instance = DioClient._internal();

  factory DioClient() => _instance;

  late final Dio dio = _createDio();

  Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
      ),
    );

    // AuthInterceptor handles token attachment and 401 errors
    dio.interceptors.add(AuthInterceptor());

    // Logging interceptor for debugging
    dio.interceptors.add(
      PrettyDioLogger(
        request: true,
        requestBody: true,
        responseBody: true,
        error: true,
      ),
    );

    return dio;
  }
}
