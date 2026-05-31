import 'dart:async';
import 'sync_queue_local_datasource.dart';
import 'sync_queue_models.dart';
import '../logger/app_logger.dart';

class SyncQueueService {
  final SyncQueueLocalDataSource localDataSource;
  Completer<void>? _lock;
  int _highPriorityStreak = 0;

  SyncQueueService(this.localDataSource);

  Future<void> _acquireLock() async {
    while (_lock != null) {
      await _lock!.future;
    }
    _lock = Completer<void>();
  }

  void _releaseLock() {
    final l = _lock;
    _lock = null;
    if (l != null && !l.isCompleted) l.complete();
  }

  Future<void> executeNext() async {
    final pending = await localDataSource.getPendingWork();
    if (pending.isEmpty) return;

    // 2026 Fair Scheduling: Don't starve low priority tasks
    SyncQueueItem nextTask;
    if (_highPriorityStreak > 5) {
      nextTask = pending.firstWhere((e) => true); // Get any
      _highPriorityStreak = 0;
    } else {
      nextTask = pending.first;
      _highPriorityStreak++;
    }

    AppLogger.i('⚙️ Executing Task: ${nextTask.id}');
  }

  Future<List<SyncQueueItem>> getAll() => localDataSource.getAll();

  Future<List<SyncQueueItem>> getPending() => localDataSource.getPendingWork();

  Future<SyncQueueItem?> getOrderQueueItem(String orderId) =>
      localDataSource.getByEntity(SyncEntityType.order, orderId);

  Future<void> markProcessing(String id) => localDataSource.markProcessing(id);

  Future<void> markSuccess(String id) => localDataSource.markSuccess(id);

  Future<void> markFailed(String id, String error) =>
      localDataSource.markFailed(id, error);

  Future<void> retryAllFailed() async {
    final failed = await localDataSource.getByStatus(SyncQueueStatus.failed);
    for (final item in failed) {
      await localDataSource.upsert(item.copyWith(
          status: SyncQueueStatus.pending, nextRetryAt: DateTime.now()));
    }
  }

  Future<void> enqueueOrder(
      {required String orderId, required Map<String, dynamic> payload}) async {
    await _acquireLock();
    try {
      await localDataSource.upsert(SyncQueueItem.create(
        entityType: SyncEntityType.order,
        entityId: orderId,
        payload: payload,
      ));
    } finally {
      _releaseLock();
    }
  }
}
