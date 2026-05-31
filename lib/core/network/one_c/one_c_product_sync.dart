import 'dart:async';
import 'one_c_api_client.dart';

// ============================================================
// 1C PRODUCT SYNC - Mahsulotlarni 1C dan yuklash
// ============================================================

class OneCProductSync {
  final OneCAPIClient client;

  OneCProductSync(this.client);

  /// Barcha mahsulotlarni yuklash
  Future<List<OneCProduct>> fetchProducts({
    DateTime? sinceDate,
    String? categoryId,
    int top = 500,
    int skip = 0,
  }) async {
    final filters = <String>['ПометкаУдаления eq false'];
    if (sinceDate != null) {
      filters.add("Modified gt datetime'${sinceDate.toIso8601String()}'");
    }
    if (categoryId != null) {
      filters.add("ProductCategory_Key eq guid'$categoryId'");
    }

    final response = await client.get(
      '/catalog/Products',
      queryParameters: {
        r'$filter': filters.join(' and '),
        r'$orderby': 'Description asc',
        r'$top': top,
        r'$skip': skip,
        r'$format': 'json',
      },
    );

    final data = response.data['value'] as List;
    return data.map((json) => OneCProduct.fromJson(json)).toList();
  }

  /// Sahifalab yuklash
  Future<List<OneCProduct>> fetchAllProducts({
    DateTime? sinceDate,
    String? categoryId,
    int pageSize = 500,
  }) async {
    final allProducts = <OneCProduct>[];
    int skip = 0;
    bool hasMore = true;

    while (hasMore) {
      final batch = await fetchProducts(
        sinceDate: sinceDate,
        categoryId: categoryId,
        top: pageSize,
        skip: skip,
      );

      allProducts.addAll(batch);
      hasMore = batch.length >= pageSize;
      skip += pageSize;
    }

    return allProducts;
  }

  /// Kategoriyalarni yuklash
  Future<List<OneCCategory>> fetchCategories() async {
    final response = await client.get(
      '/catalog/ProductCategories',
      queryParameters: {r'$format': 'json'},
    );

    final data = response.data['value'] as List;
    return data.map((json) => OneCCategory.fromJson(json)).toList();
  }
}

/// 1C Mahsulot model
class OneCProduct {
  final String refKey;
  final String code;
  final String name;
  final String sku;
  final String? barcode;
  final String categoryKey;
  final String categoryName;
  final String unitOfMeasure;
  final double weight;
  final double volume;
  final double basePrice;
  final double? minPrice;
  final String currency;
  final double stockQuantity;
  final double availableQuantity;
  final bool isActive;
  final bool isNew;
  final bool isPopular;
  final String? imageUrl;
  final String? brand;
  final String? manufacturer;
  final DateTime? lastModified;

  const OneCProduct({
    required this.refKey,
    required this.code,
    required this.name,
    required this.sku,
    this.barcode,
    required this.categoryKey,
    required this.categoryName,
    required this.unitOfMeasure,
    required this.weight,
    required this.volume,
    required this.basePrice,
    this.minPrice,
    required this.currency,
    required this.stockQuantity,
    required this.availableQuantity,
    required this.isActive,
    required this.isNew,
    required this.isPopular,
    this.imageUrl,
    this.brand,
    this.manufacturer,
    this.lastModified,
  });

  factory OneCProduct.fromJson(Map<String, dynamic> json) {
    return OneCProduct(
      refKey: json['Ref_Key'] ?? '',
      code: json['Code'] ?? '',
      name: json['Description'] ?? '',
      sku: json['Артикул'] ?? json['SKU'] ?? '',
      barcode: json['Штрихкод'] ?? json['Barcode'],
      categoryKey: json['ProductCategory_Key'] ?? '',
      categoryName: json['ProductCategory_Description'] ?? '',
      unitOfMeasure: json['ЕдиницаХраненияОстатков_Description'] ??
          json['UnitOfMeasure'] ??
          'шт',
      weight: (json['ВесБрутто'] ?? json['Weight'] ?? 0).toDouble(),
      volume: (json['Объем'] ?? json['Volume'] ?? 0).toDouble(),
      basePrice: (json['ОсновнаяЦена'] ?? json['BasePrice'] ?? 0).toDouble(),
      minPrice: json['МинимальнаяЦена']?.toDouble(),
      currency: json['ВалютаЦены'] ?? json['Currency'] ?? 'UZS',
      stockQuantity:
          (json['ОстатокНаСкладе'] ?? json['StockQuantity'] ?? 0).toDouble(),
      availableQuantity:
          (json['Доступно'] ?? json['AvailableQuantity'] ?? 0).toDouble(),
      isActive: !(json['ПометкаУдаления'] ?? json['DeletionMark'] ?? false),
      isNew: json['Новинка'] ?? json['IsNew'] ?? false,
      isPopular: json['Популярный'] ?? json['IsPopular'] ?? false,
      imageUrl: json['ФайлНоменклатуры_URL'] ?? json['ImageUrl'],
      brand: json['Марка_Description'] ?? json['Brand'],
      manufacturer: json['Производитель_Description'] ?? json['Manufacturer'],
      lastModified:
          json['Modified'] != null ? DateTime.parse(json['Modified']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'Ref_Key': refKey,
        'Code': code,
        'Description': name,
        'Артикул': sku,
        'Штрихкод': barcode,
        'ProductCategory_Key': categoryKey,
        'ProductCategory_Description': categoryName,
        'ЕдиницаХраненияОстатков_Description': unitOfMeasure,
        'ВесБрутто': weight,
        'Объем': volume,
        'ОсновнаяЦена': basePrice,
        'МинимальнаяЦена': minPrice,
        'ВалютаЦены': currency,
        'ОстатокНаСкладе': stockQuantity,
        'Доступно': availableQuantity,
        'ПометкаУдаления': !isActive,
        'Новинка': isNew,
        'Популярный': isPopular,
      };
}

/// 1C Kategoriya model
class OneCCategory {
  final String refKey;
  final String code;
  final String name;
  final String? parentKey;
  final String? parentName;
  final bool isFolder;
  final int productCount;

  const OneCCategory({
    required this.refKey,
    required this.code,
    required this.name,
    this.parentKey,
    this.parentName,
    required this.isFolder,
    required this.productCount,
  });

  factory OneCCategory.fromJson(Map<String, dynamic> json) {
    return OneCCategory(
      refKey: json['Ref_Key'] ?? '',
      code: json['Code'] ?? '',
      name: json['Description'] ?? '',
      parentKey: json['Родитель_Key'] ?? json['Parent_Key'],
      parentName: json['Родитель_Description'] ?? json['Parent_Description'],
      isFolder: json['ЭтоГруппа'] ?? json['IsFolder'] ?? false,
      productCount: json['КоличествоНоменклатуры'] ?? json['ProductCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'Ref_Key': refKey,
        'Code': code,
        'Description': name,
        'Родитель_Key': parentKey,
        'ЭтоГруппа': isFolder,
      };
}
