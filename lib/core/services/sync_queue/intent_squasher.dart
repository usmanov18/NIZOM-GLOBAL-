import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'sync_queue_models.dart';

class IntentSquasher {
  static List<SyncQueueItem> squash(List<SyncQueueItem> items,
      {String userId = 'sys'}) {
    final Map<String, List<SyncQueueItem>> grouped = {};
    for (var item in items) {
      grouped.putIfAbsent(item.entityId, () => []).add(item);
    }

    final List<SyncQueueItem> result = [];
    grouped.forEach((entityId, history) {
      bool hasCreate = history.any((i) => i.payload['action'] == 'create');
      bool isFinallyDeleted = history.last.payload['action'] == 'delete';
      if (hasCreate && isFinallyDeleted) return;

      final lastItem = history.last;

      // 🚀 Hashed Idempotency: Short & Unique
      final rawKey = '${userId}_${entityId}_${const Uuid().v4()}';
      final hashedKey =
          sha1.convert(utf8.encode(rawKey)).toString().substring(0, 20);

      final updatedItem = lastItem.copyWith(
        payload: {
          ...lastItem.payload,
          'idempotencyKey': 'NZ_${userId}_$hashedKey',
          'originTrace': history.map((e) => e.id).toList(),
          'squashedAt': DateTime.now().toIso8601String(),
        },
      );
      result.add(updatedItem);
    });
    return result;
  }
}
