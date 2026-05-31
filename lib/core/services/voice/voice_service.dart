import 'dart:async';

// ============================================================
// VOICE SERVICE - Ovozli buyruqlar
// ============================================================

class VoiceService {
  static final VoiceService _instance = VoiceService._internal();
  factory VoiceService() => _instance;
  VoiceService._internal();

  bool _isListening = false;
  bool _isAvailable = false;

  final StreamController<VoiceCommand> _commandController =
      StreamController<VoiceCommand>.broadcast();
  final StreamController<String> _textController =
      StreamController<String>.broadcast();

  Stream<VoiceCommand> get commandStream => _commandController.stream;
  Stream<String> get textStream => _textController.stream;
  bool get isListening => _isListening;

  // ============ INIT ============

  Future<bool> initialize() async {
    try {
      _isAvailable = true;
      return true;
    } catch (e) {
      return false;
    }
  }

  // ============ LISTENING ============

  Future<void> startListening() async {
    if (!_isAvailable) return;

    _isListening = true;
  }

  Future<void> stopListening() async {
    _isListening = false;
  }

  /// Test/demo muhitida speech-to-text natijasini servisga uzatish.
  void simulateTranscript(String text) {
    if (text.trim().isEmpty) return;
    _textController.add(text);
    final command = parseCommand(text);
    if (command != null) {
      _commandController.add(command);
    }
  }

  // ============ COMMAND PARSING ============

  VoiceCommand? parseCommand(String text) {
    final lower = text.toLowerCase().trim();

    // Buyurtma yaratish
    if (lower.contains('buyurtma') || lower.contains('zakaz')) {
      return VoiceCommand(
        type: VoiceCommandType.createOrder,
        text: text,
        parameters: {},
      );
    }

    // Mijoz qidirish
    if (lower.contains('qidir') || lower.contains('izla')) {
      return VoiceCommand(
        type: VoiceCommandType.searchCustomer,
        text: text,
        parameters: {'query': _extractSearchQuery(lower)},
      );
    }

    // Hisobot
    if (lower.contains('hisobot') || lower.contains('report')) {
      return VoiceCommand(
        type: VoiceCommandType.showReport,
        text: text,
        parameters: {},
      );
    }

    // Navigatsiya
    if (lower.contains('navigatsiya') || lower.contains('yo\'nalish')) {
      return VoiceCommand(
        type: VoiceCommandType.startNavigation,
        text: text,
        parameters: {},
      );
    }

    // To'lov
    if (lower.contains('to\'lov') || lower.contains('payment')) {
      return VoiceCommand(
        type: VoiceCommandType.collectPayment,
        text: text,
        parameters: {},
      );
    }

    // Xabar
    if (lower.contains('xabar') || lower.contains('message')) {
      return VoiceCommand(
        type: VoiceCommandType.sendMessage,
        text: text,
        parameters: {},
      );
    }

    return null;
  }

  String _extractSearchQuery(String text) {
    // "qidirish Coca-Cola" → "Coca-Cola"
    final patterns = ['qidir', 'izla', 'qidirish', 'search'];
    for (final pattern in patterns) {
      final index = text.indexOf(pattern);
      if (index != -1) {
        return text.substring(index + pattern.length).trim();
      }
    }
    return text;
  }

  void dispose() {
    _commandController.close();
    _textController.close();
  }
}

enum VoiceCommandType {
  createOrder,
  searchCustomer,
  searchProduct,
  showReport,
  startNavigation,
  collectPayment,
  sendMessage,
  showDashboard,
  showNotifications,
}

class VoiceCommand {
  final VoiceCommandType type;
  final String text;
  final Map<String, dynamic> parameters;

  const VoiceCommand({
    required this.type,
    required this.text,
    required this.parameters,
  });
}
