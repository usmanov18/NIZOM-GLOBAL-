import 'package:dartz/dartz.dart' hide Order;

import '../../../../core/errors/failures.dart';
import '../../../../core/config/env_config.dart';
import '../../../../core/network/api_error_mapper.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/order_flow_entities.dart';
import '../../domain/entities/order_catalog_product.dart';
import '../../domain/repositories/order_catalog_repository.dart';
import '../datasources/order_catalog_datasource.dart';
import '../datasources/order_catalog_local_datasource.dart';
import '../datasources/order_catalog_remote_datasource.dart';

class OrderCatalogRepositoryImpl implements OrderCatalogRepository {
  final OrderCatalogDataSource fallbackDataSource;
  final OrderCatalogLocalDataSource localDataSource;
  final OrderCatalogRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  OrderCatalogRepositoryImpl({
    required this.fallbackDataSource,
    required this.localDataSource,
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<OrderCustomer>>> getCustomers(
      {String? search}) async {
    try {
      if (await networkInfo.isConnected) {
        try {
          final remote = await remoteDataSource.getCustomers(search: search);
          if (remote.isNotEmpty) {
            await localDataSource.cacheCustomers(remote);
            return Right(remote);
          }
        } catch (_) {}
      }

      final cached = await localDataSource.getCachedCustomers(search: search);
      if (cached.isNotEmpty) return Right(cached);

      if (EnvConfig.isDemoMode) {
        return Right(await fallbackDataSource.getCustomers(search: search));
      }
      return const Left(CacheFailure(message: 'Mijozlar katalogi topilmadi'));
    } catch (e) {
      if (e is DioException)
        return Left(ApiErrorMapper.fromDio(e,
            defaultMessage: 'Mijozlar katalogi yuklanmadi'));
      return Left(CacheFailure(message: 'Mijozlar katalogi yuklanmadi: $e'));
    }
  }

  @override
  Future<Either<Failure, List<OrderCatalogProduct>>> getProducts(
      {String? search, String? portfolioId, String? assortment}) async {
    try {
      if (await networkInfo.isConnected) {
        try {
          final remote = await remoteDataSource.getProducts(
              search: search, portfolioId: portfolioId, assortment: assortment);
          if (remote.isNotEmpty) {
            await localDataSource.cacheProducts(remote);
            return Right(remote);
          }
        } catch (_) {}
      }

      final cached = await localDataSource.getCachedProducts(
          search: search, portfolioId: portfolioId, assortment: assortment);
      if (cached.isNotEmpty) return Right(cached);

      if (EnvConfig.isDemoMode) {
        return Right(await fallbackDataSource.getProducts(
            search: search, portfolioId: portfolioId, assortment: assortment));
      }
      return const Left(
          CacheFailure(message: 'Mahsulotlar katalogi topilmadi'));
    } catch (e) {
      if (e is DioException)
        return Left(ApiErrorMapper.fromDio(e,
            defaultMessage: 'Mahsulotlar katalogi yuklanmadi'));
      return Left(CacheFailure(message: 'Mahsulotlar katalogi yuklanmadi: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> getProductStock(
      {required String productId, required String warehouseId}) async {
    try {
      if (await networkInfo.isConnected) {
        try {
          return Right(await remoteDataSource.getProductStock(
              productId: productId, warehouseId: warehouseId));
        } catch (_) {}
      }
      if (EnvConfig.isDemoMode) {
        return Right(await fallbackDataSource.getProductStock(
            productId: productId, warehouseId: warehouseId));
      }
      return const Left(CacheFailure(message: 'Ombor qoldig‘i topilmadi'));
    } catch (e) {
      if (e is DioException)
        return Left(
            ApiErrorMapper.fromDio(e, defaultMessage: 'Qoldiq yuklanmadi'));
      return Left(CacheFailure(message: 'Qoldiq yuklanmadi: $e'));
    }
  }
}
