import 'package:flutter/material.dart';
import 'package:glucotrack/core/routes/app_routes.dart';

/// A service that handles navigation without requiring a BuildContext.
///
/// This service uses a global navigator key to manage navigation, making it
/// possible to navigate from places where context is not available (like interceptors
/// or background services).
class NavigationService {
  /// The singleton instance of the navigation service.
  static final NavigationService _instance = NavigationService._internal();

  factory NavigationService() => _instance;

  NavigationService._internal();

  /// Global key for the navigator state.
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Gets the current BuildContext from the navigator key.
  BuildContext? get currentContext => navigatorKey.currentContext;

  /// Navigates to the login page, replacing the current route stack.
  ///
  /// This ensures that the user can't navigate back to the previous screen after
  /// being logged out.
  void navigateToLogin() {
    if (navigatorKey.currentState != null) {
      navigatorKey.currentState!.pushNamedAndRemoveUntil(
        AppRoutes.login,
        (Route<dynamic> route) => false, // Remove all routes from stack
      );
    }
  }

  /// Navigates to a specific route with optional arguments.
  Future<T?>? navigateTo<T>(String routeName, {dynamic arguments}) {
    if (navigatorKey.currentState != null) {
      return navigatorKey.currentState!.pushNamed<T>(
        routeName,
        arguments: arguments,
      );
    }
    return null;
  }

  /// Pops the current route from the navigation stack.
  void pop() {
    if (navigatorKey.currentState != null &&
        navigatorKey.currentState!.canPop()) {
      navigatorKey.currentState!.pop();
    }
  }
}
