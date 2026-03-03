
class ResponseModel<T> {
  final bool success;
  final T? data;
  final String? message;
  final int? statusCode;

  const ResponseModel({
    required this.success,
    this.data,
    this.message,
    this.statusCode,
  });

  factory ResponseModel.success(T data, {int? statusCode}) {
    return ResponseModel(
      success: true,
      data: data,
      statusCode: statusCode,
    );
  }

  factory ResponseModel.failure(String message, {int? statusCode}) {
    return ResponseModel(
      success: false,
      message: message,
      statusCode: statusCode,
    );
  }
}