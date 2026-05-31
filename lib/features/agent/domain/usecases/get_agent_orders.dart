import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/agent_dashboard.dart';
import '../repositories/agent_repository.dart';

/// Agent buyurtmalarini olish UseCase
class GetAgentOrders implements UseCase<List<AgentOrder>, AgentOrdersParams> {
  final AgentRepository repository;

  GetAgentOrders(this.repository);

  @override
  Future<Either<Failure, List<AgentOrder>>> call(
      AgentOrdersParams params) async {
    return await repository.getOrders(
      status: params.status,
      page: params.page,
      limit: params.limit,
    );
  }
}

class AgentOrdersParams extends Equatable {
  final String? status;
  final int page;
  final int limit;

  const AgentOrdersParams({
    this.status,
    this.page = 1,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [status, page, limit];
}
