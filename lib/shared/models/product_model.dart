import 'package:equatable/equatable.dart';

/// Mahsulot model - JSON serialization bilan
class ProductModel extends Equatable {
  final String id;
  final String code;
  final String name;
  final String sku;
  final String? barcode;
  final String categoryId;
  final String categoryName;
  final String? description;
  final String? imageUrl;
  final String unitOfMeasure;
  final double weight;
  final double volume;
  final double basePrice;
  final double? discountPrice;
  final double? discountPercent;
  final String currency;
  final double stockQuantity;
  final double availableQuantity;
  final double reservedQuantity;
  final double minOrderQuantity;
  final String? brand;
  final String? manufacturer;
  final String? countryOfOrigin;
  final bool isActive;
  final bool isAvailable;
  final bool isNew;
  final bool isPopular;
  final bool hasDiscount;
  final Map<String, dynamic>? attributes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ProductModel({
    required this.id,
    required this.code,
    required this.name,
    required this.sku,
    this.barcode,
    required this.categoryId,
    required this.categoryName,
    this.description,
    this.imageUrl,
    required this.unitOfMeasure,
    required this.weight,
    required this.volume,
    required this.basePrice,
    this.discountPrice,
    this.discountPercent,
    required this.currency,
    required this.stockQuantity,
    required this.availableQuantity,
    required this.reservedQuantity,
    required this.minOrderQuantity,
    this.brand,
    this.manufacturer,
    this.countryOfOrigin,
    required this.isActive,
    required this.isAvailable,
    required this.isNew,
    required this.isPopular,
    required this.hasDiscount,
    this.attributes,
    required this.createdAt,
    this.updatedAt,
  });

  double get effectivePrice =>
      hasDiscount && discountPrice != null ? discountPrice! : basePrice;
  bool get isInStock => availableQuantity > 0;
  bool get isLowStock => availableQuantity < 10;

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? '',
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      sku: json['sku'] ?? '',
      barcode: json['barcode'],
      categoryId: json['category_id'] ?? '',
      categoryName: json['category_name'] ?? '',
      description: json['description'],
      imageUrl: json['image_url'],
      unitOfMeasure: json['unit_of_measure'] ?? 'dona',
      weight: (json['weight'] ?? 0).toDouble(),
      volume: (json['volume'] ?? 0).toDouble(),
      basePrice: (json['base_price'] ?? 0).toDouble(),
      discountPrice: json['discount_price']?.toDouble(),
      discountPercent: json['discount_percent']?.toDouble(),
      currency: json['currency'] ?? 'UZS',
      stockQuantity: (json['stock_quantity'] ?? 0).toDouble(),
      availableQuantity: (json['available_quantity'] ?? 0).toDouble(),
      reservedQuantity: (json['reserved_quantity'] ?? 0).toDouble(),
      minOrderQuantity: (json['min_order_quantity'] ?? 1).toDouble(),
      brand: json['brand'],
      manufacturer: json['manufacturer'],
      countryOfOrigin: json['country_of_origin'],
      isActive: json['is_active'] ?? true,
      isAvailable: json['is_available'] ?? true,
      isNew: json['is_new'] ?? false,
      isPopular: json['is_popular'] ?? false,
      hasDiscount: json['has_discount'] ?? false,
      attributes: json['attributes'],
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'sku': sku,
      'barcode': barcode,
      'category_id': categoryId,
      'category_name': categoryName,
      'description': description,
      'image_url': imageUrl,
      'unit_of_measure': unitOfMeasure,
      'weight': weight,
      'volume': volume,
      'base_price': basePrice,
      'discount_price': discountPrice,
      'discount_percent': discountPercent,
      'currency': currency,
      'stock_quantity': stockQuantity,
      'available_quantity': availableQuantity,
      'reserved_quantity': reservedQuantity,
      'min_order_quantity': minOrderQuantity,
      'brand': brand,
      'manufacturer': manufacturer,
      'country_of_origin': countryOfOrigin,
      'is_active': isActive,
      'is_available': isAvailable,
      'is_new': isNew,
      'is_popular': isPopular,
      'has_discount': hasDiscount,
      'attributes': attributes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, code, name, isActive, isAvailable];
}
