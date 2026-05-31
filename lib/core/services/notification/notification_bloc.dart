import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'models/notification_models.dart';
import 'push_notification_service.dart';
import 'notification_repository.dart';

// ============================================================
// NOTIFICATION BLOC - Bildirishnomalar boshqaruvi
// ============================================================

// ============ EVENTS ============

abstract class NotificationEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class NotificationInitialize extends NotificationEvent {}

class NotificationLoadRequested extends NotificationEvent {
  final int page;
  final bool? isRead;
  final NotificationType? type;
  NotificationLoadRequested({this.page = 1, this.isRead, this.type});
}

class NotificationUnreadCountRequested extends NotificationEvent {}

class NotificationMarkAsRead extends NotificationEvent {
  final String notificationId;
  NotificationMarkAsRead(this.notificationId);
}

class NotificationMarkAllAsRead extends NotificationEvent {}

class NotificationDelete extends NotificationEvent {
  final String notificationId;
  NotificationDelete(this.notificationId);
}

class NotificationDeleteAll extends NotificationEvent {}

class NotificationReceived extends NotificationEvent {
  final AppNotification notification;
  NotificationReceived(this.notification);
}

class NotificationSettingsLoadRequested extends NotificationEvent {}

class NotificationSettingsUpdateRequested extends NotificationEvent {
  final NotificationSettings settings;
  NotificationSettingsUpdateRequested(this.settings);
}

class NotificationPermissionRequested extends NotificationEvent {}

// ============ STATES ============

abstract class NotificationState extends Equatable {
  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationPermissionGranted extends NotificationState {}

class NotificationPermissionDenied extends NotificationState {}

class NotificationsLoaded extends NotificationState {
  final List<AppNotification> notifications;
  final bool hasMore;
  final int currentPage;
  final int unreadCount;

  NotificationsLoaded({
    required this.notifications,
    required this.hasMore,
    required this.currentPage,
    required this.unreadCount,
  });
}

class NotificationUnreadCountLoaded extends NotificationState {
  final int count;
  NotificationUnreadCountLoaded(this.count);
}

class NotificationMarkedAsRead extends NotificationState {
  final String notificationId;
  NotificationMarkedAsRead(this.notificationId);
}

class NotificationAllMarkedAsRead extends NotificationState {}

class NotificationDeleted extends NotificationState {
  final String notificationId;
  NotificationDeleted(this.notificationId);
}

class NotificationAllDeleted extends NotificationState {}

class NotificationNewReceived extends NotificationState {
  final AppNotification notification;
  final int unreadCount;
  NotificationNewReceived(
      {required this.notification, required this.unreadCount});
}

class NotificationSettingsLoaded extends NotificationState {
  final NotificationSettings settings;
  NotificationSettingsLoaded(this.settings);
}

class NotificationSettingsUpdated extends NotificationState {
  final NotificationSettings settings;
  NotificationSettingsUpdated(this.settings);
}

class NotificationError extends NotificationState {
  final String message;
  NotificationError(this.message);
}

// ============ BLOC ============

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final PushNotificationService _notificationService;
  final NotificationRepository _repository;
  StreamSubscription<AppNotification>? _notificationSubscription;

  NotificationBloc({
    required PushNotificationService notificationService,
    required NotificationRepository repository,
  })  : _notificationService = notificationService,
        _repository = repository,
        super(NotificationInitial()) {
    on<NotificationInitialize>(_onInitialize);
    on<NotificationLoadRequested>(_onLoad);
    on<NotificationUnreadCountRequested>(_onUnreadCount);
    on<NotificationMarkAsRead>(_onMarkAsRead);
    on<NotificationMarkAllAsRead>(_onMarkAllAsRead);
    on<NotificationDelete>(_onDelete);
    on<NotificationDeleteAll>(_onDeleteAll);
    on<NotificationReceived>(_onReceived);
    on<NotificationSettingsLoadRequested>(_onSettingsLoad);
    on<NotificationSettingsUpdateRequested>(_onSettingsUpdate);
    on<NotificationPermissionRequested>(_onPermission);
  }

  // ============ INITIALIZE ============

  Future<void> _onInitialize(
    NotificationInitialize event,
    Emitter<NotificationState> emit,
  ) async {
    // Service init
    await _notificationService.initialize();

    // Stream tinglash
    _notificationSubscription = _notificationService.notificationStream.listen(
      (notification) => add(NotificationReceived(notification)),
    );

    // O'qilmagan sonini olish
    add(NotificationUnreadCountRequested());
  }

  // ============ LOAD ============

  Future<void> _onLoad(
    NotificationLoadRequested event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());

    final result = await _repository.getNotifications(
      page: event.page,
      isRead: event.isRead,
      type: event.type,
    );

    final unreadResult = await _repository.getUnreadCount();

    result.fold(
      (failure) => emit(NotificationError(failure.message)),
      (notifications) {
        int unreadCount = 0;
        unreadResult.fold((_) {}, (count) => unreadCount = count);

        emit(NotificationsLoaded(
          notifications: notifications,
          hasMore: notifications.length >= 20,
          currentPage: event.page,
          unreadCount: unreadCount,
        ));
      },
    );
  }

  // ============ UNREAD COUNT ============

  Future<void> _onUnreadCount(
    NotificationUnreadCountRequested event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await _repository.getUnreadCount();
    result.fold(
      (failure) {},
      (count) => emit(NotificationUnreadCountLoaded(count)),
    );
  }

  // ============ MARK AS READ ============

  Future<void> _onMarkAsRead(
    NotificationMarkAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await _repository.markAsRead(event.notificationId);
    result.fold(
      (failure) => emit(NotificationError(failure.message)),
      (_) => emit(NotificationMarkedAsRead(event.notificationId)),
    );
  }

  Future<void> _onMarkAllAsRead(
    NotificationMarkAllAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await _repository.markAllAsRead();
    result.fold(
      (failure) => emit(NotificationError(failure.message)),
      (_) => emit(NotificationAllMarkedAsRead()),
    );
  }

  // ============ DELETE ============

  Future<void> _onDelete(
    NotificationDelete event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await _repository.deleteNotification(event.notificationId);
    result.fold(
      (failure) => emit(NotificationError(failure.message)),
      (_) => emit(NotificationDeleted(event.notificationId)),
    );
  }

  Future<void> _onDeleteAll(
    NotificationDeleteAll event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await _repository.deleteAllNotifications();
    result.fold(
      (failure) => emit(NotificationError(failure.message)),
      (_) => emit(NotificationAllDeleted()),
    );
  }

  // ============ RECEIVED ============

  Future<void> _onReceived(
    NotificationReceived event,
    Emitter<NotificationState> emit,
  ) async {
    final unreadResult = await _repository.getUnreadCount();
    final unreadCount = unreadResult.fold((_) => 0, (count) => count);
    emit(NotificationNewReceived(
        notification: event.notification, unreadCount: unreadCount));
  }

  // ============ SETTINGS ============

  Future<void> _onSettingsLoad(
    NotificationSettingsLoadRequested event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await _repository.getSettings();
    result.fold(
      (failure) => emit(NotificationError(failure.message)),
      (settings) => emit(NotificationSettingsLoaded(settings)),
    );
  }

  Future<void> _onSettingsUpdate(
    NotificationSettingsUpdateRequested event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await _repository.saveSettings(event.settings);
    result.fold(
      (failure) => emit(NotificationError(failure.message)),
      (_) => emit(NotificationSettingsUpdated(event.settings)),
    );
  }

  // ============ PERMISSION ============

  Future<void> _onPermission(
    NotificationPermissionRequested event,
    Emitter<NotificationState> emit,
  ) async {
    final granted = await _notificationService.requestPermission();
    if (granted) {
      emit(NotificationPermissionGranted());
    } else {
      emit(NotificationPermissionDenied());
    }
  }

  @override
  Future<void> close() {
    _notificationSubscription?.cancel();
    return super.close();
  }
}
