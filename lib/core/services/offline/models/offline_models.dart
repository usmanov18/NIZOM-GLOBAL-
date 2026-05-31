import 'package:equatable/equatable.dart';

// ============================================================
// OFFLINE MODELS - Offline ma'lumotlar
// ============================================================

/// Offline holat
enum OfflineStatus {
  online,
  offline,
  syncing,
  syncCompleted,
  syncFailed,
}

/// Sinxronlash holati
enum SyncStatusType {
  pending, // Kutilmoqda
  inProgress, // Jarayonda
  completed, // Tugadi
  failed, // Xatolik
  conflict, // Konflikt
}

/// Offline action turi
enum OfflineActionType {
  createOrder,
  updateOrder,
  cancelOrder,
  createPayment,
  checkInVisit,
  checkOutVisit,
  sendLocation,
  createCustomer,
  updateCustomer,
  confirmDelivery,
  createReturn,
}

/// Offline action
class OfflineAction extends Equatable {
  final String id;
  final OfflineActionType type;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final int retryCount;
  final int maxRetries;
  final String? errorMessage;
  final SyncStatusType status;
  final int priority; // 1 = yuqori, 2 = o'rta, 3 = past

  const OfflineAction({
    required this.id,
    required this.type,
    required this.data,
    required this.createdAt,
    required this.retryCount,
    required this.maxRetries,
    this.errorMessage,
    required this.status,
    required this.priority,
  });

  bool get canRetry => retryCount < maxRetries;

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'data': data,
        'created_at': createdAt.toIso8601String(),
        'retry_count': retryCount,
        'max_retries': maxRetries,
        'error_message': errorMessage,
        'status': status.name,
        'priority': priority,
      };

  factory OfflineAction.fromJson(Map<String, dynamic> json) {
    return OfflineAction(
      id: json['id'] ?? '',
      type: OfflineActionType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => OfflineActionType.createOrder,
      ),
      data: Map<String, dynamic>.from(json['data'] ?? {}),
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
      retryCount: json['retry_count'] ?? 0,
      maxRetries: json['max_retries'] ?? 3,
      errorMessage: json['error_message'],
      status: SyncStatusType.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => SyncStatusType.pending,
      ),
      priority: json['priority'] ?? 2,
    );
  }

  OfflineAction copyWith({
    int? retryCount,
    String? errorMessage,
    SyncStatusType? status,
  }) {
    return OfflineAction(
      id: id,
      type: type,
      data: data,
      createdAt: createdAt,
      retryCount: retryCount ?? this.retryCount,
      maxRetries: maxRetries,
      errorMessage: errorMessage ?? this.errorMessage,
      status: status ?? this.status,
      priority: priority,
    );
  }

  @override
  List<Object?> get props => [id, type, status, retryCount];
}

/// Sinxronlash natijasi
class SyncResult extends Equatable {
  final int total;
  final int success;
  final int failed;
  final int conflicts;
  final List<SyncError> errors;
  final DateTime startedAt;
  final DateTime completedAt;
  final Duration duration;

  const SyncResult({
    required this.total,
    required this.success,
    required this.failed,
    required this.conflicts,
    required this.errors,
    required this.startedAt,
    required this.completedAt,
    required this.duration,
  });

  bool get allSuccess => failed == 0 && conflicts == 0;
  bool get hasErrors => failed > 0;
  bool get hasConflicts => conflicts > 0;

  @override
  List<Object?> get props => [total, success, failed];
}

/// Sinxronlash xatoligi
class SyncError extends Equatable {
  final String actionId;
  final String actionType;
  final String errorMessage;
  final int errorCode;
  final DateTime occurredAt;

  const SyncError({
    required this.actionId,
    required this.actionType,
    required this.errorMessage,
    required this.errorCode,
    required this.occurredAt,
  });

  @override
  List<Object?> get props => [actionId, errorCode];
}

/// Conflict resolution
class ConflictResolution extends Equatable {
  final String actionId;
  final Map<String, dynamic> localData;
  final Map<String, dynamic> serverData;
  final DateTime localTimestamp;
  final DateTime serverTimestamp;
  final String resolution; // local, server, merge

  const ConflictResolution({
    required this.actionId,
    required this.localData,
    required this.serverData,
    required this.localTimestamp,
    required this.serverTimestamp,
    required this.resolution,
  });

  @override
  List<Object?> get props => [actionId, resolution];
}

/// Cache strategy
enum CacheStrategy {
  lru, // Least Recently Used
  fifo, // First In First Out
  ttl, // Time To Live
  size, // Size based
}

/// Cache entry
class CacheEntry extends Equatable {
  final String key;
  final dynamic data;
  final DateTime cachedAt;
  final Duration? ttl;
  final int sizeBytes;
  final int accessCount;
  final DateTime? lastAccessedAt;

  const CacheEntry({
    required this.key,
    required this.data,
    required this.cachedAt,
    this.ttl,
    required this.sizeBytes,
    required this.accessCount,
    this.lastAccessedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'data': data,
      'cachedAt': cachedAt.toIso8601String(),
      'ttl': ttl?.inSeconds,
      'sizeBytes': sizeBytes,
      'accessCount': accessCount,
      'lastAccessedAt': lastAccessedAt?.toIso8601String(),
    };
  }

  factory CacheEntry.fromJson(Map<String, dynamic> json) {
    return CacheEntry(
      key: json['key'] as String,
      data: json['data'],
      cachedAt: DateTime.parse(json['cachedAt'] as String),
      ttl: json['ttl'] != null ? Duration(seconds: json['ttl'] as int) : null,
      sizeBytes: json['sizeBytes'] as int,
      accessCount: json['accessCount'] as int,
      lastAccessedAt: json['lastAccessedAt'] != null
          ? DateTime.parse(json['lastAccessedAt'] as String)
          : null,
    );
  }

  bool get isExpired {
    if (ttl == null) return false;
    return DateTime.now().difference(cachedAt) > ttl!;
  }

  @override
  List<Object?> get props => [key, cachedAt];
}
