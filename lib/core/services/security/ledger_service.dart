import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../logger/app_logger.dart';

class LedgerService {
  static String signOrder(String orderId, String payload) {
    final bytes = utf8.encode('$orderId:$payload:NIZOM_GLOBAL_SECRET_2026');
    final hash = sha256.convert(bytes);
    AppLogger.i('📜 Order $orderId signed. Hash: $hash');
    return hash.toString();
  }
}
