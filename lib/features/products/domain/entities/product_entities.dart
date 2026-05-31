import 'package:equatable/equatable.dart';
import '../../../../core/utils/url_helper.dart';

// ============================================================
// PRODUCT ENTITIES - 1C va SAP dan yuklanadigan mahsulotlar
// ============================================================

// ============ MAHSULOT ============

/// Asosiy mahsulot entity
class Product extends Equatable {
  final String id;
  final String externalId1C; // 1C Ref_Key
  final String externalIdSAP; // SAP Material
  final String code; // Mahsulot kodi
  final String name; // Nomi
  final String? description; // Tavsif
  final String sku; // SKU
  final String? barcode; // Shtrix kod
  final String? article; // Artikul

  // Kategoriya
  final String categoryId;
  final String categoryName;
  final String? subcategoryId;
  final String? subcategoryName;

  // Birliklar
  final String unitOfMeasure; // dona, kg, litr, quti
  final String? altUnitOfMeasure; // Muqobil birlik
  final double? conversionFactor; // Aylantirish koeffitsienti

  // O'lchamlar
  final double weight; // kg
  final double volume; // m3
  final double? length; // m
  final double? width; // m
  final double? height; // m

  // Narx
  final double basePrice; // Asosiy narx
  final double? minPrice; // Min narx
  final double? maxPrice; // Max narx
  final String currency; // UZS

  // Ombor
  final double stockQuantity; // Ombordagi qoldiq
  final double reservedQuantity; // Band qilingan
  final double availableQuantity; // Mavjud
  final double? reorderLevel; // Qayta buyurtma darajasi
  final double? maxStock; // Max qoldiq

  // Rasm
  final String? imageUrl;
  final List<String> images;

  // Xususiyatlar
  final String? brand;
  final String? manufacturer;
  final String? countryOfOrigin;
  final String? color;
  final String? size;
  final Map<String, dynamic>? attributes;

  // Chegirmalar
  final bool hasDiscount;
  final double? discountPercent;
  final double? discountPrice;
  final String? promotionId;
  final String? promotionName;

  // Holat
  final bool isActive;
  final bool isAvailable;
  final bool isNew;
  final bool isPopular;
  final bool isFeatured;

  // Sinxronlash
  final String syncSource; // 1c, sap, manual
  final DateTime lastSyncedAt;
  final String? syncError;

  // Sana
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Product({
    required this.id,
    required this.externalId1C,
    required this.externalIdSAP,
    required this.code,
    required this.name,
    this.description,
    required this.sku,
    this.barcode,
    this.article,
    required this.categoryId,
    required this.categoryName,
    this.subcategoryId,
    this.subcategoryName,
    required this.unitOfMeasure,
    this.altUnitOfMeasure,
    this.conversionFactor,
    required this.weight,
    required this.volume,
    this.length,
    this.width,
    this.height,
    required this.basePrice,
    this.minPrice,
    this.maxPrice,
    required this.currency,
    required this.stockQuantity,
    required this.reservedQuantity,
    required this.availableQuantity,
    this.reorderLevel,
    this.maxStock,
    this.imageUrl,
    this.images = const [],
    this.brand,
    this.manufacturer,
    this.countryOfOrigin,
    this.color,
    this.size,
    this.attributes,
    required this.hasDiscount,
    this.discountPercent,
    this.discountPrice,
    this.promotionId,
    this.promotionName,
    required this.isActive,
    required this.isAvailable,
    required this.isNew,
    required this.isPopular,
    required this.isFeatured,
    required this.syncSource,
    required this.lastSyncedAt,
    this.syncError,
    required this.createdAt,
    this.updatedAt,
  });

  bool get isInStock => availableQuantity > 0;
  bool get isLowStock =>
      reorderLevel != null && availableQuantity <= reorderLevel!;
  bool get isOutOfStock => availableQuantity <= 0;
  double get effectivePrice =>
      hasDiscount && discountPrice != null ? discountPrice! : basePrice;

  factory Product.from1C(Map<String, dynamic> json) {
    return Product(
      id: json['Ref_Key'] ?? '',
      externalId1C: json['Ref_Key'] ?? '',
      externalIdSAP: '',
      code: json['Code'] ?? '',
      name: json['Description'] ?? '',
      description: json['DescriptionFull'],
      sku: json['SKU'] ?? json['Code'] ?? '',
      barcode: json['Barcode'],
      article: json['Article'],
      categoryId: json['ProductCategory_Key'] ?? '',
      categoryName: json['ProductCategory_Description'] ?? '',
      subcategoryId: json['Subcategory_Key'],
      subcategoryName: json['Subcategory_Description'],
      unitOfMeasure: json['UnitOfMeasure'] ?? 'dona',
      weight: (json['Weight'] ?? 0).toDouble(),
      volume: (json['Volume'] ?? 0).toDouble(),
      basePrice: (json['BasePrice'] ?? 0).toDouble(),
      minPrice: json['MinPrice']?.toDouble(),
      maxPrice: json['MaxPrice']?.toDouble(),
      currency: json['Currency'] ?? 'UZS',
      stockQuantity: (json['StockQuantity'] ?? 0).toDouble(),
      reservedQuantity: (json['ReservedQuantity'] ?? 0).toDouble(),
      availableQuantity: (json['AvailableQuantity'] ?? 0).toDouble(),
      imageUrl: UrlHelper.secure(json['ImageUrl']),
      brand: json['Brand'],
      manufacturer: json['Manufacturer'],
      countryOfOrigin: json['CountryOfOrigin'],
      isActive: json['DeletionMark'] != true,
      isAvailable: json['IsAvailable'] ?? true,
      isNew: json['IsNew'] ?? false,
      isPopular: json['IsPopular'] ?? false,
      isFeatured: json['IsFeatured'] ?? false,
      hasDiscount: json['HasDiscount'] ?? false,
      discountPercent: json['DiscountPercent']?.toDouble(),
      discountPrice: json['DiscountPrice']?.toDouble(),
      syncSource: '1c',
      lastSyncedAt: DateTime.now(),
      createdAt: json['CreatedAt'] != null
          ? DateTime.parse(json['CreatedAt'])
          : DateTime.now(),
    );
  }

  factory Product.fromSAP(Map<String, dynamic> json) {
    return Product(
      id: json['Material'] ?? '',
      externalId1C: '',
      externalIdSAP: json['Material'] ?? '',
      code: json['Material'] ?? '',
      name: json['MaterialDescription'] ?? '',
      description: json['MaterialLongDescription'],
      sku: json['Material'] ?? '',
      barcode: json['EAN_UPC'],
      article: json['ManufacturerPartNumber'],
      categoryId: json['MaterialGroup'] ?? '',
      categoryName: json['MaterialGroupName'] ?? '',
      unitOfMeasure: json['BaseUnit'] ?? 'EA',
      weight: (json['GrossWeight'] ?? 0).toDouble(),
      volume: (json['Volume'] ?? 0).toDouble(),
      basePrice: (json['StandardPrice'] ?? 0).toDouble(),
      currency: json['Currency'] ?? 'UZS',
      stockQuantity: (json['StockQuantity'] ?? 0).toDouble(),
      reservedQuantity: 0,
      availableQuantity: (json['StockQuantity'] ?? 0).toDouble(),
      imageUrl: json['MaterialImageUrl'],
      brand: json['Brand'],
      manufacturer: json['ManufacturerName'],
      isActive: json['IsMarkedForDeletion'] != true,
      isAvailable: true,
      isNew: false,
      isPopular: false,
      isFeatured: false,
      hasDiscount: false,
      syncSource: 'sap',
      lastSyncedAt: DateTime.now(),
      createdAt: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [id, externalId1C, externalIdSAP, code, sku];
}

// ============ KATEGORIYA ============

/// Mahsulot kategoriyasi
class ProductCategory extends Equatable {
  final String id;
  final String externalId1C;
  final String externalIdSAP;
  final String code;
  final String name;
  final String? description;
  final String? parentId;
  final String? parentName;
  final String? imageUrl;
  final int level; // Daraja (0, 1, 2...)
  final int sortOrder;
  final int productCount;
  final bool isActive;
  final DateTime lastSyncedAt;

  const ProductCategory({
    required this.id,
    required this.externalId1C,
    required this.externalIdSAP,
    required this.code,
    required this.name,
    this.description,
    this.parentId,
    this.parentName,
    this.imageUrl,
    required this.level,
    required this.sortOrder,
    required this.productCount,
    required this.isActive,
    required this.lastSyncedAt,
  });

  bool get isRoot => parentId == null;
  bool get hasChildren => productCount > 0;

  factory ProductCategory.from1C(Map<String, dynamic> json) {
    return ProductCategory(
      id: json['Ref_Key'] ?? '',
      externalId1C: json['Ref_Key'] ?? '',
      externalIdSAP: '',
      code: json['Code'] ?? '',
      name: json['Description'] ?? '',
      description: json['DescriptionFull'],
      parentId: json['Parent_Key'],
      parentName: json['Parent_Description'],
      imageUrl: UrlHelper.secure(json['ImageUrl']),
      level: json['Level'] ?? 0,
      sortOrder: json['SortOrder'] ?? 0,
      productCount: json['ProductCount'] ?? 0,
      isActive: json['DeletionMark'] != true,
      lastSyncedAt: DateTime.now(),
    );
  }

  factory ProductCategory.fromSAP(Map<String, dynamic> json) {
    return ProductCategory(
      id: json['MaterialGroup'] ?? '',
      externalId1C: '',
      externalIdSAP: json['MaterialGroup'] ?? '',
      code: json['MaterialGroup'] ?? '',
      name: json['MaterialGroupName'] ?? '',
      level: 0,
      sortOrder: 0,
      productCount: 0,
      isActive: true,
      lastSyncedAt: DateTime.now(),
    );
  }

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('Ref_Key') || json.containsKey('Description')) {
      return ProductCategory.from1C(json);
    }
    if (json.containsKey('MaterialGroup')) return ProductCategory.fromSAP(json);
    return ProductCategory(
      id: (json['id'] ?? json['category_id'] ?? '').toString(),
      externalId1C: (json['external_id_1c'] ?? '').toString(),
      externalIdSAP: (json['external_id_sap'] ?? '').toString(),
      code: (json['code'] ?? '').toString(),
      name: (json['name'] ?? json['category_name'] ?? '').toString(),
      description: json['description']?.toString(),
      parentId: json['parent_id']?.toString(),
      parentName: json['parent_name']?.toString(),
      imageUrl: json['image_url']?.toString(),
      level: json['level'] ?? 0,
      sortOrder: json['sort_order'] ?? 0,
      productCount: json['product_count'] ?? 0,
      isActive: json['is_active'] ?? true,
      lastSyncedAt:
          DateTime.tryParse((json['last_synced_at'] ?? '').toString()) ??
              DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [id, code, name];
}

// ============ NARX JADVALI ============

/// Narx jadvali
class PriceList extends Equatable {
  final String id;
  final String name;
  final String description;
  final String priceGroupId;
  final String priceGroupName;
  final String currency;
  final DateTime effectiveFrom;
  final DateTime? effectiveTo;
  final bool isActive;
  final bool isDefault;
  final int itemCount;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String createdBy;

  const PriceList({
    required this.id,
    required this.name,
    required this.description,
    required this.priceGroupId,
    required this.priceGroupName,
    required this.currency,
    required this.effectiveFrom,
    this.effectiveTo,
    required this.isActive,
    required this.isDefault,
    required this.itemCount,
    required this.createdAt,
    this.updatedAt,
    required this.createdBy,
  });

  factory PriceList.fromJson(Map<String, dynamic> json) {
    return PriceList(
      id: (json['id'] ?? json['price_list_id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      priceGroupId: (json['price_group_id'] ?? '').toString(),
      priceGroupName: (json['price_group_name'] ?? '').toString(),
      currency: (json['currency'] ?? 'UZS').toString(),
      effectiveFrom:
          DateTime.tryParse((json['effective_from'] ?? '').toString()) ??
              DateTime.now(),
      effectiveTo: DateTime.tryParse((json['effective_to'] ?? '').toString()),
      isActive: json['is_active'] ?? true,
      isDefault: json['is_default'] ?? false,
      itemCount: json['item_count'] ?? 0,
      createdAt: DateTime.tryParse((json['created_at'] ?? '').toString()) ??
          DateTime.now(),
      updatedAt: DateTime.tryParse((json['updated_at'] ?? '').toString()),
      createdBy: (json['created_by'] ?? '').toString(),
    );
  }

  DateTime get validFrom => effectiveFrom;

  bool get isExpired =>
      effectiveTo != null && effectiveTo!.isBefore(DateTime.now());
  bool get isCurrentlyActive => isActive && !isExpired;

  @override
  List<Object?> get props => [id, priceGroupId, isActive];
}

/// Narx jadvali elementi
class PriceListItem extends Equatable {
  final String id;
  final String productId;
  final String productCode;
  final String productName;
  final double basePrice;
  final double? minPrice;
  final double? maxPrice;
  final double? discountPercent;
  final double finalPrice;
  final String currency;
  final String unitOfMeasure;
  final DateTime lastUpdated;

  const PriceListItem({
    required this.id,
    required this.productId,
    required this.productCode,
    required this.productName,
    required this.basePrice,
    this.minPrice,
    this.maxPrice,
    this.discountPercent,
    required this.finalPrice,
    required this.currency,
    required this.unitOfMeasure,
    required this.lastUpdated,
  });

  factory PriceListItem.fromJson(Map<String, dynamic> json) {
    final base = (json['base_price'] ?? json['basePrice'] ?? json['price'] ?? 0)
        .toDouble();
    final discount = json['discount_percent']?.toDouble();
    final finalPrice = (json['final_price'] ??
            json['finalPrice'] ??
            (discount == null ? base : base * (1 - discount / 100)))
        .toDouble();
    return PriceListItem(
      id: (json['id'] ?? '').toString(),
      productId: (json['product_id'] ?? json['productId'] ?? '').toString(),
      productCode:
          (json['product_code'] ?? json['productCode'] ?? '').toString(),
      productName:
          (json['product_name'] ?? json['productName'] ?? '').toString(),
      basePrice: base,
      minPrice: json['min_price']?.toDouble(),
      maxPrice: json['max_price']?.toDouble(),
      discountPercent: discount,
      finalPrice: finalPrice,
      currency: (json['currency'] ?? 'UZS').toString(),
      unitOfMeasure: (json['unit_of_measure'] ?? 'dona').toString(),
      lastUpdated: DateTime.tryParse((json['last_updated'] ?? '').toString()) ??
          DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [id, productId, finalPrice];
}

// ============ OMBOR ============

/// Ombor
class Warehouse extends Equatable {
  final String id;
  final String externalId1C;
  final String externalIdSAP;
  final String code;
  final String name;
  final String? address;
  final String? regionId;
  final String? regionName;
  final double? latitude;
  final double? longitude;
  final String? phone;
  final String? manager;
  final bool isActive;
  final bool isDefault;
  final DateTime lastSyncedAt;

  const Warehouse({
    required this.id,
    required this.externalId1C,
    required this.externalIdSAP,
    required this.code,
    required this.name,
    this.address,
    this.regionId,
    this.regionName,
    this.latitude,
    this.longitude,
    this.phone,
    this.manager,
    required this.isActive,
    required this.isDefault,
    required this.lastSyncedAt,
  });

  factory Warehouse.from1C(Map<String, dynamic> json) {
    return Warehouse(
      id: json['Ref_Key'] ?? '',
      externalId1C: json['Ref_Key'] ?? '',
      externalIdSAP: '',
      code: json['Code'] ?? '',
      name: json['Description'] ?? '',
      address: json['Address'],
      regionId: json['Region_Key'],
      regionName: json['Region_Description'],
      latitude: json['Latitude']?.toDouble(),
      longitude: json['Longitude']?.toDouble(),
      phone: json['Phone'],
      manager: json['Manager'],
      isActive: json['DeletionMark'] != true,
      isDefault: json['IsDefault'] ?? false,
      lastSyncedAt: DateTime.now(),
    );
  }

  factory Warehouse.fromSAP(Map<String, dynamic> json) {
    return Warehouse(
      id: json['Plant'] ?? '',
      externalId1C: '',
      externalIdSAP: json['Plant'] ?? '',
      code: json['Plant'] ?? '',
      name: json['PlantName'] ?? '',
      address: json['Address'],
      isActive: true,
      isDefault: false,
      lastSyncedAt: DateTime.now(),
    );
  }

  factory Warehouse.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('Ref_Key') || json.containsKey('Description')) {
      return Warehouse.from1C(json);
    }
    if (json.containsKey('Plant')) return Warehouse.fromSAP(json);
    return Warehouse(
      id: (json['id'] ?? json['warehouse_id'] ?? '').toString(),
      externalId1C: (json['external_id_1c'] ?? '').toString(),
      externalIdSAP: (json['external_id_sap'] ?? '').toString(),
      code: (json['code'] ?? '').toString(),
      name: (json['name'] ?? json['warehouse_name'] ?? '').toString(),
      address: json['address']?.toString(),
      regionId: json['region_id']?.toString(),
      regionName: json['region_name']?.toString(),
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      phone: json['phone']?.toString(),
      manager: json['manager']?.toString(),
      isActive: json['is_active'] ?? true,
      isDefault: json['is_default'] ?? false,
      lastSyncedAt:
          DateTime.tryParse((json['last_synced_at'] ?? '').toString()) ??
              DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [id, code, name];
}

// ============ OMBOR QOLDIG'I ============

/// Ombor qoldig'i
class StockItem extends Equatable {
  final String productId;
  final String productCode;
  final String productName;
  final String warehouseId;
  final String warehouseName;
  final double quantity;
  final double reserved;
  final double available;
  final double incoming; // Kutilayotgan
  final double outgoing; // Chiqariladigan
  final String unitOfMeasure;
  final double? avgCost; // O'rtacha narx
  final double? totalValue; // Umumiy qiymat
  final DateTime lastUpdated;

  const StockItem({
    required this.productId,
    required this.productCode,
    required this.productName,
    required this.warehouseId,
    required this.warehouseName,
    required this.quantity,
    required this.reserved,
    required this.available,
    required this.incoming,
    required this.outgoing,
    required this.unitOfMeasure,
    this.avgCost,
    this.totalValue,
    required this.lastUpdated,
  });

  factory StockItem.fromJson(Map<String, dynamic> json) {
    final quantity = (json['quantity'] ??
            json['stock_quantity'] ??
            json['StockQuantity'] ??
            0)
        .toDouble();
    final reserved =
        (json['reserved'] ?? json['reserved_quantity'] ?? 0).toDouble();
    final available = (json['available'] ??
            json['available_quantity'] ??
            json['AvailableQuantity'] ??
            (quantity - reserved))
        .toDouble();
    return StockItem(
      productId:
          (json['product_id'] ?? json['productId'] ?? json['Material'] ?? '')
              .toString(),
      productCode:
          (json['product_code'] ?? json['productCode'] ?? '').toString(),
      productName: (json['product_name'] ??
              json['productName'] ??
              json['MaterialDescription'] ??
              '')
          .toString(),
      warehouseId:
          (json['warehouse_id'] ?? json['warehouseId'] ?? json['Plant'] ?? '')
              .toString(),
      warehouseName: (json['warehouse_name'] ??
              json['warehouseName'] ??
              json['PlantName'] ??
              '')
          .toString(),
      quantity: quantity,
      reserved: reserved,
      available: available,
      incoming: (json['incoming'] ?? 0).toDouble(),
      outgoing: (json['outgoing'] ?? 0).toDouble(),
      unitOfMeasure:
          (json['unit_of_measure'] ?? json['unitOfMeasure'] ?? 'dona')
              .toString(),
      avgCost: json['avg_cost']?.toDouble(),
      totalValue: json['total_value']?.toDouble(),
      lastUpdated: DateTime.tryParse((json['last_updated'] ?? '').toString()) ??
          DateTime.now(),
    );
  }

  String get batchNumber => '';

  bool get isLowStock => available < 10;
  bool get isOutOfStock => available <= 0;

  @override
  List<Object?> get props => [productId, warehouseId, available];
}

// ============ SINXRONLASH NATIJASI ============

/// Mahsulot sinxronlash natijasi
class ProductSyncResult extends Equatable {
  final String source; // 1c, sap
  final int totalProducts;
  final int newProducts;
  final int updatedProducts;
  final int unchangedProducts;
  final int failedProducts;
  final int totalCategories;
  final int newCategories;
  final List<String> errors;
  final DateTime startedAt;
  final DateTime completedAt;
  final Duration duration;

  const ProductSyncResult({
    required this.source,
    required this.totalProducts,
    required this.newProducts,
    required this.updatedProducts,
    required this.unchangedProducts,
    required this.failedProducts,
    required this.totalCategories,
    required this.newCategories,
    required this.errors,
    required this.startedAt,
    required this.completedAt,
    required this.duration,
  });

  bool get isSuccess => failedProducts == 0;
  bool get hasErrors => errors.isNotEmpty;

  @override
  List<Object?> get props => [source, totalProducts, newProducts];
}
