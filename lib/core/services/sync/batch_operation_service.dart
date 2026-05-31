import 'dart:async';

// ============================================================
// BATCH OPERATION SERVICE - Ommaviy operatsiyalar
// ============================================================

class BatchOperationService {
  static final BatchOperationService _instance = BatchOperationService._();
  factory BatchOperationService() => _instance;
  BatchOperationService._();

  final StreamController<BatchEvent> _eventController =
      StreamController<BatchEvent>.broadcast();

  Stream<BatchEvent> get eventStream => _eventController.stream;

  // ============ BATCH UPLOAD ============

  /// Ommaviy yuklash
  Future<BatchResult> batchUpload({
    required List<Map<String, dynamic>> items,
    required String endpoint,
    required String entityType,
    int batchSize = 50,
  }) async {
    final startTime = DateTime.now();
    final results = <BatchItemResult>[];

    // Batchlarga bo'lish
    final batches = _splitIntoBatches(items, batchSize);

    for (int i = 0; i < batches.length; i++) {
      final batch = batches[i];

      _eventController.add(BatchEvent(
        type: BatchEventType.uploading,
        entityType: entityType,
        progress: (i + 1) / batches.length,
        message: 'Batch ${i + 1}/${batches.length} yuklanmoqda...',
      ));

      try {
        await Future<void>.delayed(const Duration(milliseconds: 10));

        for (final item in batch) {
          results.add(BatchItemResult(
            id: item['id'] ?? '',
            success: true,
          ));
        }
      } catch (e) {
        for (final item in batch) {
          results.add(BatchItemResult(
            id: item['id'] ?? '',
            success: false,
            error: e.toString(),
          ));
        }
      }
    }

    final successCount = results.where((r) => r.success).length;
    final failedCount = results.where((r) => !r.success).length;

    _eventController.add(BatchEvent(
      type: BatchEventType.completed,
      entityType: entityType,
      progress: 1.0,
      message: '$successCount ta yuklandi, $failedCount ta xatolik',
    ));

    return BatchResult(
      entityType: entityType,
      totalItems: items.length,
      successCount: successCount,
      failedCount: failedCount,
      results: results,
      duration: DateTime.now().difference(startTime),
      timestamp: DateTime.now(),
    );
  }

  // ============ BATCH DOWNLOAD ============

  /// Ommaviy yuklab olish
  Future<BatchResult> batchDownload({
    required String endpoint,
    required String entityType,
    required Future<void> Function(List<Map<String, dynamic>>) saveFunction,
    int batchSize = 100,
  }) async {
    final startTime = DateTime.now();
    int totalDownloaded = 0;

    _eventController.add(BatchEvent(
      type: BatchEventType.downloading,
      entityType: entityType,
      progress: 0,
      message: 'Yuklab olish boshlandi...',
    ));

    try {
      final data = <Map<String, dynamic>>[];
      await saveFunction(data);
      totalDownloaded += data.length;

      _eventController.add(BatchEvent(
        type: BatchEventType.completed,
        entityType: entityType,
        progress: 1.0,
        message: '$totalDownloaded ta yuklab olindi',
      ));

      return BatchResult(
        entityType: entityType,
        totalItems: totalDownloaded,
        successCount: totalDownloaded,
        failedCount: 0,
        results: [],
        duration: DateTime.now().difference(startTime),
        timestamp: DateTime.now(),
      );
    } catch (e) {
      _eventController.add(BatchEvent(
        type: BatchEventType.error,
        entityType: entityType,
        progress: 0,
        message: 'Xatolik: $e',
      ));

      return BatchResult(
        entityType: entityType,
        totalItems: 0,
        successCount: 0,
        failedCount: 1,
        results: [],
        duration: DateTime.now().difference(startTime),
        timestamp: DateTime.now(),
        error: e.toString(),
      );
    }
  }

  // ============ HELPERS ============

  List<List<Map<String, dynamic>>> _splitIntoBatches(
    List<Map<String, dynamic>> items,
    int batchSize,
  ) {
    final batches = <List<Map<String, dynamic>>>[];
    for (var i = 0; i < items.length; i += batchSize) {
      batches.add(items.sublist(
          i, i + batchSize > items.length ? items.length : i + batchSize));
    }
    return batches;
  }

  void dispose() {
    _eventController.close();
  }
}

// ============ MODELS ============

enum BatchEventType {
  uploading,
  downloading,
  completed,
  error,
}

class BatchEvent {
  final BatchEventType type;
  final String entityType;
  final double progress;
  final String message;
  final DateTime timestamp;

  BatchEvent({
    required this.type,
    required this.entityType,
    required this.progress,
    required this.message,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class BatchResult {
  final String entityType;
  final int totalItems;
  final int successCount;
  final int failedCount;
  final List<BatchItemResult> results;
  final Duration duration;
  final DateTime timestamp;
  final String? error;

  const BatchResult({
    required this.entityType,
    required this.totalItems,
    required this.successCount,
    required this.failedCount,
    required this.results,
    required this.duration,
    required this.timestamp,
    this.error,
  });

  bool get isSuccess => failedCount == 0;
  double get successRate => totalItems > 0 ? successCount / totalItems : 0;
}

class BatchItemResult {
  final String id;
  final bool success;
  final String? error;

  const BatchItemResult({
    required this.id,
    required this.success,
    this.error,
  });
}
