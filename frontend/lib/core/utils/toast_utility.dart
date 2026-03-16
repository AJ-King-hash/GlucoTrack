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
}
