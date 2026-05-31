import 'package:equatable/equatable.dart';

/// Vazifa model
class TaskModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final String type; // visit, order, collection, inventory, other
  final String priority; // high, medium, low
  final String status; // pending, in_progress, completed, overdue, cancelled
  final String assigneeId;
  final String assigneeName;
  final String supervisorId;
  final String? customerId;
  final String? customerName;
  final DateTime dueDate;
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final String? result;
  final String? notes;
  final List<String> attachments;

  const TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.priority,
    required this.status,
    required this.assigneeId,
    required this.assigneeName,
    required this.supervisorId,
    this.customerId,
    this.customerName,
    required this.dueDate,
    required this.createdAt,
    this.startedAt,
    this.completedAt,
    this.result,
    this.notes,
    this.attachments = const [],
  });

  bool get isOverdue =>
      status != 'completed' &&
      status != 'cancelled' &&
      dueDate.isBefore(DateTime.now());
  bool get isHighPriority => priority == 'high';

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? 'other',
      priority: json['priority'] ?? 'medium',
      status: json['status'] ?? 'pending',
      assigneeId: json['assignee_id'] ?? '',
      assigneeName: json['assignee_name'] ?? '',
      supervisorId: json['supervisor_id'] ?? '',
      customerId: json['customer_id'],
      customerName: json['customer_name'],
      dueDate: DateTime.parse(json['due_date'] ??
          DateTime.now().add(const Duration(days: 1)).toIso8601String()),
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
      startedAt: json['started_at'] != null
          ? DateTime.parse(json['started_at'])
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,
      result: json['result'],
      notes: json['notes'],
      attachments: List<String>.from(json['attachments'] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'type': type,
        'priority': priority,
        'status': status,
        'assignee_id': assigneeId,
        'assignee_name': assigneeName,
        'supervisor_id': supervisorId,
        'customer_id': customerId,
        'customer_name': customerName,
        'due_date': dueDate.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
        'started_at': startedAt?.toIso8601String(),
        'completed_at': completedAt?.toIso8601String(),
        'result': result,
        'notes': notes,
        'attachments': attachments,
      };

  @override
  List<Object?> get props => [id, status];
}
