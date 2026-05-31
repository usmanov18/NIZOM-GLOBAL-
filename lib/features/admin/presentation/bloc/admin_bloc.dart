import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/admin_entities.dart';
import '../../domain/repositories/admin_repository.dart';

// ============================================================
// ADMIN BLOC - Yuqori boshqaruv
// Global sozlamalar, cheglovlar, tizim boshqaruvi
// ============================================================

// ============ EVENTS ============

abstract class AdminEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Admin dashboard yuklash
class AdminDashboardLoadRequested extends AdminEvent {}

/// Tizim sozlamalarini yuklash
class SystemSettingsLoadRequested extends AdminEvent {}

/// Tizim sozlamalarini yangilash
class SystemSettingsUpdateRequested extends AdminEvent {
  final SystemSettings settings;

  SystemSettingsUpdateRequested({required this.settings});
}

/// Agent cheklovlarini yuklash
class AgentRestrictionsLoadRequested extends AdminEvent {
  final String? agentId;

  AgentRestrictionsLoadRequested({this.agentId});
}

/// Agent cheklovlarini yangilash
class AgentRestrictionsUpdateRequested extends AdminEvent {
  final AgentRestrictions restrictions;

  AgentRestrictionsUpdateRequested({required this.restrictions});
}

/// Agent cheklovlarini yaratish
class AgentRestrictionsCreateRequested extends AdminEvent {
  final AgentRestrictions restrictions;

  AgentRestrictionsCreateRequested({required this.restrictions});
}

/// Global skidka siyosatini yuklash
class DiscountPolicyLoadRequested extends AdminEvent {}

/// Global skidka siyosatini yangilash
class DiscountPolicyUpdateRequested extends AdminEvent {
  final GlobalDiscountPolicy policy;

  DiscountPolicyUpdateRequested({required this.policy});
}

/// Skidka qoidasini qo'shish
class DiscountRuleAddRequested extends AdminEvent {
  final String agentId;
  final DiscountRule rule;

  DiscountRuleAddRequested({required this.agentId, required this.rule});
}

/// Skidka qoidasini o'chirish
class DiscountRuleRemoveRequested extends AdminEvent {
  final String agentId;
  final String ruleId;

  DiscountRuleRemoveRequested({required this.agentId, required this.ruleId});
}

/// 1C/SAP sinxronlash
class SystemSyncRequested extends AdminEvent {}

/// Agent bloklash
class AgentBlockRequested extends AdminEvent {
  final String agentId;
  final String reason;

  AgentBlockRequested({required this.agentId, required this.reason});
}

/// Agent faollashtirish
class AgentUnblockRequested extends AdminEvent {
  final String agentId;

  AgentUnblockRequested({required this.agentId});
}

// ============ STATES ============

abstract class AdminState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AdminInitial extends AdminState {}

class AdminLoading extends AdminState {}

class AdminDashboardLoaded extends AdminState {
  final AdminDashboard dashboard;

  AdminDashboardLoaded({required this.dashboard});
}

class SystemSettingsLoaded extends AdminState {
  final SystemSettings settings;

  SystemSettingsLoaded({required this.settings});
}

class SystemSettingsUpdated extends AdminState {
  final SystemSettings settings;

  SystemSettingsUpdated({required this.settings});
}

class AgentRestrictionsLoaded extends AdminState {
  final List<AgentRestrictions> restrictions;

  AgentRestrictionsLoaded({required this.restrictions});
}

class AgentRestrictionLoaded extends AdminState {
  final AgentRestrictions restriction;

  AgentRestrictionLoaded({required this.restriction});
}

class AgentRestrictionsUpdated extends AdminState {
  final AgentRestrictions restriction;

  AgentRestrictionsUpdated({required this.restriction});
}

class DiscountPolicyLoaded extends AdminState {
  final GlobalDiscountPolicy policy;

  DiscountPolicyLoaded({required this.policy});
}

class DiscountPolicyUpdated extends AdminState {
  final GlobalDiscountPolicy policy;

  DiscountPolicyUpdated({required this.policy});
}

class SystemSyncCompleted extends AdminState {
  final bool is1CConnected;
  final bool isSAPConnected;
  final int syncedItems;

  SystemSyncCompleted({
    required this.is1CConnected,
    required this.isSAPConnected,
    required this.syncedItems,
  });
}

class AgentBlocked extends AdminState {
  final String agentId;

  AgentBlocked({required this.agentId});
}

class AgentUnblocked extends AdminState {
  final String agentId;

  AgentUnblocked({required this.agentId});
}

class AdminError extends AdminState {
  final String message;

  AdminError({required this.message});
}

// ============ BLOC ============

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final AdminRepository repository;

  AdminBloc({required this.repository}) : super(AdminInitial()) {
    on<AdminDashboardLoadRequested>(_onDashboardLoad);
    on<SystemSettingsLoadRequested>(_onSettingsLoad);
    on<SystemSettingsUpdateRequested>(_onSettingsUpdate);
    on<AgentRestrictionsLoadRequested>(_onRestrictionsLoad);
    on<AgentRestrictionsUpdateRequested>(_onRestrictionsUpdate);
    on<AgentRestrictionsCreateRequested>(_onRestrictionsCreate);
    on<DiscountPolicyLoadRequested>(_onDiscountPolicyLoad);
    on<DiscountPolicyUpdateRequested>(_onDiscountPolicyUpdate);
    on<DiscountRuleAddRequested>(_onDiscountRuleAdd);
    on<DiscountRuleRemoveRequested>(_onDiscountRuleRemove);
    on<SystemSyncRequested>(_onSystemSync);
    on<AgentBlockRequested>(_onAgentBlock);
    on<AgentUnblockRequested>(_onAgentUnblock);
  }

  // ============ DASHBOARD ============

  Future<void> _onDashboardLoad(
    AdminDashboardLoadRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());
    final result = await repository.getDashboard();
    result.fold(
      (failure) => emit(AdminError(message: failure.message)),
      (dashboard) => emit(AdminDashboardLoaded(dashboard: dashboard)),
    );
  }

  // ============ SETTINGS ============

  Future<void> _onSettingsLoad(
    SystemSettingsLoadRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());
    final result = await repository.getSystemSettings();
    result.fold(
      (failure) => emit(AdminError(message: failure.message)),
      (settings) => emit(SystemSettingsLoaded(settings: settings)),
    );
  }

  Future<void> _onSettingsUpdate(
    SystemSettingsUpdateRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());
    final result = await repository.updateSystemSettings(event.settings);
    result.fold(
      (failure) => emit(AdminError(message: failure.message)),
      (settings) => emit(SystemSettingsUpdated(settings: settings)),
    );
  }

  // ============ RESTRICTIONS ============

  Future<void> _onRestrictionsLoad(
    AgentRestrictionsLoadRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());
    final result = event.agentId == null
        ? await repository.getAllRestrictions()
        : await repository.getAgentRestrictions(event.agentId!);
    result.fold(
      (failure) => emit(AdminError(message: failure.message)),
      (value) {
        if (value is List<AgentRestrictions>) {
          emit(AgentRestrictionsLoaded(restrictions: value));
        } else if (value is AgentRestrictions) {
          emit(AgentRestrictionLoaded(restriction: value));
        }
      },
    );
  }

  Future<void> _onRestrictionsUpdate(
    AgentRestrictionsUpdateRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());
    final result = await repository.updateRestrictions(event.restrictions);
    result.fold(
      (failure) => emit(AdminError(message: failure.message)),
      (restriction) => emit(AgentRestrictionsUpdated(restriction: restriction)),
    );
  }

  Future<void> _onRestrictionsCreate(
    AgentRestrictionsCreateRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());
    final result = await repository.createRestrictions(event.restrictions);
    result.fold(
      (failure) => emit(AdminError(message: failure.message)),
      (restriction) => emit(AgentRestrictionsUpdated(restriction: restriction)),
    );
  }

  // ============ DISCOUNT POLICY ============

  Future<void> _onDiscountPolicyLoad(
    DiscountPolicyLoadRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());
    final result = await repository.getDiscountPolicy();
    result.fold(
      (failure) => emit(AdminError(message: failure.message)),
      (policy) => emit(DiscountPolicyLoaded(policy: policy)),
    );
  }

  Future<void> _onDiscountPolicyUpdate(
    DiscountPolicyUpdateRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());
    final result = await repository.updateDiscountPolicy(event.policy);
    result.fold(
      (failure) => emit(AdminError(message: failure.message)),
      (policy) => emit(DiscountPolicyUpdated(policy: policy)),
    );
  }

  Future<void> _onDiscountRuleAdd(
    DiscountRuleAddRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());
    final result = await repository.addDiscountRule(event.agentId, event.rule);
    result.fold(
      (failure) => emit(AdminError(message: failure.message)),
      (_) => add(AgentRestrictionsLoadRequested(agentId: event.agentId)),
    );
  }

  Future<void> _onDiscountRuleRemove(
    DiscountRuleRemoveRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());
    final result =
        await repository.removeDiscountRule(event.agentId, event.ruleId);
    result.fold(
      (failure) => emit(AdminError(message: failure.message)),
      (_) => add(AgentRestrictionsLoadRequested(agentId: event.agentId)),
    );
  }

  // ============ SYSTEM SYNC ============

  Future<void> _onSystemSync(
    SystemSyncRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());
    final result = await repository.triggerSync('all');
    result.fold(
      (failure) => emit(AdminError(message: failure.message)),
      (_) => emit(SystemSyncCompleted(
        is1CConnected: true,
        isSAPConnected: true,
        syncedItems: 0,
      )),
    );
  }

  // ============ AGENT BLOCK/UNBLOCK ============

  Future<void> _onAgentBlock(
    AgentBlockRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());
    final result = await repository.blockAgent(event.agentId, event.reason);
    result.fold(
      (failure) => emit(AdminError(message: failure.message)),
      (_) => emit(AgentBlocked(agentId: event.agentId)),
    );
  }

  Future<void> _onAgentUnblock(
    AgentUnblockRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());
    final result = await repository.unblockAgent(event.agentId);
    result.fold(
      (failure) => emit(AdminError(message: failure.message)),
      (_) => emit(AgentUnblocked(agentId: event.agentId)),
    );
  }
}
