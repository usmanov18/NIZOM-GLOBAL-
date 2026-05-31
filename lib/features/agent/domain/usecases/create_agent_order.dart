import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/agent_dashboard.dart';
import '../repositories/agent_repository.dart';

/// Yangi buyurtma yaratish UseCase
class CreateAgentOrder implements UseCase<AgentOrder, CreateOrderParams> {
  final AgentRepository repository;

  CreateAgentOrder(this.repository);

  @override
  Future<Either<Failure, AgentOrder>> call(CreateOrderParams params) async {
    // Validatsiya
    if (params.items.isEmpty) {
      return const Left(ValidationFailure(
        message: 'Kamida bitta mahsulot qo\'shing',
      ));
    }

    if (params.customerId.isEmpty) {
      return const Left(ValidationFailure(
        message: 'Mijozni tanlang',
      ));
    }

    return await repository.createOrder(
      customerId: params.customerId,
      items: params.items,
      notes: params.notes,
      deliveryDate: params.deliveryDate,
    );
  }
}

class CreateOrderParams extends Equatable {
  final String customerId;
  final List<OrderItem> items;
  final String? notes;
  final DateTime? deliveryDate;

  const CreateOrderParams({
    required this.customerId,
    required this.items,
    this.notes,
    this.deliveryDate,
  });

  double get totalAmount => items.fold(
        0,
        (sum, item) => sum + item.totalPrice,
      );

  int get totalItems => items.fold(
        0,
        (sum, item) => sum + item.quantity,
      );

  @override
  List<Object?> get props => [customerId, items, notes, deliveryDate];
}
