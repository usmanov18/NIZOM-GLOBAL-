import 'package:equatable/equatable.dart';

class UserFeedback extends Equatable {
  final String id;
  final String userId;
  final String message;
  final String type; // bug, suggestion, question
  final DateTime createdAt;

  const UserFeedback({
    required this.id,
    required this.userId,
    required this.message,
    required this.type,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, userId, message];
}
