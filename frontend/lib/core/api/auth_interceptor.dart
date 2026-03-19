import 'package:dio/dio.dart';
import '../utils/source_storage_service.dart';
import '../services/navigation_service.dart';
import '../utils/toast_utility.dart';

class AuthInterceptor extends Interceptor {
  final NavigationService navigationService;

  AuthInterceptor({required this.navigationService});

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await SecureStorageService.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers["Authorization"] = "Bearer $token";
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      await SecureStorageService.clearAll();
      _handleUnauthorized();
    }
    super.onError(err, handler);
  }

  void _handleUnauthorized() {
    // Show a toast to inform the user that their session has expired
    if (navigationService.currentContext != null) {
      ToastUtility.showError('Session expired. Please login again.');
    }

    // Navigate to login page
    navigationService.navigateToLogin();
  }
}
