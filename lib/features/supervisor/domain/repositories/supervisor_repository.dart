import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/supervisor_entities.dart';

// ============================================================
// SUPERVISOR REPOSITORY - Supervisor API
// ============================================================

abstract class SupervisorRepository {
  /// Dashboard
  Future<Either<Failure, SupervisorDashboard>> getDashboard(
      String supervisorId);

  /// Agentlar holati
  Future<Either<Failure, List<AgentStatus>>> getAgentsStatus(
      String supervisorId);

  /// Agent tafsilotlari
  Future<Either<Failure, AgentStatus>> getAgentDetail(String agentId);

  /// Agent marshruti
  Future<Either<Failure, List<AgentRoutePoint>>> getAgentRoute({
    required String agentId,
    required DateTime date,
  });

  /// Vazifalar
  Future<Either<Failure, List<AgentTask>>> getTasks({
    required String supervisorId,
    String? agentId,
    String? status,
  });

  /// Vazifa yaratish
  Future<Either<Failure, AgentTask>> createTask(AgentTask task);

  /// Vazifa yangilash
  Future<Either<Failure, AgentTask>> updateTask({
    required String taskId,
    required String status,
    String? result,
  });

  /// Ish jadvali
  Future<Either<Failure, AgentSchedule>> getSchedule(String agentId);

  /// Ish jadvalini yangilash
  Future<Either<Failure, AgentSchedule>> updateSchedule(AgentSchedule schedule);

  /// Statistika
  Future<Either<Failure, Map<String, dynamic>>> getStatistics({
    required String supervisorId,
    required DateTime fromDate,
    required DateTime toDate,
  });
}
