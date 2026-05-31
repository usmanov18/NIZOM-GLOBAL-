import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'models/offline_models.dart';
import 'offline_service.dart';

// ============================================================
// OFFLINE BLOC - Offline holat boshqaruvi
// ============================================================

// ============ EVENTS ============

abstract class OfflineEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class OfflineInitialize extends OfflineEvent {}

class OfflineStatusChanged extends OfflineEvent {
  final OfflineStatus status;
  OfflineStatusChanged(this.status);
}

class OfflineActionSaveRequested extends OfflineEvent {
  final OfflineAction action;
  OfflineActionSaveRequested(this.action);
}

class OfflineSyncRequested extends OfflineEvent {}

class OfflinePendingActionsLoadRequested extends OfflineEvent {}

class OfflineSyncLogLoadRequested extends OfflineEvent {}

class OfflineCacheSaveRequested extends OfflineEvent {
  final String key;
  final dynamic data;
  final Duration? ttl;
  OfflineCacheSaveRequested({required this.key, required this.data, this.ttl});
}

class OfflineCacheLoadRequested extends OfflineEvent {
  final String key;
  OfflineCacheLoadRequested(this.key);
}

class OfflineCacheCleanRequested extends OfflineEvent {}

class OfflineClearAllRequested extends OfflineEvent {}

// ============ STATES ============

abstract class OfflineState extends Equatable {
  @override
  List<Object?> get props => [];
}

class OfflineInitial extends OfflineState {}

class OfflineStatusState extends OfflineState {
  final OfflineStatus status;
  final bool isOnline;
  final bool isSyncing;
  final int pendingCount;

  OfflineStatusState({
    required this.status,
    required this.isOnline,
    required this.isSyncing,
    required this.pendingCount,
  });
}

class OfflineActionSaved extends OfflineState {
  final String actionId;
  OfflineActionSaved(this.actionId);
}

class OfflineSyncInProgress extends OfflineState {
  final int total;
  final int completed;
  OfflineSyncInProgress({required this.total, required this.completed});
}

class OfflineSyncCompletedState extends OfflineState {
  final SyncResult result;
  OfflineSyncCompletedState(this.result);
}

class OfflinePendingActionsLoaded extends OfflineState {
  final List<OfflineAction> actions;
  OfflinePendingActionsLoaded(this.actions);
}

class OfflineSyncLogLoaded extends OfflineState {
  final List<Map<String, dynamic>> logs;
  OfflineSyncLogLoaded(this.logs);
}

class OfflineCacheLoaded extends OfflineState {
  final String key;
  final dynamic data;
  OfflineCacheLoaded({required this.key, required this.data});
}

class OfflineCacheSaved extends OfflineState {
  final String key;
  OfflineCacheSaved(this.key);
}

class OfflineCleared extends OfflineState {}

class OfflineError extends OfflineState {
  final String message;
  OfflineError(this.message);
}

// ============ BLOC ============

class OfflineBloc extends Bloc<OfflineEvent, OfflineState> {
  final OfflineService _service;
  StreamSubscription<OfflineStatus>? _statusSubscription;
  StreamSubscription<SyncResult>? _syncSubscription;

  OfflineBloc({required OfflineService service})
      : _service = service,
        super(OfflineInitial()) {
    on<OfflineInitialize>(_onInitialize);
    on<OfflineStatusChanged>(_onStatusChanged);
    on<OfflineActionSaveRequested>(_onActionSave);
    on<OfflineSyncRequested>(_onSync);
    on<OfflinePendingActionsLoadRequested>(_onPendingLoad);
    on<OfflineSyncLogLoadRequested>(_onSyncLogLoad);
    on<OfflineCacheSaveRequested>(_onCacheSave);
    on<OfflineCacheLoadRequested>(_onCacheLoad);
    on<OfflineCacheCleanRequested>(_onCacheClean);
    on<OfflineClearAllRequested>(_onClearAll);
  }

  Future<void> _onInitialize(
    OfflineInitialize event,
    Emitter<OfflineState> emit,
  ) async {
    await _service.initialize();

    _statusSubscription = _service.statusStream.listen(
      (status) => add(OfflineStatusChanged(status)),
    );

    _syncSubscription = _service.syncResultStream.listen(
      (result) {
        // Sync result
      },
    );

    final pendingCount = await _service.getPendingActionsCount();

    emit(OfflineStatusState(
      status: _service.status,
      isOnline: _service.isOnline,
      isSyncing: _service.isSyncing,
      pendingCount: pendingCount,
    ));
  }

  void _onStatusChanged(
    OfflineStatusChanged event,
    Emitter<OfflineState> emit,
  ) async {
    final pendingCount = await _service.getPendingActionsCount();

    emit(OfflineStatusState(
      status: event.status,
      isOnline: event.status == OfflineStatus.online,
      isSyncing: event.status == OfflineStatus.syncing,
      pendingCount: pendingCount,
    ));
  }

  Future<void> _onActionSave(
    OfflineActionSaveRequested event,
    Emitter<OfflineState> emit,
  ) async {
    await _service.saveAction(event.action);
    emit(OfflineActionSaved(event.action.id));
  }

  Future<void> _onSync(
    OfflineSyncRequested event,
    Emitter<OfflineState> emit,
  ) async {
    final result = await _service.syncPendingActions();
    emit(OfflineSyncCompletedState(result));
  }

  Future<void> _onPendingLoad(
    OfflinePendingActionsLoadRequested event,
    Emitter<OfflineState> emit,
  ) async {
    final actions = await _service.getPendingActions();
    emit(OfflinePendingActionsLoaded(actions));
  }

  Future<void> _onSyncLogLoad(
    OfflineSyncLogLoadRequested event,
    Emitter<OfflineState> emit,
  ) async {
    final logs = await _service.getSyncLogs();
    emit(OfflineSyncLogLoaded(logs));
  }

  Future<void> _onCacheSave(
    OfflineCacheSaveRequested event,
    Emitter<OfflineState> emit,
  ) async {
    await _service.cacheData(event.key, event.data, ttl: event.ttl);
    emit(OfflineCacheSaved(event.key));
  }

  Future<void> _onCacheLoad(
    OfflineCacheLoadRequested event,
    Emitter<OfflineState> emit,
  ) async {
    final data = await _service.getCachedData(event.key);
    emit(OfflineCacheLoaded(key: event.key, data: data));
  }

  Future<void> _onCacheClean(
    OfflineCacheCleanRequested event,
    Emitter<OfflineState> emit,
  ) async {
    await _service.cleanExpiredCache();
  }

  Future<void> _onClearAll(
    OfflineClearAllRequested event,
    Emitter<OfflineState> emit,
  ) async {
    await _service.clearAll();
    emit(OfflineCleared());
  }

  @override
  Future<void> close() {
    _statusSubscription?.cancel();
    _syncSubscription?.cancel();
    return super.close();
  }
}
