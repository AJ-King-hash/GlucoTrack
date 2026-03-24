import 'package:flutter/foundation.dart';

/// Simple logging utility for debugging and monitoring
class Logger {
  Logger._();

  static bool _enabled = true;
  static LogLevel _minLevel = LogLevel.debug;

  /// Enable or disable logging
  static void setEnabled(bool enabled) {
    _enabled = enabled;
  }

  /// Set minimum log level
  static void setMinLevel(LogLevel level) {
    _minLevel = level;
  }

  /// Log a debug message
  static void debug(
    String message, {
    String tag = 'APP',
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(
      LogLevel.debug,
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log an info message
  static void info(
    String message, {
    String tag = 'APP',
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(
      LogLevel.info,
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log a warning message
  static void warning(
    String message, {
    String tag = 'APP',
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(
      LogLevel.warning,
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log an error message
  static void error(
    String message, {
    String tag = 'APP',
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(
      LogLevel.error,
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log a fatal error message
  static void fatal(
    String message, {
    String tag = 'APP',
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(
      LogLevel.fatal,
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void _log(
    LogLevel level,
    String message, {
    required String tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!_enabled || level.index < _minLevel.index) {
      return;
    }

    final timestamp = DateTime.now().toIso8601String();
    final levelStr = level.name.toUpperCase();
    final buffer = StringBuffer('[$timestamp] [$levelStr] [$tag] $message');

    if (error != null) {
      buffer.write('\nError: $error');
    }

    if (stackTrace != null) {
      buffer.write('\nStackTrace: $stackTrace');
    }

    if (kDebugMode) {
      debugPrint(buffer.toString());
    }
  }
}

/// Log levels in order of severity
enum LogLevel { debug, info, warning, error, fatal }

/// Convenience function for quick logging
void log(
  String message, {
  String tag = 'APP',
  LogLevel level = LogLevel.debug,
}) {
  switch (level) {
    case LogLevel.debug:
      Logger.debug(message, tag: tag);
      break;
    case LogLevel.info:
      Logger.info(message, tag: tag);
      break;
    case LogLevel.warning:
      Logger.warning(message, tag: tag);
      break;
    case LogLevel.error:
      Logger.error(message, tag: tag);
      break;
    case LogLevel.fatal:
      Logger.fatal(message, tag: tag);
      break;
  }
}
