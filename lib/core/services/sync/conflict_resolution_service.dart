import 'dart:async';

// ============================================================
// CONFLICT RESOLUTION SERVICE - O'zgarishlarni hal qilish
// ============================================================

class ConflictResolutionService {
  static final ConflictResolutionService _instance =
      ConflictResolutionService._();
  factory ConflictResolutionService() => _instance;
  ConflictResolutionService._();

  final StreamController<ConflictEvent> _eventController =
      StreamController<ConflictEvent>.broadcast();

  Stream<ConflictEvent> get eventStream => _eventController.stream;

  // ============ CONFLICT DETECTION ============

  /// Konfliktni aniqlash
  ConflictResult detectConflict({
    required Map<String, dynamic> localData,
    required Map<String, dynamic> remoteData,
    required String entityType,
  }) {
    final differences = <String, FieldDifference>{};

    // Har bir field ni solishtirish
    for (final key in localData.keys) {
      if (remoteData.containsKey(key)) {
        final localValue = localData[key];
        final remoteValue = remoteData[key];

        if (localValue != remoteValue) {
          differences[key] = FieldDifference(
            fieldName: key,
            localValue: localValue,
            remoteValue: remoteValue,
            localTimestamp: localData['updated_at'] != null
                ? DateTime.parse(localData['updated_at'])
                : null,
            remoteTimestamp: remoteData['updated_at'] != null
                ? DateTime.parse(remoteData['updated_at'])
                : null,
          );
        }
      }
    }

    return ConflictResult(
      entityType: entityType,
      entityId: localData['id'] ?? '',
      hasConflict: differences.isNotEmpty,
      differences: differences,
      localData: localData,
      remoteData: remoteData,
      detectedAt: DateTime.now(),
    );
  }

  // ============ CONFLICT RESOLUTION ============

  /// Konfliktni hal qilish
  Future<ResolutionResult> resolveConflict({
    required ConflictResult conflict,
    required ResolutionStrategy strategy,
  }) async {
    Map<String, dynamic> resolvedData;

    switch (strategy) {
      case ResolutionStrategy.useLocal:
        resolvedData = conflict.localData;
        break;
      case ResolutionStrategy.useRemote:
        resolvedData = conflict.remoteData;
        break;
      case ResolutionStrategy.merge:
        resolvedData = _mergeData(
            conflict.localData, conflict.remoteData, conflict.differences);
        break;
      case ResolutionStrategy.useNewest:
        resolvedData = _useNewest(
            conflict.localData, conflict.remoteData, conflict.differences);
        break;
      case ResolutionStrategy.manual:
        // Manual resolution - foydalanuvchi tanlashi kerak
        resolvedData = conflict.localData;
        break;
    }

    _eventController.add(ConflictEvent(
      entityId: conflict.entityId,
      entityType: conflict.entityType,
      strategy: strategy,
      resolvedAt: DateTime.now(),
    ));

    return ResolutionResult(
      conflict: conflict,
      strategy: strategy,
      resolvedData: resolvedData,
      resolvedAt: DateTime.now(),
    );
  }

  // ============ MERGE LOGIC ============

  Map<String, dynamic> _mergeData(
    Map<String, dynamic> local,
    Map<String, dynamic> remote,
    Map<String, FieldDifference> differences,
  ) {
    final merged = Map<String, dynamic>.from(local);

    for (final diff in differences.entries) {
      final key = diff.key;
      final fieldDiff = diff.value;

      // Eng yangi ma'lumotni tanlash
      if (fieldDiff.localTimestamp != null &&
          fieldDiff.remoteTimestamp != null) {
        if (fieldDiff.remoteTimestamp!.isAfter(fieldDiff.localTimestamp!)) {
          merged[key] = fieldDiff.remoteValue;
        } else {
          merged[key] = fieldDiff.localValue;
        }
      } else {
        // Remote ni ustun qilish
        merged[key] = fieldDiff.remoteValue;
      }
    }

    merged['updated_at'] = DateTime.now().toIso8601String();
    return merged;
  }

  Map<String, dynamic> _useNewest(
    Map<String, dynamic> local,
    Map<String, dynamic> remote,
    Map<String, FieldDifference> differences,
  ) {
    final localTime = local['updated_at'] != null
        ? DateTime.parse(local['updated_at'])
        : DateTime(2000);
    final remoteTime = remote['updated_at'] != null
        ? DateTime.parse(remote['updated_at'])
        : DateTime(2000);

    return remoteTime.isAfter(localTime) ? remote : local;
  }

  void dispose() {
    _eventController.close();
  }
}

// ============ MODELS ============

enum ResolutionStrategy {
  useLocal, // Local ma'lumotni ishlatish
  useRemote, // Remote ma'lumotni ishlatish
  merge, // Birlashtirish
  useNewest, // Eng yangisini ishlatish
  manual, // Qo'lda hal qilish
}

class FieldDifference {
  final String fieldName;
  final dynamic localValue;
  final dynamic remoteValue;
  final DateTime? localTimestamp;
  final DateTime? remoteTimestamp;

  const FieldDifference({
    required this.fieldName,
    required this.localValue,
    required this.remoteValue,
    this.localTimestamp,
    this.remoteTimestamp,
  });
}

class ConflictResult {
  final String entityType;
  final String entityId;
  final bool hasConflict;
  final Map<String, FieldDifference> differences;
  final Map<String, dynamic> localData;
  final Map<String, dynamic> remoteData;
  final DateTime detectedAt;

  const ConflictResult({
    required this.entityType,
    required this.entityId,
    required this.hasConflict,
    required this.differences,
    required this.localData,
    required this.remoteData,
    required this.detectedAt,
  });

  int get differenceCount => differences.length;
}

class ResolutionResult {
  final ConflictResult conflict;
  final ResolutionStrategy strategy;
  final Map<String, dynamic> resolvedData;
  final DateTime resolvedAt;

  const ResolutionResult({
    required this.conflict,
    required this.strategy,
    required this.resolvedData,
    required this.resolvedAt,
  });
}

class ConflictEvent {
  final String entityId;
  final String entityType;
  final ResolutionStrategy strategy;
  final DateTime resolvedAt;

  const ConflictEvent({
    required this.entityId,
    required this.entityType,
    required this.strategy,
    required this.resolvedAt,
  });
}
