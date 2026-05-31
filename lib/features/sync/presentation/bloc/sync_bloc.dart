import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../customers/domain/entities/customer_sync_entities.dart';
import '../../../customers/domain/repositories/customer_repository.dart';
import '../../../discounts/domain/repositories/discount_repository.dart';

// ============================================================
// SYNC BLOC - Markaziy sinxronlash boshqaruvi
// Mijozlar + Skidkalar + Promolar + Narxlar
// ============================================================

// ============ EVENTS ============

abstract class SyncEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Barcha ma'lumotlarni sinxronlash
class SyncAllRequested extends SyncEvent {
  final String agentId;
  final bool force; // Majburan

  SyncAllRequested({required this.agentId, this.force = false});

  @override
  List<Object?> get props => [agentId, force];
}

/// Faqat mijozlarni sinxronlash
class SyncCustomersRequested extends SyncEvent {
  final String agentId;

  SyncCustomersRequested({required this.agentId});

  @override
  List<Object?> get props => [agentId];
}

/// Faqat chegirmalarni sinxronlash
class SyncDiscountsRequested extends SyncEvent {}

/// Faqat promolarni sinxronlash
class SyncPromotionsRequested extends SyncEvent {}

/// Agent profilini sinxronlash
class SyncAgentProfileRequested extends SyncEvent {
  final String agentId;

  SyncAgentProfileRequested({required this.agentId});

  @override
  List<Object?> get props => [agentId];
}

/// Sinxronlash holatini tekshirish
class CheckSyncStatusRequested extends SyncEvent {}

/// Background sinxronlash
class BackgroundSyncRequested extends SyncEvent {
  final String agentId;

  BackgroundSyncRequested({required this.agentId});
}

// ============ STATES ============

abstract class SyncState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SyncInitial extends SyncState {}

class SyncInProgress extends SyncState {
  final String currentTask;
  final double progress; // 0.0 - 1.0
  final int totalItems;
  final int processedItems;

  SyncInProgress({
    required this.currentTask,
    required this.progress,
    required this.totalItems,
    required this.processedItems,
  });

  @override
  List<Object?> get props => [currentTask, progress];
}

class SyncCompleted extends SyncState {
  final CustomerSyncResult? customerResult;
  final DiscountSyncResult? discountResult;
  final DateTime completedAt;
  final Duration duration;

  SyncCompleted({
    this.customerResult,
    this.discountResult,
    required this.completedAt,
    required this.duration,
  });

  int get totalSynced =>
      (customerResult?.totalCustomers ?? 0) +
      (discountResult?.totalSynced ?? 0);

  bool get hasErrors =>
      customerResult?.hasErrors == true || discountResult?.hasErrors == true;

  @override
  List<Object?> get props => [completedAt];
}

class SyncFailed extends SyncState {
  final String message;
  final String? failedTask;

  SyncFailed({required this.message, this.failedTask});

  @override
  List<Object?> get props => [message];
}

class SyncStatusLoaded extends SyncState {
  final DateTime? lastCustomerSync;
  final DateTime? lastDiscountSync;
  final int cachedCustomers;
  final int cachedDiscounts;
  final bool needsSync;

  SyncStatusLoaded({
    this.lastCustomerSync,
    this.lastDiscountSync,
    required this.cachedCustomers,
    required this.cachedDiscounts,
    required this.needsSync,
  });

  @override
  List<Object?> get props => [lastCustomerSync, lastDiscountSync];
}

// ============ BLOC ============

class SyncBloc extends Bloc<SyncEvent, SyncState> {
  final CustomerRepository _customerRepository;
  final DiscountRepository _discountRepository;

  SyncBloc({
    required CustomerRepository customerRepository,
    required DiscountRepository discountRepository,
  })  : _customerRepository = customerRepository,
        _discountRepository = discountRepository,
        super(SyncInitial()) {
    on<SyncAllRequested>(_onSyncAll);
    on<SyncCustomersRequested>(_onSyncCustomers);
    on<SyncDiscountsRequested>(_onSyncDiscounts);
    on<SyncPromotionsRequested>(_onSyncPromotions);
    on<SyncAgentProfileRequested>(_onSyncAgentProfile);
    on<CheckSyncStatusRequested>(_onCheckStatus);
    on<BackgroundSyncRequested>(_onBackgroundSync);
  }

  // ============ BARCHA SINXRONLASH ============

  Future<void> _onSyncAll(
    SyncAllRequested event,
    Emitter<SyncState> emit,
  ) async {
    final startTime = DateTime.now();

    emit(SyncInProgress(
      currentTask: 'Agent profilini yuklash...',
      progress: 0.0,
      totalItems: 0,
      processedItems: 0,
    ));

    // 1. Agent profilini sinxronlash
    final profileResult =
        await _customerRepository.syncAgentProfile(event.agentId);

    await profileResult.fold(
      (failure) async {
        emit(SyncFailed(
            message: 'Agent profili yuklanmadi: ${failure.message}'));
      },
      (profile) async {
        // 2. Mijozlarni sinxronlash
        emit(SyncInProgress(
          currentTask: 'Mijozlar yuklanmoqda (${profile.totalCustomers} ta)...',
          progress: 0.2,
          totalItems: profile.totalCustomers,
          processedItems: 0,
        ));

        final customerResult = await _customerRepository.syncAllCustomers(
          agentId: event.agentId,
        );

        // 3. Chegirmalarni sinxronlash
        emit(SyncInProgress(
          currentTask: 'Chegirmalar yuklanmoqda...',
          progress: 0.5,
          totalItems: profile.totalCustomers,
          processedItems: profile.totalCustomers ~/ 2,
        ));

        final discountResult = await _discountRepository.syncAllDiscounts();

        // 4. Natija
        final endTime = DateTime.now();
        final duration = endTime.difference(startTime);

        customerResult.fold(
          (failure) => emit(SyncFailed(
            message: 'Mijozlar sinxronlashda xatolik: ${failure.message}',
          )),
          (customers) {
            discountResult.fold(
              (failure) => emit(SyncFailed(
                message:
                    'Chegirmalar sinxronlashda xatolik: ${failure.message}',
              )),
              (discounts) => emit(SyncCompleted(
                customerResult: customers,
                discountResult: discounts,
                completedAt: endTime,
                duration: duration,
              )),
            );
          },
        );
      },
    );
  }

  // ============ FAQAT MIJOZLAR ============

  Future<void> _onSyncCustomers(
    SyncCustomersRequested event,
    Emitter<SyncState> emit,
  ) async {
    emit(SyncInProgress(
      currentTask: 'Mijozlar yuklanmoqda...',
      progress: 0.0,
      totalItems: 0,
      processedItems: 0,
    ));

    final result = await _customerRepository.syncAllCustomers(
      agentId: event.agentId,
    );

    result.fold(
      (failure) => emit(SyncFailed(message: failure.message)),
      (syncResult) => emit(SyncCompleted(
        customerResult: syncResult,
        completedAt: DateTime.now(),
        duration: Duration.zero,
      )),
    );
  }

  // ============ FAQAT CHEGIRMALAR ============

  Future<void> _onSyncDiscounts(
    SyncDiscountsRequested event,
    Emitter<SyncState> emit,
  ) async {
    emit(SyncInProgress(
      currentTask: 'Chegirmalar yuklanmoqda...',
      progress: 0.0,
      totalItems: 0,
      processedItems: 0,
    ));

    final result = await _discountRepository.syncAllDiscounts();

    result.fold(
      (failure) => emit(SyncFailed(message: failure.message)),
      (syncResult) => emit(SyncCompleted(
        discountResult: syncResult,
        completedAt: DateTime.now(),
        duration: Duration.zero,
      )),
    );
  }

  // ============ PROMOLAR ============

  Future<void> _onSyncPromotions(
    SyncPromotionsRequested event,
    Emitter<SyncState> emit,
  ) async {
    emit(SyncInProgress(
      currentTask: 'Promolar yuklanmoqda...',
      progress: 0.0,
      totalItems: 0,
      processedItems: 0,
    ));

    final result = await _discountRepository.syncAllDiscounts();

    result.fold(
      (failure) => emit(SyncFailed(message: failure.message)),
      (syncResult) => emit(SyncCompleted(
        discountResult: syncResult,
        completedAt: DateTime.now(),
        duration: Duration.zero,
      )),
    );
  }

  // ============ AGENT PROFILI ============

  Future<void> _onSyncAgentProfile(
    SyncAgentProfileRequested event,
    Emitter<SyncState> emit,
  ) async {
    emit(SyncInProgress(
      currentTask: 'Agent profili yuklanmoqda...',
      progress: 0.0,
      totalItems: 1,
      processedItems: 0,
    ));

    final result = await _customerRepository.syncAgentProfile(event.agentId);

    result.fold(
      (failure) => emit(SyncFailed(message: failure.message)),
      (profile) => emit(SyncCompleted(
        completedAt: DateTime.now(),
        duration: Duration.zero,
      )),
    );
  }

  // ============ HOLATNI TEKSHIRISH ============

  Future<void> _onCheckStatus(
    CheckSyncStatusRequested event,
    Emitter<SyncState> emit,
  ) async {
    final lastCustomerSync =
        await _customerRepository.getLastCustomerSyncTime();
    final lastDiscountSync = await _discountRepository.getLastSyncTime();

    lastCustomerSync.fold(
      (_) {},
      (time) {
        lastDiscountSync.fold(
          (_) {},
          (discountTime) {
            final needsSync = time == null ||
                discountTime == null ||
                DateTime.now().difference(time).inHours > 1 ||
                DateTime.now().difference(discountTime).inHours > 1;

            emit(SyncStatusLoaded(
              lastCustomerSync: time,
              lastDiscountSync: discountTime,
              cachedCustomers: 0,
              cachedDiscounts: 0,
              needsSync: needsSync,
            ));
          },
        );
      },
    );
  }

  // ============ BACKGROUND SINXRONLASH ============

  Future<void> _onBackgroundSync(
    BackgroundSyncRequested event,
    Emitter<SyncState> emit,
  ) async {
    // Sessiya boshida avtomatik sinxronlash
    add(SyncAllRequested(agentId: event.agentId));
  }
}
