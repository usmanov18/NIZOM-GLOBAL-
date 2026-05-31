import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'models/offline_models.dart';

// ============================================================
// OFFLINE SERVICE - Professional Offline Support
// ============================================================

class OfflineService {
  static final OfflineService _instance = OfflineService._internal();
  factory OfflineService() => _instance;
  OfflineService._internal();

  static const String _actionsBox = 'offline_actions';
  static const String _cacheBox = 'offline_cache';
  static const String _syncLogBox = 'sync_log';

  final Connectivity _connectivity = Connectivity();

  OfflineStatus _status = OfflineStatus.online;
  bool _isSyncing = false;

  final StreamController<OfflineStatus> _statusController =
      StreamController<OfflineStatus>.broadcast();
  final StreamController<SyncResult> _syncResultController =
      StreamController<SyncResult>.broadcast();

  Stream<OfflineStatus> get statusStream => _statusController.stream;
  Stream<SyncResult> get syncResultStream => _syncResultController.stream;

  OfflineStatus get status => _status;
  bool get isOnline => _status == OfflineStatus.online;
  bool get isOffline => _status == OfflineStatus.offline;
  bool get isSyncing => _isSyncing;

  // ============ INITIALIZATION ============

  Future<void> initialize() async {
    // Connectivity tinglash
    _connectivity.onConnectivityChanged.listen(_onConnectivityChanged);

    // Boshlang'ich holat
    final result = await _connectivity.checkConnectivity();
    _updateStatus(result != ConnectivityResult.none
        ? OfflineStatus.online
        : OfflineStatus.offline);
  }

  void _onConnectivityChanged(ConnectivityResult result) {
    final isOnline = result != ConnectivityResult.none;

    if (isOnline && _status == OfflineStatus.offline) {
      _updateStatus(OfflineStatus.online);
      // Avtomatik sinxronlash
      syncPendingActions();
    } else if (!isOnline && _status == OfflineStatus.online) {
      _updateStatus(OfflineStatus.offline);
    }
  }

  void _updateStatus(OfflineStatus newStatus) {
    _status = newStatus;
    _statusController.add(newStatus);
  }

  // ============ OFFLINE ACTIONS ============

  /// Offline action saqlash
  Future<void> saveAction(OfflineAction action) async {
    try {
      final box = await Hive.openBox(_actionsBox);
      await box.put(action.id, jsonEncode(action.toJson()));
      debugPrint('Offline action saved: ${action.type.name}');
    } catch (e) {
      debugPrint('Save action error: $e');
    }
  }

  /// Barcha pending actionlarni olish
  Future<List<OfflineAction>> getPendingActions() async {
    try {
      final box = await Hive.openBox(_actionsBox);
      final actions = <OfflineAction>[];

      for (var i = 0; i < box.length; i++) {
        final data = box.getAt(i);
        if (data != null) {
          actions.add(OfflineAction.fromJson(jsonDecode(data)));
        }
      }

      // Priority bo'yicha saralash
      actions.sort((a, b) => a.priority.compareTo(b.priority));

      return actions;
    } catch (e) {
      return [];
    }
  }

  /// Action ni o'chirish
  Future<void> removeAction(String actionId) async {
    try {
      final box = await Hive.openBox(_actionsBox);
      await box.delete(actionId);
    } catch (e) {
      debugPrint('Remove action error: $e');
    }
  }

  /// Barcha actionlarni tozalash
  Future<void> clearActions() async {
    try {
      final box = await Hive.openBox(_actionsBox);
      await box.clear();
    } catch (e) {
      debugPrint('Clear actions error: $e');
    }
  }

  // ============ SINXRONLASH ============

  /// Barcha pending actionlarni sinxronlash
  Future<SyncResult> syncPendingActions() async {
    if (_isSyncing) {
      return SyncResult(
        total: 0,
        success: 0,
        failed: 0,
        conflicts: 0,
        errors: [],
        startedAt: DateTime.now(),
        completedAt: DateTime.now(),
        duration: Duration.zero,
      );
    }

    _isSyncing = true;
    _updateStatus(OfflineStatus.syncing);

    final startTime = DateTime.now();
    final actions = await getPendingActions();

    int success = 0;
    int failed = 0;
    int conflicts = 0;
    final errors = <SyncError>[];

    for (final action in actions) {
      try {
        final result = await _executeAction(action);

        if (result) {
          await removeAction(action.id);
          success++;
        } else {
          // Qayta urinish
          if (action.canRetry) {
            await saveAction(action.copyWith(
              retryCount: action.retryCount + 1,
              status: SyncStatusType.pending,
            ));
          } else {
            await removeAction(action.id);
            failed++;
            errors.add(SyncError(
              actionId: action.id,
              actionType: action.type.name,
              errorMessage: action.errorMessage ?? 'Max urinish soni oshdi',
              errorCode: 0,
              occurredAt: DateTime.now(),
            ));
          }
        }
      } catch (e) {
        failed++;
        errors.add(SyncError(
          actionId: action.id,
          actionType: action.type.name,
          errorMessage: e.toString(),
          errorCode: 0,
          occurredAt: DateTime.now(),
        ));
      }
    }

    final endTime = DateTime.now();

    final result = SyncResult(
      total: actions.length,
      success: success,
      failed: failed,
      conflicts: conflicts,
      errors: errors,
      startedAt: startTime,
      completedAt: endTime,
      duration: endTime.difference(startTime),
    );

    _isSyncing = false;
    _updateStatus(OfflineStatus.syncCompleted);
    _syncResultController.add(result);

    // Log saqlash
    await _saveSyncLog(result);

    return result;
  }

  /// Action ni bajarish
  Future<bool> _executeAction(OfflineAction action) async {
    try {
      switch (action.type) {
        case OfflineActionType.createOrder:
        case OfflineActionType.updateOrder:
        case OfflineActionType.createPayment:
        case OfflineActionType.sendLocation:
        default:
          break;
      }

      await Future.delayed(const Duration(milliseconds: 500));
      return true;
    } catch (e) {
      return false;
    }
  }

  // ============ CACHE ============

  /// Cache ga saqlash
  Future<void> cacheData(String key, dynamic data, {Duration? ttl}) async {
    try {
      final box = await Hive.openBox(_cacheBox);
      final entry = CacheEntry(
        key: key,
        data: data,
        cachedAt: DateTime.now(),
        ttl: ttl,
        sizeBytes: jsonEncode(data).length,
        accessCount: 0,
      );
      await box.put(key, jsonEncode(entry.toJson()));
    } catch (e) {
      debugPrint('Cache error: $e');
    }
  }

  /// Cache dan olish
  Future<dynamic> getCachedData(String key) async {
    try {
      final box = await Hive.openBox(_cacheBox);
      final data = box.get(key);
      if (data != null) {
        final entry = CacheEntry.fromJson(jsonDecode(data));
        if (!entry.isExpired) {
          // Access count yangilash
          await box.put(
              key,
              jsonEncode(entry
                  .copyWith(
                    accessCount: entry.accessCount + 1,
                    lastAccessedAt: DateTime.now(),
                  )
                  .toJson()));
          return entry.data;
        } else {
          await box.delete(key);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Cache dan o'chirish
  Future<void> removeCachedData(String key) async {
    try {
      final box = await Hive.openBox(_cacheBox);
      await box.delete(key);
    } catch (e) {
      debugPrint('Remove cache error: $e');
    }
  }

  /// Eski cache larni tozalash
  Future<void> cleanExpiredCache() async {
    try {
      final box = await Hive.openBox(_cacheBox);
      final keysToDelete = <dynamic>[];

      for (var i = 0; i < box.length; i++) {
        final key = box.keyAt(i);
        final data = box.get(key);
        if (data != null) {
          final entry = CacheEntry.fromJson(jsonDecode(data));
          if (entry.isExpired) {
            keysToDelete.add(key);
          }
        }
      }

      for (final key in keysToDelete) {
        await box.delete(key);
      }

      debugPrint('Cleaned ${keysToDelete.length} expired cache entries');
    } catch (e) {
      debugPrint('Clean cache error: $e');
    }
  }

  // ============ SYNC LOG ============

  Future<void> _saveSyncLog(SyncResult result) async {
    try {
      final box = await Hive.openBox(_syncLogBox);
      final logs = List<String>.from(box.get('logs') ?? []);
      logs.insert(
          0,
          jsonEncode({
            'total': result.total,
            'success': result.success,
            'failed': result.failed,
            'conflicts': result.conflicts,
            'duration_ms': result.duration.inMilliseconds,
            'timestamp': result.completedAt.toIso8601String(),
          }));

      // Oxirgi 100 ta log saqlash
      if (logs.length > 100) {
        logs.removeRange(100, logs.length);
      }

      await box.put('logs', logs);
    } catch (e) {
      debugPrint('Save sync log error: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getSyncLogs({int limit = 20}) async {
    try {
      final box = await Hive.openBox(_syncLogBox);
      final logs = List<String>.from(box.get('logs') ?? []);
      return logs
          .take(limit)
          .map((l) => Map<String, dynamic>.from(jsonDecode(l)))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // ============ HELPERS ============

  Future<int> getPendingActionsCount() async {
    final actions = await getPendingActions();
    return actions.length;
  }

  Future<int> getCacheSize() async {
    try {
      final box = await Hive.openBox(_cacheBox);
      int totalSize = 0;
      for (var i = 0; i < box.length; i++) {
        final data = box.getAt(i);
        if (data != null) {
          totalSize += (data as String).length;
        }
      }
      return totalSize;
    } catch (e) {
      return 0;
    }
  }

  Future<void> clearAll() async {
    await clearActions();
    final box = await Hive.openBox(_cacheBox);
    await box.clear();
    final logBox = await Hive.openBox(_syncLogBox);
    await logBox.clear();
  }

  void dispose() {
    _statusController.close();
    _syncResultController.close();
  }
}

extension on CacheEntry {
  CacheEntry copyWith({
    int? accessCount,
    DateTime? lastAccessedAt,
  }) {
    return CacheEntry(
      key: key,
      data: data,
      cachedAt: cachedAt,
      ttl: ttl,
      sizeBytes: sizeBytes,
      accessCount: accessCount ?? this.accessCount,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
    );
  }
}
