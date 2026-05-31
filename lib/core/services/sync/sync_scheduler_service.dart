import 'dart:async';
import 'package:flutter/material.dart';

// ============================================================
// SYNC SCHEDULER SERVICE - Background sinxronlash
// ============================================================

class SyncSchedulerService {
  static final SyncSchedulerService _instance = SyncSchedulerService._();
  factory SyncSchedulerService() => _instance;
  SyncSchedulerService._();

  Timer? _timer;
  bool _isRunning = false;
  final List<SyncTask> _taskQueue = [];
  final StreamController<SyncStatus> _statusController =
      StreamController<SyncStatus>.broadcast();

  Stream<SyncStatus> get statusStream => _statusController.stream;
  bool get isRunning => _isRunning;
  List<SyncTask> get pendingTasks => List.unmodifiable(_taskQueue);

  // ============ INIT ============

  void initialize({
    Duration interval = const Duration(minutes: 30),
  }) {
    _timer?.cancel();
    _timer = Timer.periodic(interval, (_) {
      _executeQueue();
    });
    debugPrint(
        'Sync scheduler initialized with ${interval.inMinutes}min interval');
  }

  void dispose() {
    _timer?.cancel();
    _statusController.close();
  }

  // ============ TASK MANAGEMENT ============

  void addTask(SyncTask task) {
    _taskQueue.add(task);
    _taskQueue.sort((a, b) => a.priority.compareTo(b.priority));
    debugPrint('Sync task added: ${task.name} (priority: ${task.priority})');

    if (task.immediate) {
      _executeTask(task);
    }
  }

  void removeTask(String taskId) {
    _taskQueue.removeWhere((t) => t.id == taskId);
  }

  void clearQueue() {
    _taskQueue.clear();
  }

  // ============ EXECUTION ============

  Future<void> _executeQueue() async {
    if (_isRunning || _taskQueue.isEmpty) return;

    _isRunning = true;
    _statusController.add(SyncStatus.running);

    final tasksToExecute = List<SyncTask>.from(_taskQueue);

    for (final task in tasksToExecute) {
      try {
        await _executeTask(task);
        _taskQueue.remove(task);
      } catch (e) {
        task.retryCount++;
        if (task.retryCount >= task.maxRetries) {
          _taskQueue.remove(task);
          _statusController.add(SyncStatus.error);
        }
      }
    }

    _isRunning = false;
    _statusController.add(SyncStatus.idle);
  }

  Future<void> _executeTask(SyncTask task) async {
    _statusController.add(SyncStatus.running);

    try {
      await task.execute();
      task.completedAt = DateTime.now();
      debugPrint('Sync task completed: ${task.name}');
    } catch (e) {
      debugPrint('Sync task failed: ${task.name} - $e');
      rethrow;
    }
  }

  // ============ MANUAL SYNC ============

  Future<void> syncNow() async {
    await _executeQueue();
  }

  Future<void> syncAll() async {
    // Barcha ma'lumotlarni sinxronlash
    addTask(SyncTask(
      id: 'sync_all',
      name: 'Barcha ma\'lumotlarni sinxronlash',
      priority: 1,
      immediate: true,
      execute: () async {
        await Future.delayed(const Duration(seconds: 2));
      },
    ));
  }
}

// ============ SYNC TASK ============

class SyncTask {
  final String id;
  final String name;
  final int priority; // 1 = yuqori, 10 = past
  final bool immediate;
  final Future<void> Function() execute;
  int retryCount;
  final int maxRetries;
  DateTime? completedAt;

  SyncTask({
    required this.id,
    required this.name,
    this.priority = 5,
    this.immediate = false,
    required this.execute,
    this.retryCount = 0,
    this.maxRetries = 3,
    this.completedAt,
  });
}

// ============ SYNC STATUS ============

enum SyncStatus {
  idle,
  running,
  error,
  completed,
}
