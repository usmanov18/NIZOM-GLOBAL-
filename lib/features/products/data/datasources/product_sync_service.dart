import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/one_c/one_c_api_client.dart';
import '../../../../core/network/one_c/one_c_product_models.dart';
import '../../../../core/network/sap/sap_api_client.dart';
import '../../../../core/network/sap/sap_product_models.dart';
import '../../domain/entities/product_entities.dart';

// ============================================================
// PRODUCT SYNC SERVICE
// 1C va SAP dan mahsulotlarni yuklash
// ============================================================

class ProductSyncService {
  final OneCAPIClient oneCClient;
  final SAPAPIClient sapClient;

  ProductSyncService({
    required this.oneCClient,
    required this.sapClient,
  });

  // ============ 1C DAN YUKLASH ============

  /// 1C dan barcha mahsulotlarni yuklash
  Future<Either<Failure, List<OneCProduct>>> fetchProductsFrom1C({
    DateTime? sinceDate,
    String? categoryKey,
    int top = 500,
    int skip = 0,
  }) async {
    try {
      final filters = <String>['ПометкаУдаления eq false'];

      if (sinceDate != null) {
        filters
            .add("ДатаИзменения ge datetime'${sinceDate.toIso8601String()}'");
      }
      if (categoryKey != null) {
        filters.add("Родитель_Key eq guid'$categoryKey'");
      }

      final result = await oneCClient.getProducts(
        search: filters.isNotEmpty ? filters.join(' and ') : null,
        top: top,
        skip: skip,
      );

      return result.fold(
        (failure) => Left(failure),
        (data) {
          final products =
              data.map((json) => OneCProduct.fromJson(json)).toList();
          return Right(products);
        },
      );
    } catch (e) {
      return Left(
          ServerFailure(message: '1C dan mahsulotlar yuklashda xatolik: $e'));
    }
  }

  /// 1C dan barcha mahsulotlarni sahifalab yuklash
  Future<Either<Failure, List<OneCProduct>>> fetchAllProductsFrom1C({
    DateTime? sinceDate,
    String? categoryKey,
    int pageSize = 500,
  }) async {
    final allProducts = <OneCProduct>[];
    int skip = 0;
    bool hasMore = true;

    while (hasMore) {
      final result = await fetchProductsFrom1C(
        sinceDate: sinceDate,
        categoryKey: categoryKey,
        top: pageSize,
        skip: skip,
      );

      result.fold(
        (failure) => hasMore = false,
        (products) {
          allProducts.addAll(products);
          if (products.length < pageSize) {
            hasMore = false;
          } else {
            skip += pageSize;
          }
        },
      );
    }

    return Right(allProducts);
  }

  /// 1C dan narxlarni yuklash
  Future<Either<Failure, List<OneCPrice>>> fetchPricesFrom1C({
    String? priceGroupKey,
    DateTime? sinceDate,
  }) async {
    try {
      final result = await oneCClient.getActiveDiscounts(
        priceGroupRefKey: priceGroupKey,
      );

      return result.fold(
        (failure) => Left(failure),
        (data) {
          final prices = data.map((json) => OneCPrice.fromJson(json)).toList();
          return Right(prices);
        },
      );
    } catch (e) {
      return Left(
          ServerFailure(message: '1C dan narxlar yuklashda xatolik: $e'));
    }
  }

  /// 1C dan ombor qoldiqlarini yuklash
  Future<Either<Failure, List<OneCStock>>> fetchStockFrom1C({
    String? warehouseKey,
    String? productKey,
  }) async {
    try {
      final result = await oneCClient.getStockBalance(
        warehouseRefKey: warehouseKey ?? '',
        productRefKey: productKey,
      );

      return result.fold(
        (failure) => Left(failure),
        (data) {
          final stocks = data.map((json) => OneCStock.fromJson(json)).toList();
          return Right(stocks);
        },
      );
    } catch (e) {
      return Left(
          ServerFailure(message: '1C dan qoldiqlar yuklashda xatolik: $e'));
    }
  }

  /// 1C dan kategoriyalarni yuklash
  Future<Either<Failure, List<OneCCategory>>> fetchCategoriesFrom1C() async {
    try {
      final productsResult = await fetchProductsFrom1C(top: 1000);
      return productsResult.fold(
        (failure) => Left(failure),
        (products) {
          final grouped = <String, int>{};
          for (final product in products) {
            final key = product.categoryKey.isEmpty
                ? 'uncategorized'
                : product.categoryKey;
            grouped[key] = (grouped[key] ?? 0) + 1;
          }
          final categories = grouped.entries
              .map((entry) => OneCCategory(
                    refKey: entry.key,
                    code: entry.key,
                    description: entry.key == 'uncategorized'
                        ? 'Kategoriyasiz'
                        : entry.key,
                    level: 0,
                    isFolder: true,
                    isMarkedForDeletion: false,
                    productCount: entry.value,
                  ))
              .toList();
          return Right(categories);
        },
      );
    } catch (e) {
      return Left(
          ServerFailure(message: '1C dan kategoriyalar yuklashda xatolik: $e'));
    }
  }

  // ============ SAP DAN YUKLASH ============

  /// SAP dan barcha mahsulotlarni yuklash
  Future<Either<Failure, List<SAPProduct>>> fetchProductsFromSAP({
    DateTime? sinceDate,
    String? materialGroup,
    int top = 500,
    int skip = 0,
  }) async {
    try {
      final result = await sapClient.getProducts(
        productGroup: materialGroup,
        top: top,
        skip: skip,
      );

      return result.fold(
        (failure) => Left(failure),
        (data) {
          final products =
              data.map((json) => SAPProduct.fromJson(json)).toList();
          return Right(products);
        },
      );
    } catch (e) {
      return Left(
          ServerFailure(message: 'SAP dan mahsulotlar yuklashda xatolik: $e'));
    }
  }

  /// SAP dan barcha mahsulotlarni sahifalab yuklash
  Future<Either<Failure, List<SAPProduct>>> fetchAllProductsFromSAP({
    DateTime? sinceDate,
    String? materialGroup,
    int pageSize = 500,
  }) async {
    final allProducts = <SAPProduct>[];
    int skip = 0;
    bool hasMore = true;

    while (hasMore) {
      final result = await fetchProductsFromSAP(
        sinceDate: sinceDate,
        materialGroup: materialGroup,
        top: pageSize,
        skip: skip,
      );

      result.fold(
        (failure) => hasMore = false,
        (products) {
          allProducts.addAll(products);
          if (products.length < pageSize) {
            hasMore = false;
          } else {
            skip += pageSize;
          }
        },
      );
    }

    return Right(allProducts);
  }

  /// SAP dan narx shartlarini yuklash
  Future<Either<Failure, List<SAPConditionRecord>>> fetchPricesFromSAP({
    String? salesOrganization,
    String? distributionChannel,
    String? material,
  }) async {
    try {
      final result = await sapClient.getPriceList(
        salesOrganization: salesOrganization ?? '1000',
        distributionChannel: distributionChannel ?? '10',
        material: material,
      );

      return result.fold(
        (failure) => Left(failure),
        (data) {
          final conditions =
              data.map((json) => SAPConditionRecord.fromJson(json)).toList();
          return Right(conditions);
        },
      );
    } catch (e) {
      return Left(
          ServerFailure(message: 'SAP dan narxlar yuklashda xatolik: $e'));
    }
  }

  /// SAP dan ombor qoldiqlarini yuklash
  Future<Either<Failure, List<SAPStockLevel>>> fetchStockFromSAP({
    String? plant,
    String? material,
  }) async {
    try {
      final result = await sapClient.getStockBalance(
        plant: plant ?? '1000',
        material: material,
      );

      return result.fold(
        (failure) => Left(failure),
        (data) {
          final stocks =
              data.map((json) => SAPStockLevel.fromJson(json)).toList();
          return Right(stocks);
        },
      );
    } catch (e) {
      return Left(
          ServerFailure(message: 'SAP dan qoldiqlar yuklashda xatolik: $e'));
    }
  }

  // ============ CONVERT TO DOMAIN ============

  /// 1C mahsulotlarini domain modelga aylantirish
  List<Product> convert1CProducts(List<OneCProduct> products) {
    return products
        .map((p) => Product(
              id: p.refKey,
              externalId1C: p.refKey,
              externalIdSAP: '',
              code: p.code,
              name: p.description,
              description: p.fullDescription,
              sku: p.article.isNotEmpty ? p.article : p.code,
              barcode: p.barcode.isNotEmpty ? p.barcode : null,
              article: p.article.isNotEmpty ? p.article : null,
              categoryId: p.categoryKey,
              categoryName: p.categoryName,
              subcategoryId: null,
              subcategoryName: null,
              unitOfMeasure: p.baseUnitName,
              altUnitOfMeasure: p.salesUnitName,
              conversionFactor: p.salesUnitFactor,
              weight: p.weight ?? 0,
              volume: p.volume ?? 0,
              length: p.length,
              width: p.width,
              height: p.height,
              basePrice: p.basePrice ?? 0,
              minPrice: p.minPrice,
              maxPrice: null,
              currency: p.currency,
              stockQuantity: p.stockQuantity,
              reservedQuantity: p.reservedQuantity,
              availableQuantity: p.availableQuantity,
              reorderLevel: p.reorderPoint,
              maxStock: p.maxStock,
              imageUrl: p.imageUrl,
              images: p.additionalImages,
              brand: p.brandName,
              manufacturer: p.manufacturerName,
              countryOfOrigin: p.countryOfOriginName,
              color: p.color,
              size: p.size,
              attributes: p.customAttributes,
              hasDiscount: p.hasAutomaticDiscount,
              discountPercent: p.discountPercent,
              discountPrice: null,
              promotionId: p.promotionKey,
              promotionName: null,
              isActive: p.isActive && !p.isMarkedForDeletion,
              isAvailable: p.availableQuantity > 0,
              isNew: p.isNew,
              isPopular: p.isPopular,
              isFeatured: p.isFeatured,
              syncSource: '1c',
              lastSyncedAt: DateTime.now(),
              createdAt: p.createdAt,
              updatedAt: p.updatedAt,
            ))
        .toList();
  }

  /// SAP mahsulotlarini domain modelga aylantirish
  List<Product> convertSAPProducts(List<SAPProduct> products) {
    return products
        .map((p) => Product(
              id: p.material,
              externalId1C: '',
              externalIdSAP: p.material,
              code: p.material,
              name: p.materialDescription,
              description: p.materialLongDescription,
              sku: p.material,
              barcode: p.eanUPC,
              article: p.manufacturerPartNumber,
              categoryId: p.materialGroup,
              categoryName: p.materialGroupName,
              subcategoryId: null,
              subcategoryName: null,
              unitOfMeasure: p.baseUnit,
              altUnitOfMeasure: p.salesUnit,
              conversionFactor: null,
              weight: p.grossWeight ?? 0,
              volume: p.volume ?? 0,
              length: p.length,
              width: p.width,
              height: p.height,
              basePrice: p.standardPrice ?? 0,
              minPrice: null,
              maxPrice: null,
              currency: 'UZS',
              stockQuantity: p.stockQuantity ?? 0,
              reservedQuantity: 0,
              availableQuantity: p.unrestrictedStock ?? 0,
              reorderLevel: null,
              maxStock: null,
              imageUrl: p.materialImageUrl,
              images: [],
              brand: p.manufacturerName,
              manufacturer: p.manufacturerName,
              countryOfOrigin: p.countryOfOriginName,
              color: null,
              size: null,
              attributes: null,
              hasDiscount: p.hasConditionRecord,
              discountPercent: null,
              discountPrice: p.conditionRate,
              promotionId: null,
              promotionName: null,
              isActive: !p.isMarkedForDeletion && !p.isBlockedForSales,
              isAvailable: (p.unrestrictedStock ?? 0) > 0,
              isNew: false,
              isPopular: false,
              isFeatured: false,
              syncSource: 'sap',
              lastSyncedAt: DateTime.now(),
              createdAt: p.createdAt ?? DateTime.now(),
              updatedAt: p.lastChangedAt,
            ))
        .toList();
  }
}
