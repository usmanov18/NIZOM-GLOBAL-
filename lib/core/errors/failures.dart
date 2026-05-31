import 'package:equatable/equatable.dart';

// ============================================================
// FAILURES - Domain qatlamida ishlatiladi
// Barcha xatoliklar uchun
// ============================================================

abstract class Failure extends Equatable {
  final String message;
  final int? statusCode;

  const Failure({required this.message, this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}

// ============ SERVER ============

class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.statusCode});
}

class TimeoutFailure extends Failure {
  const TimeoutFailure() : super(message: 'Serverga ulanish vaqti tugadi');
}

class BadRequestFailure extends Failure {
  const BadRequestFailure({required super.message}) : super(statusCode: 400);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure()
      : super(message: 'Avtorizatsiya talab qilinadi', statusCode: 401);
}

class ForbiddenFailure extends Failure {
  const ForbiddenFailure() : super(message: 'Ruxsat yo\'q', statusCode: 403);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure({String? resource})
      : super(message: '${resource ?? "Ma'lumot"} topilmadi', statusCode: 404);
}

class ConflictFailure extends Failure {
  const ConflictFailure({required super.message}) : super(statusCode: 409);
}

class ValidationFailure extends Failure {
  final Map<String, String>? errors;

  const ValidationFailure({required super.message, this.errors});
}

// ============ NETWORK ============

class NetworkFailure extends Failure {
  const NetworkFailure({String? message})
      : super(message: message ?? 'Internetga ulanmagan');
}

class ConnectionFailure extends Failure {
  const ConnectionFailure() : super(message: 'Ulanish xatosi');
}

// ============ CACHE ============

class CacheFailure extends Failure {
  const CacheFailure({String? message})
      : super(message: message ?? 'Kesh xatosi');
}

// ============ AUTH ============

class AuthFailure extends Failure {
  const AuthFailure({required super.message, super.statusCode});
}

class TokenExpiredFailure extends Failure {
  const TokenExpiredFailure() : super(message: 'Sessiya muddati tugadi');
}

class InvalidCredentialsFailure extends Failure {
  const InvalidCredentialsFailure()
      : super(message: 'Login yoki parol noto\'g\'ri');
}

class AccountLockedFailure extends Failure {
  const AccountLockedFailure() : super(message: 'Hisob bloklangan');
}

class OTPFailure extends Failure {
  const OTPFailure({required super.message});
}

class BiometricFailure extends Failure {
  const BiometricFailure({required super.message});
}

// ============ LOCATION ============

class LocationFailure extends Failure {
  const LocationFailure({required super.message});
}

class LocationPermissionFailure extends Failure {
  const LocationPermissionFailure()
      : super(message: 'Lokatsiya ruxsati berilmagan');
}

// ============ SYNC ============

class SyncFailure extends Failure {
  final String? system;

  const SyncFailure({required super.message, this.system});
}

class OneCSyncFailure extends SyncFailure {
  const OneCSyncFailure({required String message})
      : super(message: '1C: $message', system: '1C');
}

class SAPSyncFailure extends SyncFailure {
  const SAPSyncFailure({required String message})
      : super(message: 'SAP: $message', system: 'SAP');
}

// ============ ORDER ============

class OrderFailure extends Failure {
  const OrderFailure({required super.message, super.statusCode});
}

class OrderNotFoundFailure extends Failure {
  const OrderNotFoundFailure() : super(message: 'Buyurtma topilmadi');
}

class InsufficientStockFailure extends Failure {
  const InsufficientStockFailure({String? product})
      : super(message: '${product ?? "Mahsulot"} omborda yetarli emas');
}

class OrderLimitExceededFailure extends Failure {
  const OrderLimitExceededFailure() : super(message: 'Buyurtma limiti oshdi');
}

// ============ PAYMENT ============

class PaymentFailure extends Failure {
  const PaymentFailure({required super.message, super.statusCode});
}

class PaymentDeclinedFailure extends Failure {
  const PaymentDeclinedFailure() : super(message: 'To\'lov rad etildi');
}

// ============ UNKNOWN ============

class UnknownFailure extends Failure {
  const UnknownFailure() : super(message: 'Noma\'lum xatolik yuz berdi');
}
