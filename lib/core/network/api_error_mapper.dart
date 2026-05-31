import 'package:dio/dio.dart';

import '../errors/failures.dart';

class ApiErrorMapper {
  ApiErrorMapper._();

  static Failure fromDio(DioException error,
      {String defaultMessage = 'API xatolik'}) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutFailure();
      case DioExceptionType.connectionError:
        return const NetworkFailure(
            message: 'Internet yoki server ulanish xatosi');
      case DioExceptionType.badResponse:
        return _fromResponse(error.response, defaultMessage: defaultMessage);
      case DioExceptionType.cancel:
        return const ServerFailure(message: 'So‘rov bekor qilindi');
      case DioExceptionType.badCertificate:
        return const ServerFailure(message: 'SSL sertifikat xatosi');
      case DioExceptionType.unknown:
        return ServerFailure(message: error.message ?? defaultMessage);
    }
  }

  static Failure _fromResponse(Response? response,
      {required String defaultMessage}) {
    final status = response?.statusCode;
    final message = _extractMessage(response?.data) ?? defaultMessage;
    switch (status) {
      case 400:
        return BadRequestFailure(message: message);
      case 401:
        return const UnauthorizedFailure();
      case 403:
        return const ForbiddenFailure();
      case 404:
        return NotFoundFailure(resource: message);
      case 409:
        return ConflictFailure(message: message);
      case 422:
        return ValidationFailure(
            message: message, errors: _extractValidationErrors(response?.data));
      case 500:
      case 502:
      case 503:
      case 504:
        return ServerFailure(message: message, statusCode: status);
      default:
        return ServerFailure(message: message, statusCode: status);
    }
  }

  static String? _extractMessage(dynamic data) {
    if (data is Map) {
      return data['message']?.toString() ??
          data['error']?.toString() ??
          data['detail']?.toString();
    }
    if (data is String && data.isNotEmpty) return data;
    return null;
  }

  static Map<String, String>? _extractValidationErrors(dynamic data) {
    if (data is! Map) return null;
    final errors = data['errors'];
    if (errors is! Map) return null;
    return errors
        .map((key, value) => MapEntry(key.toString(), value.toString()));
  }
}
