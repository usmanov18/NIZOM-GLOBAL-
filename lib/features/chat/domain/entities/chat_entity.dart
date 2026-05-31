import 'package:equatable/equatable.dart';

class ChatMessage extends Equatable {
  final String id;
  final String senderId;
  final String text;
  final DateTime timestamp;
  final String? documentId; // 1C/SAP hujjati bilan bog'liqlik

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.text,
    required this.timestamp,
    this.documentId,
  });

  @override
  List<Object?> get props => [id, senderId, text];
}
