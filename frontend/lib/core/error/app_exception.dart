/// Base exception class for application-specific errors
class AppException implements Exception {
  final String message;
  final String? code;
  final StackTrace? stackTrace;
  final dynamic originalError;

  const AppException({
    required this.message,
    this.code,
    this.stackTrace,
    this.originalError,
  });

  @override
  String toString() {
    final buffer = StringBuffer('AppException: $message');
    if (code != null) {
      buffer.write(' (code: $code)');
    }
    if (originalError != null) {
      buffer.write('\nOriginal error: $originalError');
    }
    return buffer.toString();
  }
}

/// Exception thrown when server returns an error
class ServerException extends AppException {
  final int? statusCode;

  const ServerException({
    required super.message,
    this.statusCode,
    super.code,
    super.stackTrace,
    super.originalError,
  });

  @override
  String toString() {
    final buffer = StringBuffer('ServerException: $message');
    if (statusCode != null) {
      buffer.write(' (status: $statusCode)');
    }
    if (code != null) {
      buffer.write(' (code: $code)');
    }
    return buffer.toString();
  }
}

/// Exception thrown when cache operations fail
class CacheException extends AppException {
  const CacheException({
    required super.message,
    super.code,
    super.stackTrace,
    super.originalError,
  });

  @override
  String toString() => 'CacheException: $message';
}

/// Exception thrown when network operations fail
class NetworkException extends AppException {
  const NetworkException({
    required super.message,
    super.code,
    super.stackTrace,
    super.originalError,
  });

  @override
  String toString() => 'NetworkException: $message';
}

/// Exception thrown when user is unauthorized
class UnauthorizedException extends AppException {
  const UnauthorizedException({
    required super.message,
    super.code,
    super.stackTrace,
    super.originalError,
  });

  @override
  String toString() => 'UnauthorizedException: $message';
}

/// Exception thrown when validation fails
class ValidationException extends AppException {
  final Map<String, List<String>>? fieldErrors;

  const ValidationException({
    required super.message,
    this.fieldErrors,
    super.code,
    super.stackTrace,
    super.originalError,
  });

  @override
  String toString() {
    final buffer = StringBuffer('ValidationException: $message');
    if (fieldErrors != null && fieldErrors!.isNotEmpty) {
      buffer.write('\nField errors: $fieldErrors');
    }
    return buffer.toString();
  }
}

/// Exception thrown when a resource is not found
class NotFoundException extends AppException {
  const NotFoundException({
    required super.message,
    super.code,
    super.stackTrace,
    super.originalError,
  });

  @override
  String toString() => 'NotFoundException: $message';
}

/// Exception thrown when request times out
class TimeoutException extends AppException {
  const TimeoutException({
    required super.message,
    super.code,
    super.stackTrace,
    super.originalError,
  });

  @override
  String toString() => 'TimeoutException: $message';
}
