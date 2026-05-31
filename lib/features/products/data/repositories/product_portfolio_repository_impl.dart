import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/config/env_config.dart';
import '../../../../core/network/api_error_mapper.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/product_portfolio.dart';
import '../../domain/repositories/product_portfolio_repository.dart';
import '../../domain/policies/product_portfolio_policy.dart';
import '../datasources/product_portfolio_local_datasource.dart';
import '../datasources/product_portfolio_remote_datasource.dart';

class ProductPortfolioRepositoryImpl implements ProductPortfolioRepository {
  final ProductPortfolioRemoteDataSource remoteDataSource;
  final ProductPortfolioLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  ProductPortfolioRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  bool canManagePortfolios(String role) =>
      ProductPortfolioPolicy.canManageAssignments(role);

  @override
  Future<Either<Failure, List<ProductPortfolio>>> getPortfolios() async {
    try {
      if (await networkInfo.isConnected) {
        final remote = await remoteDataSource.getPortfolios();
        final portfolios = remote.map(ProductPortfolio.fromJson).toList();
        if (portfolios.isNotEmpty) {
          await localDataSource.savePortfolios(portfolios);
          return Right(portfolios);
        }
      }

      final local = await localDataSource.getPortfolios();
      if (local.isNotEmpty) return Right(local);
      if (EnvConfig.isDemoMode) return Right(demoPortfolios);
      return const Left(
          CacheFailure(message: 'Portfolio ma’lumotlari topilmadi'));
    } catch (e) {
      final local = await localDataSource.getPortfolios();
      if (local.isNotEmpty) return Right(local);
      if (EnvConfig.isDemoMode) return Right(demoPortfolios);
      return const Left(
          CacheFailure(message: 'Portfolio ma’lumotlari topilmadi'));
    }
  }

  @override
  Future<Either<Failure, ProductPortfolio>> getPortfolioById(String id) async {
    final portfoliosResult = await getPortfolios();
    return portfoliosResult.fold(
      (failure) => Left(failure),
      (portfolios) {
        final matches = portfolios.where((p) => p.id == id);
        if (matches.isEmpty)
          return Left(NotFoundFailure(resource: 'Portfolio'));
        return Right(matches.first);
      },
    );
  }

  @override
  Future<Either<Failure, PortfolioAssignment>> getAssignmentForUser(
    String userId,
    String role,
  ) async {
    try {
      if (await networkInfo.isConnected) {
        final remote = await remoteDataSource.getAssignmentForUser(userId);
        final assignment = PortfolioAssignment.fromJson(remote);
        await localDataSource.saveAssignment(assignment);
        return Right(assignment);
      }

      final local = await localDataSource.getAssignment(userId, role);
      if (local != null) return Right(local);
      if (EnvConfig.isDemoMode) return Right(demoAssignmentFor(userId, role));
      return const Left(
          CacheFailure(message: 'Portfolio biriktirish topilmadi'));
    } catch (e) {
      final local = await localDataSource.getAssignment(userId, role);
      if (local != null) return Right(local);
      if (EnvConfig.isDemoMode) return Right(demoAssignmentFor(userId, role));
      return const Left(
          CacheFailure(message: 'Portfolio biriktirish topilmadi'));
    }
  }

  @override
  Future<Either<Failure, void>> saveAssignment({
    required String actorRole,
    required PortfolioAssignment assignment,
  }) async {
    final validationErrors = ProductPortfolioPolicy.validateAssignment(
      actorRole: actorRole,
      assignment: assignment,
    );
    if (validationErrors.isNotEmpty) {
      if (!canManagePortfolios(actorRole))
        return const Left(ForbiddenFailure());
      return Left(ValidationFailure(message: validationErrors.join('\n')));
    }

    try {
      final oldAssignment = await localDataSource.getAssignment(
        assignment.userId,
        assignment.userRole,
      );

      await localDataSource.saveAssignment(assignment);
      await localDataSource.saveAuditLog(PortfolioAuditLog(
        id: 'audit_${DateTime.now().microsecondsSinceEpoch}',
        event: 'portfolio_assignment_updated',
        actorId: actorRole,
        actorRole: actorRole,
        targetUserId: assignment.userId,
        targetUserRole: assignment.userRole,
        oldPortfolioIds: oldAssignment?.portfolioIds ?? const [],
        newPortfolioIds: assignment.portfolioIds,
        oldCanSellOutsidePortfolio:
            oldAssignment?.canSellOutsidePortfolio ?? false,
        newCanSellOutsidePortfolio: assignment.canSellOutsidePortfolio,
        createdAt: DateTime.now(),
      ));

      if (await networkInfo.isConnected) {
        await remoteDataSource.saveAssignment(
            assignment.userId, assignment.toJson());
      }
      return const Right(null);
    } catch (e) {
      if (e is DioException)
        return Left(ApiErrorMapper.fromDio(e,
            defaultMessage: 'Portfolio assignment saqlanmadi'));
      return Left(
          ServerFailure(message: 'Portfolio assignment saqlanmadi: $e'));
    }
  }

  @override
  Future<Either<Failure, List<ProductPortfolio>>> getAssignedPortfolios(
    String userId,
    String role,
  ) async {
    final portfoliosResult = await getPortfolios();
    final assignmentResult = await getAssignmentForUser(userId, role);

    return portfoliosResult.fold(
      (failure) => Left(failure),
      (portfolios) => assignmentResult.fold(
        (failure) => Left(failure),
        (assignment) {
          final assigned = portfolios
              .where(
                  (portfolio) => assignment.portfolioIds.contains(portfolio.id))
              .where((portfolio) =>
                  portfolio.isActive && portfolio.isCurrentlyValid)
              .toList()
            ..sort((a, b) => a.priority.compareTo(b.priority));
          return Right(assigned);
        },
      ),
    );
  }

  @override
  Future<Either<Failure, bool>> canUserSellProduct({
    required String userId,
    required String role,
    required String productId,
  }) async {
    final portfoliosResult = await getPortfolios();
    final assignmentResult = await getAssignmentForUser(userId, role);

    return portfoliosResult.fold(
      (failure) => Left(failure),
      (portfolios) => assignmentResult.fold(
        (failure) => Left(failure),
        (assignment) => Right(ProductPortfolioPolicy.canSellProduct(
            assignment: assignment,
            productId: productId,
            portfolios: portfolios)),
      ),
    );
  }

  @override
  Future<Either<Failure, List<PortfolioAuditLog>>> getAuditLogs(
      {String? targetUserId}) async {
    try {
      if (await networkInfo.isConnected) {
        try {
          final remote =
              await remoteDataSource.getAuditLogs(targetUserId: targetUserId);
          final logs = remote.map(PortfolioAuditLog.fromJson).toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
          if (logs.isNotEmpty) return Right(logs);
        } catch (_) {
          // Backend audit endpoint hali bo‘lmasa local fallback ishlaydi.
        }
      }

      return Right(
          await localDataSource.getAuditLogs(targetUserId: targetUserId));
    } catch (e) {
      return Left(CacheFailure(message: 'Audit log o‘qilmadi: $e'));
    }
  }

  @override
  List<ProductPortfolio> get demoPortfolios => const [
        ProductPortfolio(
          id: 'pf_beverages',
          code: 'BEV-001',
          name: 'Ichimliklar portfeli',
          description: 'Gazli ichimliklar, suv va choylar',
          sourceSystem: ProductSourceSystem.oneC,
          assortmentType: AssortmentType.mandatory,
          categoryIds: ['cat_drinks', 'cat_water'],
          productIds: [
            'prod_1',
            'prod_2',
            'prod_3',
            'prod_4',
            'prod_5',
            'prod_9'
          ],
          brands: ['Coca-Cola', 'Fanta', 'Sprite', 'Pepsi', 'Lipton'],
          channels: ['retail', 'wholesale'],
          priority: 1,
        ),
        ProductPortfolio(
          id: 'pf_snacks',
          code: 'SNK-001',
          name: 'Snack va qandolat',
          description: 'Chips, saqich, shokolad va impulse goods',
          sourceSystem: ProductSourceSystem.sap,
          assortmentType: AssortmentType.recommended,
          categoryIds: ['cat_snacks', 'cat_confectionery'],
          productIds: ['prod_6', 'prod_7', 'prod_8'],
          brands: ['Lays', 'Orbit', 'Milka'],
          channels: ['retail'],
          priority: 2,
        ),
        ProductPortfolio(
          id: 'pf_energy_premium',
          code: 'ENR-PRM',
          name: 'Premium va energetiklar',
          description: 'Energetik ichimliklar va premium SKUlar',
          sourceSystem: ProductSourceSystem.mixed,
          assortmentType: AssortmentType.optional,
          categoryIds: ['cat_energy'],
          productIds: ['prod_10'],
          brands: ['Red Bull'],
          channels: ['retail', 'horeca'],
          priority: 3,
        ),
      ];

  PortfolioAssignment demoAssignmentFor(String userId, String role) {
    final portfolioIds =
        ProductPortfolioPolicy.defaultPortfolioIdsForRole(role);

    return PortfolioAssignment(
      id: 'demo_assignment_${role}_$userId',
      userId: userId,
      userRole: role,
      portfolioIds: portfolioIds,
      canSellOutsidePortfolio:
          ProductPortfolioPolicy.defaultCanSellOutsidePortfolio(role),
      assignedAt: DateTime.now(),
      assignedBy: 'system',
    );
  }
}
