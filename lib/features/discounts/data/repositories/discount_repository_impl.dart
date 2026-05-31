import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/discount_entities.dart';
import '../../domain/repositories/discount_repository.dart';
import '../datasources/discount_remote_datasource.dart';
import '../datasources/discount_local_datasource.dart';
import '../models/discount_models_mapper.dart';

// ============================================================
// DISCOUNT REPOSITORY IMPLEMENTATION
// ============================================================

class DiscountRepositoryImpl implements DiscountRepository {
  final DiscountRemoteDataSource remoteDataSource;
  final DiscountLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  DiscountRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<ProductDiscount>>> getActiveDiscounts({
    String? priceGroupId,
    String? productId,
    String? categoryId,
  }) async {
    try {
      if (await networkInfo.isConnected) {
        final data = await remoteDataSource.getActiveDiscounts(
          priceGroupId: priceGroupId,
          productId: productId,
          categoryId: categoryId,
        );
        await localDataSource.cacheDiscounts(data);
        return Right(
            data.map((d) => ProductDiscountMapper.fromJson(d)).toList());
      } else {
        final cached = await localDataSource.getCachedDiscounts(
          priceGroupId: priceGroupId,
        );
        return Right(
            cached.map((d) => ProductDiscountMapper.fromJson(d)).toList());
      }
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, List<ProductDiscount>>> getDiscountsForProduct({
    required String productId,
    required String priceGroupId,
    required double quantity,
    required double amount,
  }) async {
    try {
      final data = await remoteDataSource.getDiscountsForProduct(
        productId: productId,
        priceGroupId: priceGroupId,
        quantity: quantity,
        amount: amount,
      );
      return Right(data.map((d) => ProductDiscountMapper.fromJson(d)).toList());
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, ProductDiscount>> getDiscountById(String id) async {
    try {
      final data = await remoteDataSource.getDiscountById(id);
      return Right(ProductDiscountMapper.fromJson(data));
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, List<Promotion>>> getActivePromotions({
    String? customerGroup,
    String? region,
  }) async {
    try {
      if (await networkInfo.isConnected) {
        final data = await remoteDataSource.getActivePromotions(
          customerGroup: customerGroup,
          region: region,
        );
        await localDataSource.cachePromotions(data);
        return Right(data.map((d) => PromotionMapper.fromJson(d)).toList());
      } else {
        final cached = await localDataSource.getCachedPromotions();
        return Right(cached.map((d) => PromotionMapper.fromJson(d)).toList());
      }
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, Promotion>> getPromotionById(String id) async {
    try {
      final data = await remoteDataSource.getPromotionById(id);
      return Right(PromotionMapper.fromJson(data));
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, Promotion>> validatePromoCode(String code) async {
    try {
      final data = await remoteDataSource.validatePromoCode(code);
      return Right(PromotionMapper.fromJson(data));
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, bool>> applyPromotion({
    required String promotionId,
    required String orderId,
    required String customerId,
  }) async {
    try {
      if (promotionId.trim().isEmpty ||
          orderId.trim().isEmpty ||
          customerId.trim().isEmpty) {
        return const Left(ValidationFailure(
            message: 'Promo qo‘llash uchun majburiy maydonlar to‘ldirilmagan'));
      }
      return const Right(true);
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, List<SpecialPrice>>> getSpecialPrices({
    required String priceGroupId,
    List<String>? productIds,
  }) async {
    try {
      if (await networkInfo.isConnected) {
        final data = await remoteDataSource.getSpecialPrices(
          priceGroupId: priceGroupId,
          productIds: productIds,
        );
        await localDataSource.cacheSpecialPrices(data);
        return Right(data.map((d) => SpecialPriceMapper.fromJson(d)).toList());
      } else {
        final cached = await localDataSource.getCachedSpecialPrices(
          priceGroupId: priceGroupId,
        );
        return Right(
            cached.map((d) => SpecialPriceMapper.fromJson(d)).toList());
      }
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, SpecialPrice?>> getSpecialPrice({
    required String productId,
    required String priceGroupId,
  }) async {
    try {
      final prices = await getSpecialPrices(priceGroupId: priceGroupId);
      return prices.fold(
        (failure) => Left(failure),
        (list) {
          SpecialPrice? price;
          for (final item in list) {
            if (item.productId == productId) {
              price = item;
              break;
            }
          }
          return Right(price);
        },
      );
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, List<ProductDiscount>>> syncDiscountsFrom1C(
      {DateTime? sinceDate}) async {
    try {
      final data =
          await remoteDataSource.syncDiscountsFrom1C(sinceDate: sinceDate);
      await localDataSource.cacheDiscounts(data);
      return Right(data.map((d) => ProductDiscountMapper.fromJson(d)).toList());
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, List<ProductDiscount>>> syncDiscountsFromSAP(
      {DateTime? sinceDate}) async {
    try {
      final data =
          await remoteDataSource.syncDiscountsFromSAP(sinceDate: sinceDate);
      await localDataSource.cacheDiscounts(data);
      return Right(data.map((d) => ProductDiscountMapper.fromJson(d)).toList());
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, List<Promotion>>> syncPromotionsFrom1C(
      {DateTime? sinceDate}) async {
    try {
      final data =
          await remoteDataSource.syncPromotionsFrom1C(sinceDate: sinceDate);
      await localDataSource.cachePromotions(data);
      return Right(data.map((d) => PromotionMapper.fromJson(d)).toList());
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, List<Promotion>>> syncPromotionsFromSAP(
      {DateTime? sinceDate}) async {
    try {
      final data =
          await remoteDataSource.syncPromotionsFromSAP(sinceDate: sinceDate);
      await localDataSource.cachePromotions(data);
      return Right(data.map((d) => PromotionMapper.fromJson(d)).toList());
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, List<SpecialPrice>>> syncSpecialPricesFrom1C(
      {String? priceGroupId}) async {
    try {
      final data = await remoteDataSource.syncSpecialPricesFrom1C(
          priceGroupId: priceGroupId);
      await localDataSource.cacheSpecialPrices(data);
      return Right(data.map((d) => SpecialPriceMapper.fromJson(d)).toList());
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, List<SpecialPrice>>> syncSpecialPricesFromSAP(
      {String? priceGroupId}) async {
    try {
      final data = await remoteDataSource.syncSpecialPricesFromSAP(
          priceGroupId: priceGroupId);
      await localDataSource.cacheSpecialPrices(data);
      return Right(data.map((d) => SpecialPriceMapper.fromJson(d)).toList());
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, DiscountSyncResult>> syncAllDiscounts() async {
    try {
      final startTime = DateTime.now();

      final discountsResult = await syncDiscountsFrom1C();
      final promotionsResult = await syncPromotionsFrom1C();
      final pricesResult = await syncSpecialPricesFrom1C();

      await localDataSource.saveLastSyncTime();

      int discountsCount = 0;
      int promotionsCount = 0;
      int pricesCount = 0;

      discountsResult.fold((_) {}, (d) => discountsCount = d.length);
      promotionsResult.fold((_) {}, (p) => promotionsCount = p.length);
      pricesResult.fold((_) {}, (p) => pricesCount = p.length);

      return Right(DiscountSyncResult(
        discountsSynced: discountsCount,
        promotionsSynced: promotionsCount,
        specialPricesSynced: pricesCount,
        errors: [],
        completedAt: DateTime.now(),
      ));
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, DateTime?>> getLastSyncTime() async {
    try {
      final time = await localDataSource.getLastSyncTime();
      return Right(time);
    } catch (e) {
      return const Right(null);
    }
  }

  @override
  Future<Either<Failure, List<ProductDiscount>>> getCachedDiscounts() async {
    try {
      final cached = await localDataSource.getCachedDiscounts();
      return Right(
          cached.map((d) => ProductDiscountMapper.fromJson(d)).toList());
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, List<Promotion>>> getCachedPromotions() async {
    try {
      final cached = await localDataSource.getCachedPromotions();
      return Right(cached.map((d) => PromotionMapper.fromJson(d)).toList());
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, List<SpecialPrice>>> getCachedSpecialPrices() async {
    try {
      final cached = await localDataSource.getCachedSpecialPrices();
      return Right(cached.map((d) => SpecialPriceMapper.fromJson(d)).toList());
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }
}
