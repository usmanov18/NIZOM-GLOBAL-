// ============================================================
// EXCEPTIONS - Xatoliklar
// Data qatlamida ishlatiladi
// ============================================================

class ServerException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ServerException({
    required this.message,
    this.statusCode,
    this.data,
  });

  @override
  String toString() => 'ServerException: $message ($statusCode)';
}

class CacheException implements Exception {
  final String message;

  CacheException({required this.message});

  @override
  String toString() => 'CacheException: $message';
}

class NetworkException implements Exception {
  final String message;

  NetworkException({required this.message});

  @override
  String toString() => 'NetworkException: $message';
}

class AuthException implements Exception {
  final String message;
  final int? statusCode;

  AuthException({required this.message, this.statusCode});

  @override
  String toString() => 'AuthException: $message';
}

class ValidationException implements Exception {
  final String message;
  final Map<String, String>? errors;

  ValidationException({required this.message, this.errors});

  @override
  String toString() => 'ValidationException: $message';
}

class TimeoutException implements Exception {
  final String message;

  TimeoutException({this.message = 'Vaqt tugadi'});

  @override
  String toString() => 'TimeoutException: $message';
}

class FormatException implements Exception {
  final String message;

  FormatException({this.message = 'Format xatosi'});

  @override
  String toString() => 'FormatException: $message';
}

class PermissionException implements Exception {
  final String message;

  PermissionException({required this.message});

  @override
  String toString() => 'PermissionException: $message';
}

class LocationException implements Exception {
  final String message;

  LocationException({required this.message});

  @override
  String toString() => 'LocationException: $message';
}

class SyncException implements Exception {
  final String message;
  final String? system;

  SyncException({required this.message, this.system});

  @override
  String toString() => 'SyncException: $message ($system)';
}
