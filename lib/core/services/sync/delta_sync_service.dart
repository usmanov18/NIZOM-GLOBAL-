import 'dart:async';

// ============================================================
// DELTA SYNC SERVICE - Faqat o'zgarishlarni sinxronlash
// ============================================================

class DeltaSyncService {
  static final DeltaSyncService _instance = DeltaSyncService._();
  factory DeltaSyncService() => _instance;
  DeltaSyncService._();

  final Map<String, DateTime> _lastSyncTimes = {};
  final Map<String, int> _lastSyncVersions = {};
  final StreamController<DeltaSyncEvent> _eventController =
      StreamController<DeltaSyncEvent>.broadcast();

  Stream<DeltaSyncEvent> get eventStream => _eventController.stream;

  // ============ DELTA SYNC ============

  /// Faqat o'zgarishlarni sinxronlash
  Future<DeltaSyncResult> syncDelta({
    required String entityType,
    required String source, // '1c' or 'sap'
    required Future<List<Map<String, dynamic>>> Function(DateTime? since)
        fetchFunction,
    required Future<void> Function(List<Map<String, dynamic>>) saveFunction,
  }) async {
    final startTime = DateTime.now();
    final lastSync = _lastSyncTimes['${entityType}_$source'];

    try {
      _eventController.add(DeltaSyncEvent(
        entityType: entityType,
        source: source,
        status: DeltaSyncStatus.running,
        message: 'Sinxronlash boshlandi...',
      ));

      // Faqat o'zgarishlarni olish
      final changes = await fetchFunction(lastSync);

      // Saqlash
      if (changes.isNotEmpty) {
        await saveFunction(changes);
      }

      // Vaqtni yangilash
      _lastSyncTimes['${entityType}_$source'] = DateTime.now();

      final result = DeltaSyncResult(
        entityType: entityType,
        source: source,
        totalChanges: changes.length,
        successCount: changes.length,
        failedCount: 0,
        duration: DateTime.now().difference(startTime),
        timestamp: DateTime.now(),
      );

      _eventController.add(DeltaSyncEvent(
        entityType: entityType,
        source: source,
        status: DeltaSyncStatus.completed,
        message: '${changes.length} ta o\'zgarish sinxronlandi',
      ));

      return result;
    } catch (e) {
      _eventController.add(DeltaSyncEvent(
        entityType: entityType,
        source: source,
        status: DeltaSyncStatus.error,
        message: 'Xatolik: $e',
      ));

      return DeltaSyncResult(
        entityType: entityType,
        source: source,
        totalChanges: 0,
        successCount: 0,
        failedCount: 1,
        duration: DateTime.now().difference(startTime),
        timestamp: DateTime.now(),
        error: e.toString(),
      );
    }
  }

  /// Barcha entitylar uchun delta sync
  Future<List<DeltaSyncResult>> syncAllDeltas() async {
    final results = <DeltaSyncResult>[];

    for (final entity in const ['customers', 'products', 'orders']) {
      results.add(await syncDelta(
        entityType: entity,
        source: 'local',
        fetchFunction: (_) async => const <Map<String, dynamic>>[],
        saveFunction: (_) async {},
      ));
    }

    return results;
  }

  /// Oxirgi sinxronlash vaqtini olish
  DateTime? getLastSyncTime(String entityType, String source) {
    return _lastSyncTimes['${entityType}_$source'];
  }

  /// Sinxronlash kerakligini tekshirish
  bool needsSync(String entityType, String source,
      {Duration maxAge = const Duration(hours: 1)}) {
    final lastSync = getLastSyncTime(entityType, source);
    if (lastSync == null) return true;
    return DateTime.now().difference(lastSync) > maxAge;
  }

  void dispose() {
    _eventController.close();
  }
}

// ============ MODELS ============

enum DeltaSyncStatus {
  idle,
  running,
  completed,
  error,
}

class DeltaSyncEvent {
  final String entityType;
  final String source;
  final DeltaSyncStatus status;
  final String message;
  final DateTime timestamp;

  DeltaSyncEvent({
    required this.entityType,
    required this.source,
    required this.status,
    required this.message,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class DeltaSyncResult {
  final String entityType;
  final String source;
  final int totalChanges;
  final int successCount;
  final int failedCount;
  final Duration duration;
  final DateTime timestamp;
  final String? error;

  const DeltaSyncResult({
    required this.entityType,
    required this.source,
    required this.totalChanges,
    required this.successCount,
    required this.failedCount,
    required this.duration,
    required this.timestamp,
    this.error,
  });

  bool get isSuccess => failedCount == 0;
  bool get hasChanges => totalChanges > 0;
}
