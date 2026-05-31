import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/agent_dashboard.dart';
import '../repositories/agent_repository.dart';

/// Agent Dashboard ma'lumotlarini olish UseCase
class GetAgentDashboard implements UseCase<AgentDashboard, NoParams> {
  final AgentRepository repository;

  GetAgentDashboard(this.repository);

  @override
  Future<Either<Failure, AgentDashboard>> call(NoParams params) async {
    return await repository.getDashboard();
  }
}
