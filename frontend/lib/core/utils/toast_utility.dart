import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

/// A utility class for showing consistent toast messages across the app.
class ToastUtility {
  /// Shows a success toast message.
  static void showSuccess(String message) {
    _showToast(message, Colors.green);
  }

  /// Shows an error toast message.
  static void showError(String message) {
    _showToast(message, Colors.red);
  }

  /// Shows a warning toast message.
  static void showWarning(String message) {
    _showToast(message, Colors.orange);
  }

  /// Shows an info toast message.
  static void showInfo(String message) {
    _showToast(message, Colors.blue);
  }

  /// Shows a loading toast message.
  static void showLoading(String message) {
    _showToast(message, Colors.grey);
  }

  /// Internal method to show a toast with customizable background color.
  static void _showToast(String message, Color backgroundColor) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: backgroundColor,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  /// Shows a dismissible snackbar that can be swiped away in either direction.
  /// Returns a function to call to show the snackbar.
  static void showDismissibleToast(
    BuildContext context, {
    required String message,
    required ToastType type,
    VoidCallback? onDismissed,
    Duration duration = const Duration(seconds: 3),
  }) {
    final color = _getColorForType(type);
    final icon = _getIconForType(type);

    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Text(message, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
      backgroundColor: color,
      duration: duration,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
      dismissDirection: DismissDirection.horizontal,
      action: SnackBarAction(
        label: 'Dismiss',
        textColor: Colors.white,
        onPressed: () {
          if (onDismissed != null) {
            onDismissed();
          }
        },
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar).closed.then((reason) {
      if (onDismissed != null && reason != SnackBarClosedReason.action) {
        onDismissed();
      }
    });
  }

  /// Shows a loading dismissible toast
  static void showLoadingDismissibleToast(
    BuildContext context, {
    required String message,
    VoidCallback? onDismissed,
  }) {
    showDismissibleToast(
      context,
      message: message,
      type: ToastType.loading,
      onDismissed: onDismissed,
    );
  }

  /// Shows a success dismissible toast
  static void showSuccessDismissibleToast(
    BuildContext context, {
    required String message,
    VoidCallback? onDismissed,
  }) {
    showDismissibleToast(
      context,
      message: message,
      type: ToastType.success,
      onDismissed: onDismissed,
    );
  }

  /// Shows an error dismissible toast
  static void showErrorDismissibleToast(
    BuildContext context, {
    required String message,
    VoidCallback? onDismissed,
  }) {
    showDismissibleToast(
      context,
      message: message,
      type: ToastType.error,
      onDismissed: onDismissed,
    );
  }

  static Color _getColorForType(ToastType type) {
    switch (type) {
      case ToastType.success:
        return Colors.green;
      case ToastType.error:
        return Colors.red;
      case ToastType.warning:
        return Colors.orange;
      case ToastType.info:
        return Colors.blue;
      case ToastType.loading:
        return Colors.grey;
    }
  }

  static IconData _getIconForType(ToastType type) {
    switch (type) {
      case ToastType.success:
        return Icons.check_circle;
      case ToastType.error:
        return Icons.error;
      case ToastType.warning:
        return Icons.warning;
      case ToastType.info:
        return Icons.info;
      case ToastType.loading:
        return Icons.hourglass_empty;
    }
  }
}

/// Enum for toast types
enum ToastType { success, error, warning, info, loading }
