import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/admin_entities.dart';
import '../entities/admin_extended_entities.dart';
import '../repositories/admin_repository.dart';

// ============================================================
// ADMIN USECASES - Business logika
// ============================================================

// ============ DASHBOARD ============

class GetAdminDashboard implements UseCase<AdminDashboard, NoParams> {
  final AdminRepository repository;
  GetAdminDashboard(this.repository);

  @override
  Future<Either<Failure, AdminDashboard>> call(NoParams params) {
    return repository.getDashboard();
  }
}

// ============ SYSTEM SETTINGS ============

class GetSystemSettings implements UseCase<SystemSettings, NoParams> {
  final AdminRepository repository;
  GetSystemSettings(this.repository);

  @override
  Future<Either<Failure, SystemSettings>> call(NoParams params) {
    return repository.getSystemSettings();
  }
}

class UpdateSystemSettings implements UseCase<SystemSettings, SystemSettings> {
  final AdminRepository repository;
  UpdateSystemSettings(this.repository);

  @override
  Future<Either<Failure, SystemSettings>> call(SystemSettings settings) {
    return repository.updateSystemSettings(settings);
  }
}

class TestConnection implements UseCase<bool, String> {
  final AdminRepository repository;
  TestConnection(this.repository);

  @override
  Future<Either<Failure, bool>> call(String system) {
    return repository.testConnection(system);
  }
}

// ============ AGENT MANAGEMENT ============

class GetAllAgents implements UseCase<List<AdminAgent>, GetAgentsParams> {
  final AdminRepository repository;
  GetAllAgents(this.repository);

  @override
  Future<Either<Failure, List<AdminAgent>>> call(GetAgentsParams params) {
    return repository.getAllAgents(
        status: params.status, search: params.search);
  }
}

class CreateAgent implements UseCase<AdminAgent, CreateAgentParams> {
  final AdminRepository repository;
  CreateAgent(this.repository);

  @override
  Future<Either<Failure, AdminAgent>> call(CreateAgentParams params) {
    // Validatsiya
    if (params.name.isEmpty)
      return Future.value(
          const Left(ValidationFailure(message: 'Ism kiritish shart')));
    if (params.phone.isEmpty)
      return Future.value(
          const Left(ValidationFailure(message: 'Telefon kiritish shart')));
    if (params.code.isEmpty)
      return Future.value(
          const Left(ValidationFailure(message: 'Agent kodi kiritish shart')));

    return repository.createAgent(params);
  }
}

class BlockAgent implements UseCase<bool, BlockAgentParams> {
  final AdminRepository repository;
  BlockAgent(this.repository);

  @override
  Future<Either<Failure, bool>> call(BlockAgentParams params) {
    if (params.reason.isEmpty)
      return Future.value(
          const Left(ValidationFailure(message: 'Sabab kiritish shart')));
    return repository.blockAgent(params.agentId, params.reason);
  }
}

class UnblockAgent implements UseCase<bool, String> {
  final AdminRepository repository;
  UnblockAgent(this.repository);

  @override
  Future<Either<Failure, bool>> call(String agentId) {
    return repository.unblockAgent(agentId);
  }
}

class AssignAgentToSupervisor implements UseCase<bool, AssignAgentParams> {
  final AdminRepository repository;
  AssignAgentToSupervisor(this.repository);

  @override
  Future<Either<Failure, bool>> call(AssignAgentParams params) {
    return repository.assignAgentToSupervisor(
        params.agentId, params.supervisorId);
  }
}

// ============ RESTRICTIONS ============

class GetAgentRestrictions implements UseCase<AgentRestrictions, String> {
  final AdminRepository repository;
  GetAgentRestrictions(this.repository);

  @override
  Future<Either<Failure, AgentRestrictions>> call(String agentId) {
    return repository.getAgentRestrictions(agentId);
  }
}

class UpdateRestrictions
    implements UseCase<AgentRestrictions, AgentRestrictions> {
  final AdminRepository repository;
  UpdateRestrictions(this.repository);

  @override
  Future<Either<Failure, AgentRestrictions>> call(
      AgentRestrictions restrictions) {
    // Validatsiya
    if (restrictions.maxDiscountPercent > 50) {
      return Future.value(const Left(
          ValidationFailure(message: 'Max chegirma 50% dan oshmasligi kerak')));
    }
    if (restrictions.maxOrdersPerDay > 100) {
      return Future.value(const Left(
          ValidationFailure(message: 'Max buyurtma 100 dan oshmasligi kerak')));
    }

    return repository.updateRestrictions(restrictions);
  }
}

class ApplyRestrictionsToAll implements UseCase<bool, AgentRestrictions> {
  final AdminRepository repository;
  ApplyRestrictionsToAll(this.repository);

  @override
  Future<Either<Failure, bool>> call(AgentRestrictions restrictions) {
    return repository.applyRestrictionsToAll(restrictions);
  }
}

// ============ DISCOUNT POLICY ============

class GetDiscountPolicy implements UseCase<GlobalDiscountPolicy, NoParams> {
  final AdminRepository repository;
  GetDiscountPolicy(this.repository);

  @override
  Future<Either<Failure, GlobalDiscountPolicy>> call(NoParams params) {
    return repository.getDiscountPolicy();
  }
}

class UpdateDiscountPolicy
    implements UseCase<GlobalDiscountPolicy, GlobalDiscountPolicy> {
  final AdminRepository repository;
  UpdateDiscountPolicy(this.repository);

  @override
  Future<Either<Failure, GlobalDiscountPolicy>> call(
      GlobalDiscountPolicy policy) {
    // Validatsiya
    if (policy.maxOverallDiscount > 50) {
      return Future.value(const Left(ValidationFailure(
          message: 'Max umumiy chegirma 50% dan oshmasligi kerak')));
    }

    // Bosqichlar tekshirish
    for (int i = 0; i < policy.tiers.length - 1; i++) {
      if (policy.tiers[i].discountPercent >=
          policy.tiers[i + 1].discountPercent) {
        return Future.value(const Left(ValidationFailure(
            message:
                'Chegirma bosqichlari o\'sish tartibida bo\'lishi kerak')));
      }
    }

    return repository.updateDiscountPolicy(policy);
  }
}

// ============ SYSTEM MONITOR ============

class GetSystemHealth implements UseCase<SystemHealth, NoParams> {
  final AdminRepository repository;
  GetSystemHealth(this.repository);

  @override
  Future<Either<Failure, SystemHealth>> call(NoParams params) {
    return repository.getSystemHealth();
  }
}

class GetActiveAlerts implements UseCase<List<SystemAlert>, NoParams> {
  final AdminRepository repository;
  GetActiveAlerts(this.repository);

  @override
  Future<Either<Failure, List<SystemAlert>>> call(NoParams params) {
    return repository.getActiveAlerts();
  }
}

class AcknowledgeAlert implements UseCase<bool, String> {
  final AdminRepository repository;
  AcknowledgeAlert(this.repository);

  @override
  Future<Either<Failure, bool>> call(String alertId) {
    return repository.acknowledgeAlert(alertId);
  }
}

// ============ AUDIT LOG ============

class GetAuditLog implements UseCase<List<AuditLogEntry>, GetAuditLogParams> {
  final AdminRepository repository;
  GetAuditLog(this.repository);

  @override
  Future<Either<Failure, List<AuditLogEntry>>> call(GetAuditLogParams params) {
    return repository.getAuditLog(
      userId: params.userId,
      action: params.action,
      fromDate: params.fromDate,
      toDate: params.toDate,
      page: params.page,
      limit: params.limit,
    );
  }
}

// ============ ROLES ============

class GetAllRoles implements UseCase<List<AdminRole>, NoParams> {
  final AdminRepository repository;
  GetAllRoles(this.repository);

  @override
  Future<Either<Failure, List<AdminRole>>> call(NoParams params) {
    return repository.getAllRoles();
  }
}

class CreateRole implements UseCase<AdminRole, AdminRole> {
  final AdminRepository repository;
  CreateRole(this.repository);

  @override
  Future<Either<Failure, AdminRole>> call(AdminRole role) {
    if (role.name.isEmpty)
      return Future.value(
          const Left(ValidationFailure(message: 'Rol nomi kiritish shart')));
    return repository.createRole(role);
  }
}

// ============ REPORTS ============

class GetSalesReport implements UseCase<AdminSalesReport, SalesReportParams> {
  final AdminRepository repository;
  GetSalesReport(this.repository);

  @override
  Future<Either<Failure, AdminSalesReport>> call(SalesReportParams params) {
    return repository.getSalesReport(
      fromDate: params.fromDate,
      toDate: params.toDate,
      agentId: params.agentId,
      regionId: params.regionId,
    );
  }
}

class GetAgentPerformance
    implements UseCase<AdminAgentPerformance, AgentPerformanceParams> {
  final AdminRepository repository;
  GetAgentPerformance(this.repository);

  @override
  Future<Either<Failure, AdminAgentPerformance>> call(
      AgentPerformanceParams params) {
    return repository.getAgentPerformance(
      agentId: params.agentId,
      fromDate: params.fromDate,
      toDate: params.toDate,
    );
  }
}

// ============ SYNC ============

class GetSyncStatus implements UseCase<SyncStatus, NoParams> {
  final AdminRepository repository;
  GetSyncStatus(this.repository);

  @override
  Future<Either<Failure, SyncStatus>> call(NoParams params) {
    return repository.getSyncStatus();
  }
}

class TriggerSync implements UseCase<bool, String> {
  final AdminRepository repository;
  TriggerSync(this.repository);

  @override
  Future<Either<Failure, bool>> call(String system) {
    return repository.triggerSync(system);
  }
}

// ============ BULK OPERATIONS ============

class BulkUpdateRestrictions
    implements UseCase<BulkOperationResult, BulkRestrictionsParams> {
  final AdminRepository repository;
  BulkUpdateRestrictions(this.repository);

  @override
  Future<Either<Failure, BulkOperationResult>> call(
      BulkRestrictionsParams params) {
    return repository.bulkUpdateAgentRestrictions(
      agentIds: params.agentIds,
      restrictions: params.restrictions,
    );
  }
}

class BulkBlockAgents implements UseCase<BulkOperationResult, BulkBlockParams> {
  final AdminRepository repository;
  BulkBlockAgents(this.repository);

  @override
  Future<Either<Failure, BulkOperationResult>> call(BulkBlockParams params) {
    return repository.bulkBlockAgents(
      agentIds: params.agentIds,
      reason: params.reason,
    );
  }
}

// ============ PARAM CLASSES ============

class GetAgentsParams extends Equatable {
  final String? status;
  final String? search;
  const GetAgentsParams({this.status, this.search});
  @override
  List<Object?> get props => [status, search];
}

class CreateAgentParams extends Equatable {
  final String name;
  final String code;
  final String phone;
  final String email;
  final String regionId;
  final String supervisorId;
  final String warehouseId;
  final String password;

  const CreateAgentParams({
    required this.name,
    required this.code,
    required this.phone,
    required this.email,
    required this.regionId,
    required this.supervisorId,
    required this.warehouseId,
    required this.password,
  });

  @override
  List<Object?> get props => [code, phone];
}

class UpdateAgentParams extends Equatable {
  final String? name;
  final String? phone;
  final String? email;
  final String? regionId;
  final String? supervisorId;
  final bool? isActive;

  const UpdateAgentParams({
    this.name,
    this.phone,
    this.email,
    this.regionId,
    this.supervisorId,
    this.isActive,
  });

  @override
  List<Object?> get props => [name, phone, email];
}

class BlockAgentParams extends Equatable {
  final String agentId;
  final String reason;
  const BlockAgentParams({required this.agentId, required this.reason});
  @override
  List<Object?> get props => [agentId, reason];
}

class AssignAgentParams extends Equatable {
  final String agentId;
  final String supervisorId;
  const AssignAgentParams({required this.agentId, required this.supervisorId});
  @override
  List<Object?> get props => [agentId, supervisorId];
}

class GetAuditLogParams extends Equatable {
  final String? userId;
  final String? action;
  final DateTime? fromDate;
  final DateTime? toDate;
  final int page;
  final int limit;

  const GetAuditLogParams({
    this.userId,
    this.action,
    this.fromDate,
    this.toDate,
    this.page = 1,
    this.limit = 50,
  });

  @override
  List<Object?> get props => [userId, action, fromDate, toDate, page];
}

class SalesReportParams extends Equatable {
  final DateTime fromDate;
  final DateTime toDate;
  final String? agentId;
  final String? regionId;

  const SalesReportParams({
    required this.fromDate,
    required this.toDate,
    this.agentId,
    this.regionId,
  });

  @override
  List<Object?> get props => [fromDate, toDate];
}

class AgentPerformanceParams extends Equatable {
  final String agentId;
  final DateTime fromDate;
  final DateTime toDate;

  const AgentPerformanceParams({
    required this.agentId,
    required this.fromDate,
    required this.toDate,
  });

  @override
  List<Object?> get props => [agentId, fromDate, toDate];
}

class BulkRestrictionsParams extends Equatable {
  final List<String> agentIds;
  final AgentRestrictions restrictions;

  const BulkRestrictionsParams({
    required this.agentIds,
    required this.restrictions,
  });

  @override
  List<Object?> get props => [agentIds];
}

class BulkBlockParams extends Equatable {
  final List<String> agentIds;
  final String reason;

  const BulkBlockParams({
    required this.agentIds,
    required this.reason,
  });

  @override
  List<Object?> get props => [agentIds, reason];
}

class CreateSupervisorParams extends Equatable {
  final String name;
  final String code;
  final String phone;
  final String email;
  final List<String> regionIds;
  final List<String> agentIds;

  const CreateSupervisorParams({
    required this.name,
    required this.code,
    required this.phone,
    required this.email,
    required this.regionIds,
    required this.agentIds,
  });

  @override
  List<Object?> get props => [code, phone];
}

class UpdateSupervisorParams extends Equatable {
  final String? name;
  final String? phone;
  final String? email;
  final List<String>? regionIds;
  final List<String>? agentIds;

  const UpdateSupervisorParams({
    this.name,
    this.phone,
    this.email,
    this.regionIds,
    this.agentIds,
  });

  @override
  List<Object?> get props => [name, phone];
}
