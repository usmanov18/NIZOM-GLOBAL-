import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/product_portfolio.dart';

abstract class ProductPortfolioRepository {
  bool canManagePortfolios(String role);

  List<ProductPortfolio> get demoPortfolios;

  Future<Either<Failure, List<ProductPortfolio>>> getPortfolios();

  Future<Either<Failure, ProductPortfolio>> getPortfolioById(String id);

  Future<Either<Failure, PortfolioAssignment>> getAssignmentForUser(
    String userId,
    String role,
  );

  Future<Either<Failure, void>> saveAssignment({
    required String actorRole,
    required PortfolioAssignment assignment,
  });

  Future<Either<Failure, List<ProductPortfolio>>> getAssignedPortfolios(
    String userId,
    String role,
  );

  Future<Either<Failure, bool>> canUserSellProduct({
    required String userId,
    required String role,
    required String productId,
  });

  Future<Either<Failure, List<PortfolioAuditLog>>> getAuditLogs(
      {String? targetUserId});
}
