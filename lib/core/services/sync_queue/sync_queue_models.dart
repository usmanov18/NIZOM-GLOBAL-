import 'package:equatable/equatable.dart';

enum SyncEntityType { order, payment, customer, visit, inventory, unknown }

enum SyncQueueStatus { pending, processing, success, failed, cancelled }

enum SyncFailureCategory {
  network,
  validation,
  auth,
  server,
  conflict,
  unsupported,
  unknown
}

class SyncAttempt extends Equatable {
  final int attempt;
  final SyncQueueStatus status;
  final String? error;
  final SyncFailureCategory? category;
  final DateTime createdAt;

  const SyncAttempt({
    required this.attempt,
    required this.status,
    this.error,
    this.category,
    required this.createdAt,
  });

  factory SyncAttempt.fromJson(Map<String, dynamic> json) {
    return SyncAttempt(
      attempt: json['attempt'] ?? 0,
      status: SyncQueueStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => SyncQueueStatus.failed,
      ),
      error: json['error'],
      category: json['category'] == null
          ? null
          : SyncFailureCategory.values.firstWhere(
              (e) => e.name == json['category'],
              orElse: () => SyncFailureCategory.unknown,
            ),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'attempt': attempt,
        'status': status.name,
        'error': error,
        'category': category?.name,
        'createdAt': createdAt.toIso8601String(),
      };

  @override
  List<Object?> get props => [attempt, status, error, createdAt];
}

class SyncQueueItem extends Equatable {
  final String id;
  final SyncEntityType entityType;
  final String entityId;
  final Map<String, dynamic> payload;
  final SyncQueueStatus status;
  final int retryCount;
  final int maxRetries;
  final String? lastError;
  final SyncFailureCategory? failureCategory;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? nextRetryAt;
  final DateTime? processedAt;
  final String idempotencyKey;
  final String? dependsOnId;
  final List<SyncAttempt> attempts;

  const SyncQueueItem({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.payload,
    required this.status,
    this.retryCount = 0,
    this.maxRetries = 5,
    this.lastError,
    this.failureCategory,
    required this.createdAt,
    required this.updatedAt,
    this.nextRetryAt,
    this.processedAt,
    required this.idempotencyKey,
    this.dependsOnId,
    this.attempts = const [],
  });

  bool get canRetry =>
      status == SyncQueueStatus.failed && retryCount < maxRetries;
  bool get isPendingLike =>
      status == SyncQueueStatus.pending || status == SyncQueueStatus.failed;

  SyncQueueItem copyWith({
    SyncQueueStatus? status,
    int? retryCount,
    String? lastError,
    SyncFailureCategory? failureCategory,
    DateTime? updatedAt,
    DateTime? nextRetryAt,
    DateTime? processedAt,
    Map<String, dynamic>? payload,
    List<SyncAttempt>? attempts,
  }) {
    return SyncQueueItem(
      id: id,
      entityType: entityType,
      entityId: entityId,
      payload: payload ?? this.payload,
      status: status ?? this.status,
      retryCount: retryCount ?? this.retryCount,
      maxRetries: maxRetries,
      lastError: lastError ?? this.lastError,
      failureCategory: failureCategory ?? this.failureCategory,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      nextRetryAt: nextRetryAt ?? this.nextRetryAt,
      processedAt: processedAt ?? this.processedAt,
      idempotencyKey: idempotencyKey,
      dependsOnId: dependsOnId,
      attempts: attempts ?? this.attempts,
    );
  }

  factory SyncQueueItem.create({
    required SyncEntityType entityType,
    required String entityId,
    required Map<String, dynamic> payload,
  }) {
    final now = DateTime.now();
    final id = '${entityType.name}_${entityId}_${now.microsecondsSinceEpoch}';
    return SyncQueueItem(
      id: id,
      entityType: entityType,
      entityId: entityId,
      payload: payload,
      status: SyncQueueStatus.pending,
      createdAt: now,
      updatedAt: now,
      idempotencyKey: '${entityType.name}_$entityId',
    );
  }

  factory SyncQueueItem.fromJson(Map<String, dynamic> json) {
    return SyncQueueItem(
      id: json['id'] ?? '',
      entityType: SyncEntityType.values.firstWhere(
        (e) => e.name == json['entityType'],
        orElse: () => SyncEntityType.unknown,
      ),
      entityId: json['entityId'] ?? '',
      payload: Map<String, dynamic>.from(json['payload'] ?? {}),
      status: SyncQueueStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => SyncQueueStatus.pending,
      ),
      retryCount: json['retryCount'] ?? 0,
      maxRetries: json['maxRetries'] ?? 5,
      lastError: json['lastError'],
      failureCategory: json['failureCategory'] == null
          ? null
          : SyncFailureCategory.values.firstWhere(
              (e) => e.name == json['failureCategory'],
              orElse: () => SyncFailureCategory.unknown,
            ),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      nextRetryAt: DateTime.tryParse(json['nextRetryAt'] ?? ''),
      processedAt: DateTime.tryParse(json['processedAt'] ?? ''),
      idempotencyKey: json['idempotencyKey'] ?? '',
      dependsOnId: json['dependsOnId'],
      attempts: (json['attempts'] as List? ?? [])
          .map((e) => SyncAttempt.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'entityType': entityType.name,
        'entityId': entityId,
        'payload': payload,
        'status': status.name,
        'retryCount': retryCount,
        'maxRetries': maxRetries,
        'lastError': lastError,
        'failureCategory': failureCategory?.name,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'nextRetryAt': nextRetryAt?.toIso8601String(),
        'processedAt': processedAt?.toIso8601String(),
        'idempotencyKey': idempotencyKey,
        'dependsOnId': dependsOnId,
        'attempts': attempts.map((e) => e.toJson()).toList(),
      };

  @override
  List<Object?> get props =>
      [id, entityType, entityId, status, retryCount, attempts.length];
}
