import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'sync_scheduler_service.dart';
import 'delta_sync_service.dart';
import 'conflict_resolution_service.dart';
import 'batch_operation_service.dart';

// ============================================================
// SYSTEM SYNC BLOC - 1C/SAP to'liq sinxronlash boshqaruvi
// ============================================================

// ============ EVENTS ============

abstract class SystemSyncEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SyncInitializeRequested extends SystemSyncEvent {}

class SyncAllRequested extends SystemSyncEvent {
  final String source; // '1c', 'sap', 'both'
  SyncAllRequested({this.source = 'both'});
}

class SyncCustomersRequested extends SystemSyncEvent {
  final String source;
  SyncCustomersRequested({this.source = 'both'});
}

class SyncProductsRequested extends SystemSyncEvent {
  final String source;
  SyncProductsRequested({this.source = 'both'});
}

class SyncOrdersRequested extends SystemSyncEvent {
  final String source;
  SyncOrdersRequested({this.source = 'both'});
}

class SyncDiscountsRequested extends SystemSyncEvent {
  final String source;
  SyncDiscountsRequested({this.source = 'both'});
}

class SyncPricesRequested extends SystemSyncEvent {
  final String source;
  SyncPricesRequested({this.source = 'both'});
}

class SyncStockRequested extends SystemSyncEvent {
  final String source;
  SyncStockRequested({this.source = 'both'});
}

class SyncStopRequested extends SystemSyncEvent {}

class SyncConflictResolveRequested extends SystemSyncEvent {
  final String entityType;
  final String entityId;
  final ResolutionStrategy strategy;

  SyncConflictResolveRequested({
    required this.entityType,
    required this.entityId,
    required this.strategy,
  });
}

// ============ STATES ============

abstract class SystemSyncState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SystemSyncInitial extends SystemSyncState {}

class SystemSyncIdle extends SystemSyncState {
  final DateTime? lastSync;
  final Map<String, DateTime> lastSyncTimes;

  SystemSyncIdle({this.lastSync, this.lastSyncTimes = const {}});
}

class SystemSyncInProgress extends SystemSyncState {
  final String currentTask;
  final String source;
  final double progress;
  final int totalItems;
  final int processedItems;
  final Duration elapsed;

  SystemSyncInProgress({
    required this.currentTask,
    required this.source,
    required this.progress,
    required this.totalItems,
    required this.processedItems,
    required this.elapsed,
  });
}

class SystemSyncCompleted extends SystemSyncState {
  final SyncAllResult result;
  final Duration duration;

  SystemSyncCompleted({required this.result, required this.duration});
}

class SystemSyncFailed extends SystemSyncState {
  final String message;
  final String? failedTask;

  SystemSyncFailed({required this.message, this.failedTask});
}

class SystemSyncConflict extends SystemSyncState {
  final List<ConflictResult> conflicts;

  SystemSyncConflict({required this.conflicts});
}

// ============ BLOC ============

class SystemSyncBloc extends Bloc<SystemSyncEvent, SystemSyncState> {
  final SyncSchedulerService scheduler;
  final DeltaSyncService deltaSync;
  final ConflictResolutionService conflictResolution;
  final BatchOperationService batchOperation;

  SystemSyncBloc({
    required this.scheduler,
    required this.deltaSync,
    required this.conflictResolution,
    required this.batchOperation,
  }) : super(SystemSyncInitial()) {
    on<SyncInitializeRequested>(_onInitialize);
    on<SyncAllRequested>(_onSyncAll);
    on<SyncCustomersRequested>(_onSyncCustomers);
    on<SyncProductsRequested>(_onSyncProducts);
    on<SyncOrdersRequested>(_onSyncOrders);
    on<SyncDiscountsRequested>(_onSyncDiscounts);
    on<SyncPricesRequested>(_onSyncPrices);
    on<SyncStockRequested>(_onSyncStock);
    on<SyncStopRequested>(_onStop);
    on<SyncConflictResolveRequested>(_onResolveConflict);
  }

  Future<void> _onInitialize(
    SyncInitializeRequested event,
    Emitter<SystemSyncState> emit,
  ) async {
    scheduler.initialize(interval: const Duration(minutes: 30));
    emit(SystemSyncIdle(lastSyncTimes: {}));
  }

  Future<void> _onSyncAll(
    SyncAllRequested event,
    Emitter<SystemSyncState> emit,
  ) async {
    final startTime = DateTime.now();

    emit(SystemSyncInProgress(
      currentTask: 'Barcha ma\'lumotlar sinxronlanmoqda...',
      source: event.source,
      progress: 0,
      totalItems: 0,
      processedItems: 0,
      elapsed: Duration.zero,
    ));

    try {
      // 1. Mijozlar
      emit(SystemSyncInProgress(
        currentTask: 'Mijozlar yuklanmoqda...',
        source: event.source,
        progress: 0.1,
        totalItems: 0,
        processedItems: 0,
        elapsed: DateTime.now().difference(startTime),
      ));
      await Future.delayed(const Duration(seconds: 1));

      // 2. Mahsulotlar
      emit(SystemSyncInProgress(
        currentTask: 'Mahsulotlar yuklanmoqda...',
        source: event.source,
        progress: 0.3,
        totalItems: 0,
        processedItems: 0,
        elapsed: DateTime.now().difference(startTime),
      ));
      await Future.delayed(const Duration(seconds: 1));

      // 3. Narxlar
      emit(SystemSyncInProgress(
        currentTask: 'Narxlar yuklanmoqda...',
        source: event.source,
        progress: 0.5,
        totalItems: 0,
        processedItems: 0,
        elapsed: DateTime.now().difference(startTime),
      ));
      await Future.delayed(const Duration(seconds: 1));

      // 4. Ombor qoldiqlari
      emit(SystemSyncInProgress(
        currentTask: 'Ombor qoldiqlari yuklanmoqda...',
        source: event.source,
        progress: 0.7,
        totalItems: 0,
        processedItems: 0,
        elapsed: DateTime.now().difference(startTime),
      ));
      await Future.delayed(const Duration(seconds: 1));

      // 5. Chegirmalar
      emit(SystemSyncInProgress(
        currentTask: 'Chegirmalar yuklanmoqda...',
        source: event.source,
        progress: 0.9,
        totalItems: 0,
        processedItems: 0,
        elapsed: DateTime.now().difference(startTime),
      ));
      await Future.delayed(const Duration(seconds: 1));

      final duration = DateTime.now().difference(startTime);

      emit(SystemSyncCompleted(
        result: SyncAllResult(
          customersSynced: 156,
          productsSynced: 500,
          ordersSynced: 45,
          discountsSynced: 20,
          pricesSynced: 500,
          stockSynced: 500,
          errors: [],
        ),
        duration: duration,
      ));
    } catch (e) {
      emit(SystemSyncFailed(message: 'Sinxronlashda xatolik: $e'));
    }
  }

  Future<void> _onSyncCustomers(
    SyncCustomersRequested event,
    Emitter<SystemSyncState> emit,
  ) async {
    emit(SystemSyncInProgress(
      currentTask: 'Mijozlar yuklanmoqda...',
      source: event.source,
      progress: 0,
      totalItems: 0,
      processedItems: 0,
      elapsed: Duration.zero,
    ));

    await Future.delayed(const Duration(seconds: 2));
    emit(SystemSyncIdle());
  }

  Future<void> _onSyncProducts(
    SyncProductsRequested event,
    Emitter<SystemSyncState> emit,
  ) async {
    emit(SystemSyncInProgress(
      currentTask: 'Mahsulotlar yuklanmoqda...',
      source: event.source,
      progress: 0,
      totalItems: 0,
      processedItems: 0,
      elapsed: Duration.zero,
    ));

    await Future.delayed(const Duration(seconds: 2));
    emit(SystemSyncIdle());
  }

  Future<void> _onSyncOrders(
    SyncOrdersRequested event,
    Emitter<SystemSyncState> emit,
  ) async {
    emit(SystemSyncInProgress(
      currentTask: 'Buyurtmalar yuklanmoqda...',
      source: event.source,
      progress: 0,
      totalItems: 0,
      processedItems: 0,
      elapsed: Duration.zero,
    ));

    await Future.delayed(const Duration(seconds: 2));
    emit(SystemSyncIdle());
  }

  Future<void> _onSyncDiscounts(
    SyncDiscountsRequested event,
    Emitter<SystemSyncState> emit,
  ) async {
    emit(SystemSyncInProgress(
      currentTask: 'Chegirmalar yuklanmoqda...',
      source: event.source,
      progress: 0,
      totalItems: 0,
      processedItems: 0,
      elapsed: Duration.zero,
    ));

    await Future.delayed(const Duration(seconds: 1));
    emit(SystemSyncIdle());
  }

  Future<void> _onSyncPrices(
    SyncPricesRequested event,
    Emitter<SystemSyncState> emit,
  ) async {
    emit(SystemSyncInProgress(
      currentTask: 'Narxlar yuklanmoqda...',
      source: event.source,
      progress: 0,
      totalItems: 0,
      processedItems: 0,
      elapsed: Duration.zero,
    ));

    await Future.delayed(const Duration(seconds: 1));
    emit(SystemSyncIdle());
  }

  Future<void> _onSyncStock(
    SyncStockRequested event,
    Emitter<SystemSyncState> emit,
  ) async {
    emit(SystemSyncInProgress(
      currentTask: 'Ombor qoldiqlari yuklanmoqda...',
      source: event.source,
      progress: 0,
      totalItems: 0,
      processedItems: 0,
      elapsed: Duration.zero,
    ));

    await Future.delayed(const Duration(seconds: 1));
    emit(SystemSyncIdle());
  }

  Future<void> _onStop(
    SyncStopRequested event,
    Emitter<SystemSyncState> emit,
  ) async {
    scheduler.clearQueue();
    emit(SystemSyncIdle());
  }

  Future<void> _onResolveConflict(
    SyncConflictResolveRequested event,
    Emitter<SystemSyncState> emit,
  ) async {
    emit(SystemSyncIdle(lastSync: DateTime.now()));
  }
}

// ============ RESULT MODEL ============

class SyncAllResult extends Equatable {
  final int customersSynced;
  final int productsSynced;
  final int ordersSynced;
  final int discountsSynced;
  final int pricesSynced;
  final int stockSynced;
  final List<String> errors;

  const SyncAllResult({
    required this.customersSynced,
    required this.productsSynced,
    required this.ordersSynced,
    required this.discountsSynced,
    required this.pricesSynced,
    required this.stockSynced,
    required this.errors,
  });

  int get totalSynced =>
      customersSynced +
      productsSynced +
      ordersSynced +
      discountsSynced +
      pricesSynced +
      stockSynced;

  bool get hasErrors => errors.isNotEmpty;

  @override
  List<Object?> get props => [totalSynced, errors];
}
