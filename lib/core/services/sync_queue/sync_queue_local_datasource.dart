import 'dart:convert';
import 'package:hive/hive.dart';

import 'sync_queue_models.dart';

class SyncQueueLocalDataSource {
  static const _boxName = 'sync_queue';
  static const _itemsKey = 'items';

  Future<List<SyncQueueItem>> getAll() async {
    final box = await Hive.openBox(_boxName);
    final raw = box.get(_itemsKey);
    if (raw == null) return [];
    final list = List<Map<String, dynamic>>.from(jsonDecode(raw));
    return list.map(SyncQueueItem.fromJson).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> _saveAll(List<SyncQueueItem> items) async {
    final box = await Hive.openBox(_boxName);
    await box.put(_itemsKey, jsonEncode(items.map((e) => e.toJson()).toList()));
  }

  Future<void> upsert(SyncQueueItem item) async {
    final items = await getAll();
    final index = items.indexWhere(
        (e) => e.id == item.id || e.idempotencyKey == item.idempotencyKey);
    if (index >= 0) {
      items[index] = item;
    } else {
      items.add(item);
    }
    await _saveAll(items);
  }

  Future<SyncQueueItem?> getByEntity(
      SyncEntityType type, String entityId) async {
    final items = await getAll();
    final matches =
        items.where((e) => e.entityType == type && e.entityId == entityId);
    return matches.isEmpty ? null : matches.first;
  }

  Future<List<SyncQueueItem>> getByStatus(SyncQueueStatus status) async {
    final items = await getAll();
    return items.where((e) => e.status == status).toList();
  }

  Future<List<SyncQueueItem>> getPendingWork() async {
    final now = DateTime.now();
    final items = await getAll();
    return items.where((e) {
      if (e.status == SyncQueueStatus.pending) return true;
      if (e.status == SyncQueueStatus.failed && e.canRetry) {
        return e.nextRetryAt == null || !e.nextRetryAt!.isAfter(now);
      }
      return false;
    }).toList();
  }

  Future<void> markProcessing(String id) async {
    final items = await getAll();
    final index = items.indexWhere((e) => e.id == id);
    if (index < 0) return;
    final current = items[index];
    items[index] = current.copyWith(
      status: SyncQueueStatus.processing,
      updatedAt: DateTime.now(),
      attempts: [
        ...current.attempts,
        SyncAttempt(
            attempt: current.retryCount + 1,
            status: SyncQueueStatus.processing,
            createdAt: DateTime.now()),
      ],
    );
    await _saveAll(items);
  }

  Future<void> markSuccess(String id) async {
    final items = await getAll();
    final index = items.indexWhere((e) => e.id == id);
    if (index < 0) return;
    final current = items[index];
    items[index] = current.copyWith(
      status: SyncQueueStatus.success,
      updatedAt: DateTime.now(),
      processedAt: DateTime.now(),
      lastError: null,
      attempts: [
        ...current.attempts,
        SyncAttempt(
            attempt: current.retryCount + 1,
            status: SyncQueueStatus.success,
            createdAt: DateTime.now()),
      ],
    );
    await _saveAll(items);
  }

  SyncFailureCategory _categorizeError(String error) {
    final e = error.toLowerCase();
    if (e.contains('network') ||
        e.contains('internet') ||
        e.contains('timeout') ||
        e.contains('connection')) return SyncFailureCategory.network;
    if (e.contains('validation') ||
        e.contains('majburiy') ||
        e.contains('sklad') ||
        e.contains('payload')) return SyncFailureCategory.validation;
    if (e.contains('auth') || e.contains('401') || e.contains('token'))
      return SyncFailureCategory.auth;
    if (e.contains('conflict') || e.contains('409') || e.contains('duplicate'))
      return SyncFailureCategory.conflict;
    if (e.contains('unsupported') || e.contains('qo‘llab-quvvatlanmaydi'))
      return SyncFailureCategory.unsupported;
    if (e.contains('500') || e.contains('server'))
      return SyncFailureCategory.server;
    return SyncFailureCategory.unknown;
  }

  Future<void> markFailed(String id, String error) async {
    final items = await getAll();
    final index = items.indexWhere((e) => e.id == id);
    if (index < 0) return;
    final current = items[index];
    final retry = current.retryCount + 1;
    final category = _categorizeError(error);
    items[index] = current.copyWith(
      status: SyncQueueStatus.failed,
      retryCount: retry,
      lastError: error,
      failureCategory: category,
      updatedAt: DateTime.now(),
      nextRetryAt: DateTime.now().add(Duration(minutes: retry * 2)),
      attempts: [
        ...current.attempts,
        SyncAttempt(
            attempt: retry,
            status: SyncQueueStatus.failed,
            error: error,
            category: category,
            createdAt: DateTime.now()),
      ],
    );
    await _saveAll(items);
  }

  Future<void> remove(String id) async {
    final items = await getAll();
    items.removeWhere((e) => e.id == id);
    await _saveAll(items);
  }
}
