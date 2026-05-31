import 'package:equatable/equatable.dart';

class StateMirror extends Equatable {
  final String agentId;
  final String currentRoute;
  final Map<String, dynamic> activeCart;
  final DateTime lastActionAt;

  const StateMirror({
    required this.agentId,
    required this.currentRoute,
    required this.activeCart,
    required this.lastActionAt,
  });

  @override
  List<Object?> get props => [agentId, currentRoute, lastActionAt];
}
