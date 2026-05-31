import 'dart:async';

import '../../../features/order_flow/domain/repositories/order_flow_repository.dart';
import 'sync_queue_models.dart';
import 'sync_queue_service.dart';

class SyncWorkerProgress {
  final bool running;
  final int total;
  final int processed;
  final int success;
  final int failed;
  final String? currentEntityId;

  const SyncWorkerProgress({
    required this.running,
    required this.total,
    required this.processed,
    required this.success,
    required this.failed,
    this.currentEntityId,
  });
}

/// Queue ichidagi pending itemlarni sync qiluvchi worker.
class SyncWorkerService {
  final SyncQueueService queueService;
  final OrderFlowRepository orderRepository;

  final _controller = StreamController<SyncWorkerProgress>.broadcast();
  Stream<SyncWorkerProgress> get progressStream => _controller.stream;

  bool _running = false;
  bool get isRunning => _running;

  SyncWorkerService({
    required this.queueService,
    required this.orderRepository,
  });

  Future<SyncWorkerProgress> runOnce() async {
    if (_running) {
      return const SyncWorkerProgress(
          running: true, total: 0, processed: 0, success: 0, failed: 0);
    }

    _running = true;
    final pending = await queueService.getPending();
    int processed = 0;
    int success = 0;
    int failed = 0;

    _emit(
        total: pending.length,
        processed: processed,
        success: success,
        failed: failed);

    for (final item in pending) {
      _emit(
          total: pending.length,
          processed: processed,
          success: success,
          failed: failed,
          currentEntityId: item.entityId);
      await queueService.markProcessing(item.id);

      try {
        switch (item.entityType) {
          case SyncEntityType.order:
            final result = await orderRepository.syncOrderToAll(item.entityId);
            await result.fold(
              (failure) async {
                failed++;
                await queueService.markFailed(item.id, failure.message);
              },
              (_) async {
                success++;
                await queueService.markSuccess(item.id);
              },
            );
            break;
          default:
            failed++;
            await queueService.markFailed(item.id,
                'Sync entity qo‘llab-quvvatlanmaydi: ${item.entityType.name}');
            break;
        }
      } catch (e) {
        failed++;
        await queueService.markFailed(item.id, e.toString());
      }

      processed++;
      _emit(
          total: pending.length,
          processed: processed,
          success: success,
          failed: failed);
    }

    _running = false;
    final done = SyncWorkerProgress(
      running: false,
      total: pending.length,
      processed: processed,
      success: success,
      failed: failed,
    );
    _controller.add(done);
    return done;
  }

  void _emit({
    required int total,
    required int processed,
    required int success,
    required int failed,
    String? currentEntityId,
  }) {
    _controller.add(SyncWorkerProgress(
      running: true,
      total: total,
      processed: processed,
      success: success,
      failed: failed,
      currentEntityId: currentEntityId,
    ));
  }

  void dispose() {
    _controller.close();
  }
}
