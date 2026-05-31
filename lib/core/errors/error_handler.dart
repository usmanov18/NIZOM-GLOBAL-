import 'failures.dart';

class ErrorHandler {
  static Failure handleException(Exception error) => handle(error);

  static Failure handle(dynamic error) {
    final str = error.toString().toLowerCase();
    if (str.contains('socketexception')) {
      return const NetworkFailure(message: 'Internet ulanishini tekshiring');
    }
    if (str.contains('401')) {
      return const AuthFailure(message: 'Sessiya muddati tugadi. Qayta kiring');
    }
    if (str.contains('500')) {
      return const ServerFailure(message: 'Serverda texnik ishlar ketmoqda');
    }
    return ServerFailure(message: 'Kutilmagan xato: $error');
  }
}
