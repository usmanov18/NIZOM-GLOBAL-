import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/admin_entities.dart';
import '../entities/admin_extended_entities.dart';
import '../usecases/admin_usecases.dart';

// ============================================================
// ADMIN REPOSITORY - Yuqori boshqaruv API
// ============================================================

abstract class AdminRepository {
  // ============ DASHBOARD ============
  Future<Either<Failure, AdminDashboard>> getDashboard();

  // ============ SYSTEM SETTINGS ============
  Future<Either<Failure, SystemSettings>> getSystemSettings();
  Future<Either<Failure, SystemSettings>> updateSystemSettings(
      SystemSettings settings);
  Future<Either<Failure, bool>> testConnection(String system); // 1c, sap

  // ============ AGENT MANAGEMENT ============
  Future<Either<Failure, List<AdminAgent>>> getAllAgents(
      {String? status, String? search});
  Future<Either<Failure, AdminAgent>> getAgentById(String agentId);
  Future<Either<Failure, AdminAgent>> createAgent(CreateAgentParams params);
  Future<Either<Failure, AdminAgent>> updateAgent(
      String agentId, UpdateAgentParams params);
  Future<Either<Failure, bool>> blockAgent(String agentId, String reason);
  Future<Either<Failure, bool>> unblockAgent(String agentId);
  Future<Either<Failure, bool>> resetAgentPassword(String agentId);
  Future<Either<Failure, bool>> assignAgentToSupervisor(
      String agentId, String supervisorId);

  // ============ SUPERVISOR MANAGEMENT ============
  Future<Either<Failure, List<AdminSupervisor>>> getAllSupervisors();
  Future<Either<Failure, AdminSupervisor>> createSupervisor(
      CreateSupervisorParams params);
  Future<Either<Failure, AdminSupervisor>> updateSupervisor(
      String id, UpdateSupervisorParams params);
  Future<Either<Failure, bool>> deleteSupervisor(String id);

  // ============ AGENT RESTRICTIONS ============
  Future<Either<Failure, List<AgentRestrictions>>> getAllRestrictions();
  Future<Either<Failure, AgentRestrictions>> getAgentRestrictions(
      String agentId);
  Future<Either<Failure, AgentRestrictions>> updateRestrictions(
      AgentRestrictions restrictions);
  Future<Either<Failure, AgentRestrictions>> createRestrictions(
      AgentRestrictions restrictions);
  Future<Either<Failure, bool>> applyRestrictionsToAll(
      AgentRestrictions restrictions);
  Future<Either<Failure, bool>> applyRestrictionsToRegion(
      String regionId, AgentRestrictions restrictions);

  // ============ DISCOUNT POLICY ============
  Future<Either<Failure, GlobalDiscountPolicy>> getDiscountPolicy();
  Future<Either<Failure, GlobalDiscountPolicy>> updateDiscountPolicy(
      GlobalDiscountPolicy policy);
  Future<Either<Failure, DiscountRule>> addDiscountRule(
      String agentId, DiscountRule rule);
  Future<Either<Failure, bool>> removeDiscountRule(
      String agentId, String ruleId);
  Future<Either<Failure, List<DiscountRule>>> getGlobalDiscountRules();

  // ============ SYSTEM MONITOR ============
  Future<Either<Failure, SystemHealth>> getSystemHealth();
  Future<Either<Failure, List<SystemAlert>>> getActiveAlerts();
  Future<Either<Failure, bool>> acknowledgeAlert(String alertId);
  Future<Either<Failure, PerformanceMetrics>> getPerformanceMetrics(
      {String? period});

  // ============ AUDIT LOG ============
  Future<Either<Failure, List<AuditLogEntry>>> getAuditLog({
    String? userId,
    String? action,
    DateTime? fromDate,
    DateTime? toDate,
    int page = 1,
    int limit = 50,
  });

  // ============ ROLES & PERMISSIONS ============
  Future<Either<Failure, List<AdminRole>>> getAllRoles();
  Future<Either<Failure, AdminRole>> createRole(AdminRole role);
  Future<Either<Failure, AdminRole>> updateRole(AdminRole role);
  Future<Either<Failure, bool>> deleteRole(String roleId);
  Future<Either<Failure, bool>> assignRoleToUser(String userId, String roleId);

  // ============ REPORTS ============
  Future<Either<Failure, AdminSalesReport>> getSalesReport({
    required DateTime fromDate,
    required DateTime toDate,
    String? agentId,
    String? regionId,
  });
  Future<Either<Failure, AdminAgentPerformance>> getAgentPerformance({
    required String agentId,
    required DateTime fromDate,
    required DateTime toDate,
  });
  Future<Either<Failure, List<AdminTopProduct>>> getTopProducts({
    required DateTime fromDate,
    required DateTime toDate,
    int limit = 10,
  });
  Future<Either<Failure, List<AdminTopCustomer>>> getTopCustomers({
    required DateTime fromDate,
    required DateTime toDate,
    int limit = 10,
  });

  // ============ SYNC MANAGEMENT ============
  Future<Either<Failure, SyncStatus>> getSyncStatus();
  Future<Either<Failure, bool>> triggerSync(String system); // 1c, sap, all
  Future<Either<Failure, List<SyncLogEntry>>> getSyncLog({int limit = 50});

  // ============ BULK OPERATIONS ============
  Future<Either<Failure, BulkOperationResult>> bulkUpdateAgentRestrictions({
    required List<String> agentIds,
    required AgentRestrictions restrictions,
  });
  Future<Either<Failure, BulkOperationResult>> bulkBlockAgents({
    required List<String> agentIds,
    required String reason,
  });
}
