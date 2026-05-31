import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// ============================================================
// TASK BLOC - Vazifalar boshqaruvi
// ============================================================

// ============ EVENTS ============

abstract class TaskEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class TasksLoadRequested extends TaskEvent {
  final String? status;
  final String? assigneeId;
  TasksLoadRequested({this.status, this.assigneeId});
}

class TaskCreateRequested extends TaskEvent {
  final String title;
  final String description;
  final String type;
  final String priority;
  final String assigneeId;
  final DateTime dueDate;
  final String? customerId;
  TaskCreateRequested({
    required this.title,
    required this.description,
    required this.type,
    required this.priority,
    required this.assigneeId,
    required this.dueDate,
    this.customerId,
  });
}

class TaskUpdateRequested extends TaskEvent {
  final String taskId;
  final String? status;
  final String? result;
  TaskUpdateRequested({required this.taskId, this.status, this.result});
}

class TaskDeleteRequested extends TaskEvent {
  final String taskId;
  TaskDeleteRequested(this.taskId);
}

// ============ STATES ============

abstract class TaskState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class TasksLoaded extends TaskState {
  final List<Map<String, dynamic>> tasks;
  final int pendingCount;
  final int overdueCount;
  TasksLoaded(
      {required this.tasks,
      required this.pendingCount,
      required this.overdueCount});
}

class TaskCreated extends TaskState {
  final Map<String, dynamic> task;
  TaskCreated(this.task);
}

class TaskUpdated extends TaskState {}

class TaskDeleted extends TaskState {}

class TaskError extends TaskState {
  final String message;
  TaskError(this.message);
}

// ============ BLOC ============

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  TaskBloc() : super(TaskInitial()) {
    on<TasksLoadRequested>(_onLoad);
    on<TaskCreateRequested>(_onCreate);
    on<TaskUpdateRequested>(_onUpdate);
    on<TaskDeleteRequested>(_onDelete);
  }

  Future<void> _onLoad(
      TasksLoadRequested event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    await Future.delayed(const Duration(milliseconds: 500));

    final tasks = List.generate(
        10,
        (i) => {
              'id': 'task_$i',
              'title': 'Vazifa ${i + 1}',
              'description': 'Vazifa tavsifi',
              'type': i % 3 == 0
                  ? 'visit'
                  : i % 3 == 1
                      ? 'order'
                      : 'collection',
              'priority': i % 3 == 0
                  ? 'high'
                  : i % 3 == 1
                      ? 'medium'
                      : 'low',
              'status': i < 3
                  ? 'pending'
                  : i < 6
                      ? 'in_progress'
                      : 'completed',
              'assignee_id': 'agent_1',
              'due_date':
                  DateTime.now().add(Duration(days: i - 3)).toIso8601String(),
            });

    final filtered = event.status == null
        ? tasks
        : tasks.where((task) => task['status'] == event.status).toList();
    emit(TasksLoaded(
      tasks: filtered,
      pendingCount: tasks.where((task) => task['status'] == 'pending').length,
      overdueCount: tasks.where((task) {
        final dueDate = DateTime.tryParse(task['due_date'].toString());
        return task['status'] != 'completed' &&
            dueDate != null &&
            dueDate.isBefore(DateTime.now());
      }).length,
    ));
  }

  Future<void> _onCreate(
      TaskCreateRequested event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    await Future.delayed(const Duration(milliseconds: 500));

    final task = {
      'id': 'task_${DateTime.now().millisecondsSinceEpoch}',
      'title': event.title,
      'description': event.description,
      'type': event.type,
      'priority': event.priority,
      'status': 'pending',
      'assignee_id': event.assigneeId,
      'due_date': event.dueDate.toIso8601String(),
      'customer_id': event.customerId,
      'created_at': DateTime.now().toIso8601String(),
    };

    emit(TaskCreated(task));
  }

  Future<void> _onUpdate(
      TaskUpdateRequested event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    await Future.delayed(const Duration(milliseconds: 300));
    emit(TaskUpdated());
  }

  Future<void> _onDelete(
      TaskDeleteRequested event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    await Future.delayed(const Duration(milliseconds: 300));
    emit(TaskDeleted());
  }
}
