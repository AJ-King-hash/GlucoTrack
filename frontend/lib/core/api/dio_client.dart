import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:untitled10/core/api/auth_interceptor.dart';
import 'package:untitled10/core/services/navigation_service.dart';

class DioClient {
  DioClient._internal();

  // Use String.fromEnvironment for build-time configuration
  // Example: flutter build --dart-define=BASE_URL=http://localhost:8000
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://192.168.34.73:8000',
  );
  static final DioClient _instance = DioClient._internal();

  factory DioClient() => _instance;
  late final Dio dio = _createDio();

  Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 15),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
      ),
    );

    // AuthInterceptor handles token attachment and 401 errors
    dio.interceptors.add(
      AuthInterceptor(navigationService: NavigationService()),
    );

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
