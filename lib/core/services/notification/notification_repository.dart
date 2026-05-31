import 'package:dartz/dartz.dart';
import '../../errors/failures.dart';
import 'models/notification_models.dart';

// ============================================================
// NOTIFICATION REPOSITORY
// ============================================================

abstract class NotificationRepository {
  /// Bildirishnomalarni olish
  Future<Either<Failure, List<AppNotification>>> getNotifications({
    int page = 1,
    int limit = 20,
    bool? isRead,
    NotificationType? type,
  });

  /// O'qilmagan soni
  Future<Either<Failure, int>> getUnreadCount();

  /// O'qilgan deb belgilash
  Future<Either<Failure, bool>> markAsRead(String notificationId);

  /// Barchasini o'qilgan deb belgilash
  Future<Either<Failure, bool>> markAllAsRead();

  /// O'chirish
  Future<Either<Failure, bool>> deleteNotification(String notificationId);

  /// Barchasini o'chirish
  Future<Either<Failure, bool>> deleteAllNotifications();

  /// FCM token serverga yuborish
  Future<Either<Failure, bool>> registerToken(String token);

  /// FCM token o'chirish
  Future<Either<Failure, bool>> unregisterToken(String token);

  /// Sozlamalarni olish
  Future<Either<Failure, NotificationSettings>> getSettings();

  /// Sozlamalarni saqlash
  Future<Either<Failure, bool>> saveSettings(NotificationSettings settings);
}

class NotificationRepositoryImpl implements NotificationRepository {
  final List<AppNotification> _items = [];
  final Set<String> _registeredTokens = {};
  NotificationSettings _settings = const NotificationSettings(
    pushEnabled: true,
    soundEnabled: true,
    vibrationEnabled: true,
    channelSettings: {
      'orders_channel': true,
      'payments_channel': true,
      'delivery_channel': true,
      'tasks_channel': true,
      'promos_channel': true,
      'system_channel': true,
      'sync_channel': true,
    },
  );

  void addLocalNotification(AppNotification notification) {
    _items.insert(0, notification);
  }

  @override
  Future<Either<Failure, List<AppNotification>>> getNotifications({
    int page = 1,
    int limit = 20,
    bool? isRead,
    NotificationType? type,
  }) async {
    try {
      var items = _items.where((item) {
        final readMatches = isRead == null || item.isRead == isRead;
        final typeMatches = type == null || item.type == type;
        return readMatches && typeMatches;
      }).toList();
      final start = (page - 1) * limit;
      if (start >= items.length) return const Right([]);
      items = items.skip(start).take(limit).toList();
      return Right(items);
    } catch (e) {
      return Left(ServerFailure(message: 'Bildirishnomalar yuklanmadi'));
    }
  }

  @override
  Future<Either<Failure, int>> getUnreadCount() async {
    try {
      return Right(_items.where((item) => !item.isRead).length);
    } catch (e) {
      return Left(ServerFailure(message: 'Soni yuklanmadi'));
    }
  }

  @override
  Future<Either<Failure, bool>> markAsRead(String notificationId) async {
    try {
      final index = _items.indexWhere((item) => item.id == notificationId);
      if (index == -1)
        return const Left(NotFoundFailure(resource: 'Bildirishnoma'));
      _items[index] = _items[index].markAsRead();
      return const Right(true);
    } catch (e) {
      return Left(ServerFailure(message: 'Xatolik'));
    }
  }

  @override
  Future<Either<Failure, bool>> markAllAsRead() async {
    try {
      for (var i = 0; i < _items.length; i++) {
        _items[i] = _items[i].markAsRead();
      }
      return const Right(true);
    } catch (e) {
      return Left(ServerFailure(message: 'Xatolik'));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteNotification(
      String notificationId) async {
    try {
      _items.removeWhere((item) => item.id == notificationId);
      return const Right(true);
    } catch (e) {
      return Left(ServerFailure(message: 'Xatolik'));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteAllNotifications() async {
    try {
      _items.clear();
      return const Right(true);
    } catch (e) {
      return Left(ServerFailure(message: 'Xatolik'));
    }
  }

  @override
  Future<Either<Failure, bool>> registerToken(String token) async {
    try {
      if (token.trim().isEmpty)
        return const Left(ValidationFailure(message: 'Token bo‘sh'));
      _registeredTokens.add(token);
      return const Right(true);
    } catch (e) {
      return Left(ServerFailure(message: 'Token yuborilmadi'));
    }
  }

  @override
  Future<Either<Failure, bool>> unregisterToken(String token) async {
    try {
      _registeredTokens.remove(token);
      return const Right(true);
    } catch (e) {
      return Left(ServerFailure(message: 'Token o\'chirilmadi'));
    }
  }

  @override
  Future<Either<Failure, NotificationSettings>> getSettings() async {
    try {
      return Right(_settings);
    } catch (e) {
      return Left(ServerFailure(message: 'Sozlamalar yuklanmadi'));
    }
  }

  @override
  Future<Either<Failure, bool>> saveSettings(
      NotificationSettings settings) async {
    try {
      _settings = settings;
      return const Right(true);
    } catch (e) {
      return Left(ServerFailure(message: 'Sozlamalar saqlanmadi'));
    }
  }
}
