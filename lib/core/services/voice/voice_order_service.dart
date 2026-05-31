import '../logger/app_logger.dart';

class VoiceOrderService {
  static Map<String, dynamic> parseCommand(String transcript) {
    AppLogger.i('🎤 Processing voice: $transcript');
    // 2026 NLP logic stub
    if (transcript.contains('qo\'sh') || transcript.contains('add')) {
      return {'action': 'add_to_cart', 'quantity': 10, 'product': 'unknown'};
    }
    return {'action': 'none'};
  }
}
