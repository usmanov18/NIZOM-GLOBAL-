// ============================================================
// 1C:ENTERPRISE - MAHSULOT (NOMENKLATURA) MODELS
// Haqiqiy 1C konfiguratsiyaga mos
// ============================================================

/// 1C Nomenklatura (Mahsulot) - to'liq tuzilma
///
/// 1C da mahsulotlar "Справочник.Номенклатура" da saqlanadi
/// Har bir mahsulot quyidagi ma'lumotlarga ega:
class OneCProduct {
  final String refKey; // УникальныйИдентификатор (GUID)
  final String code; // Код (автоматик)
  final String description; // Наименование (asosiy nom)
  final String fullDescription; // Полное наименование
  final String article; // Артикул
  final String barcode; // Штрихкод (EAN-13, EAN-8)

  // ============ ТАСНИФЛОВ (CLASSIFICATION) ============
  final String
      productTypeKey; // ВидНоменклатуры (Товар, Услуга, Многооборотная тара)
  final String productTypeName; // ВидНоменклатуры наименование
  final String categoryKey; // Родитель (категория)
  final String categoryName; // Родитель наименование
  final String groupKey; // НоменклатурнаяГруппа (savdo guruhi)
  final String groupName; // НоменклатурнаяГруппа наименование

  // ============ БИРЛИКЛАР (ЕДИНИЦЫ) ============
  final String baseUnitKey; // ЕдиницаХраненияОстатков (asosiy birlik)
  final String
      baseUnitName; // ЕдиницаХраненияОстатков наименование (штука, кг, литр)
  final String baseUnitCode; // ЕдиницаХраненияОстатков код (OKEI)
  final double baseUnitFactor; // Коэффициент (1)

  final String? salesUnitKey; // ЕдиницаДляОтчетов (sotuv birligi)
  final String? salesUnitName; // ЕдиницаДляОтчетов наименование
  final double? salesUnitFactor; // Коэффициент (masalan, 1 quti = 12 dona)

  final String? weightUnitKey; // ЕдиницаИзмеренияВеса
  final double? weightUnitFactor; // ВесЕдиницы

  // ============ ОЛЧАМЛАР (ХАРАКТЕРИСТИКИ) ============
  final double? weight; // ВесБрутто (кг)
  final double? netWeight; // ВесНетто (кг)
  final double? volume; // Объем (м³)
  final double? length; // Длина (м)
  final double? width; // Ширина (м)
  final double? height; // Высота (м)

  // ============ НАРХЛАР (ЦЕНЫ) ============
  final String? priceGroupKey; // ЦеноваяГруппа
  final String? priceGroupName; // ЦеноваяГруппа наименование
  final double? basePrice; // ОсновнаяЦена
  final double? minPrice; // МинимальнаяЦена
  final double? recommendedPrice; // РекомендуемаяЦена
  final String currency; // ВалютаЦены (UZS, USD)

  // ============ СКИДКИ (СКИДКИНАДБАВКИ) ============
  final bool hasAutomaticDiscount; // АвтоматическаяСкидка
  final double? discountPercent; // ПроцентСкидки
  final String? discountConditionKey; // УсловиеСкидки
  final String? promotionKey; // Акция

  // ============ ОМБОР (СКЛАД) ============
  final double stockQuantity; // ОстатокНаСкладе
  final double reservedQuantity; // ВРезерве
  final double orderedQuantity; // ВЗаказах
  final double availableQuantity; // Доступно
  final String? warehouseKey; // ОсновнойСклад
  final double? reorderPoint; // ТочкаЗаказа
  final double? maxStock; // МаксимальныйОстаток

  // ============ ПРОИЗВОДИТЕЛЬ (ИШЛАБ ЧИКАРУВЧИ) ============
  final String? brandKey; // Марка (бренд)
  final String? brandName; // Марка наименование
  final String? manufacturerKey; // Производитель
  final String? manufacturerName; // Производитель наименование
  final String? countryOfOriginKey; // СтранаПроисхождения
  final String? countryOfOriginName; // СтранаПроисхождения наименование

  // ============ РАСМ (ИЗОБРАЖЕНИЕ) ============
  final String? imageUrl; // ФайлНоменклатуры (URL)
  final String? imageRefKey; // ФайлНоменклатуры ключ
  final List<String> additionalImages; // ДополнительныеФайлы

  // ============ ХУСУСИЯТЛАР (ДОПОЛНИТЕЛЬНЫЕ РЕКВИЗИТЫ) ============
  final String? color; // Цвет
  final String? size; // Размер
  final String? material; // Материал
  final String? season; // Сезон
  final String? gender; // Пол
  final Map<String, dynamic>? customAttributes; // Произвольные реквизиты

  // ============ ХОЛАТ (СОСТОЯНИЕ) ============
  final bool isActive; // Активный (не помечен на удаление)
  final bool isMarkedForDeletion; // ПометкаУдаления
  final bool isNew; // Новинка
  final bool isPopular; // Популярный
  final bool isFeatured; // Рекомендуемый

  // ============ ВАКТ (ДАТЫ) ============
  final DateTime createdAt; // ДатаСоздания
  final DateTime? updatedAt; // ДатаИзменения
  final DateTime? lastSaleDate; // ДатаПоследнейПродажи
  final DateTime? lastReceiptDate; // ДатаПоследнегоПоступления

  // ============ САНА (СВЕДЕНИЯ) ============
  final String? descriptionFull; // Описание (detailed description)
  final String? specifications; // Характеристики (specs)
  final String? notes; // Комментарий

  const OneCProduct({
    required this.refKey,
    required this.code,
    required this.description,
    required this.fullDescription,
    required this.article,
    required this.barcode,
    required this.productTypeKey,
    required this.productTypeName,
    required this.categoryKey,
    required this.categoryName,
    required this.groupKey,
    required this.groupName,
    required this.baseUnitKey,
    required this.baseUnitName,
    required this.baseUnitCode,
    required this.baseUnitFactor,
    this.salesUnitKey,
    this.salesUnitName,
    this.salesUnitFactor,
    this.weightUnitKey,
    this.weightUnitFactor,
    this.weight,
    this.netWeight,
    this.volume,
    this.length,
    this.width,
    this.height,
    this.priceGroupKey,
    this.priceGroupName,
    this.basePrice,
    this.minPrice,
    this.recommendedPrice,
    required this.currency,
    required this.hasAutomaticDiscount,
    this.discountPercent,
    this.discountConditionKey,
    this.promotionKey,
    required this.stockQuantity,
    required this.reservedQuantity,
    required this.orderedQuantity,
    required this.availableQuantity,
    this.warehouseKey,
    this.reorderPoint,
    this.maxStock,
    this.brandKey,
    this.brandName,
    this.manufacturerKey,
    this.manufacturerName,
    this.countryOfOriginKey,
    this.countryOfOriginName,
    this.imageUrl,
    this.imageRefKey,
    this.additionalImages = const [],
    this.color,
    this.size,
    this.material,
    this.season,
    this.gender,
    this.customAttributes,
    required this.isActive,
    required this.isMarkedForDeletion,
    required this.isNew,
    required this.isPopular,
    required this.isFeatured,
    required this.createdAt,
    this.updatedAt,
    this.lastSaleDate,
    this.lastReceiptDate,
    this.descriptionFull,
    this.specifications,
    this.notes,
  });

  /// 1C JSON dan yaratish
  factory OneCProduct.fromJson(Map<String, dynamic> json) {
    return OneCProduct(
      refKey: json['Ref_Key'] ?? '',
      code: json['Code'] ?? '',
      description: json['Description'] ?? '',
      fullDescription:
          json['НаименованиеПолное'] ?? json['DescriptionFull'] ?? '',
      article: json['Артикул'] ?? json['Article'] ?? '',
      barcode: json['Штрихкод'] ?? json['Barcode'] ?? '',

      // Classification
      productTypeKey:
          json['ВидНоменклатуры_Key'] ?? json['ProductType_Key'] ?? '',
      productTypeName: json['ВидНоменклатуры_Description'] ??
          json['ProductType_Description'] ??
          '',
      categoryKey: json['Родитель_Key'] ?? json['Parent_Key'] ?? '',
      categoryName:
          json['Родитель_Description'] ?? json['Parent_Description'] ?? '',
      groupKey:
          json['НоменклатурнаяГруппа_Key'] ?? json['ProductGroup_Key'] ?? '',
      groupName: json['НоменклатурнаяГруппа_Description'] ??
          json['ProductGroup_Description'] ??
          '',

      // Units
      baseUnitKey:
          json['ЕдиницаХраненияОстатков_Key'] ?? json['BaseUnit_Key'] ?? '',
      baseUnitName: json['ЕдиницаХраненияОстатков_Description'] ??
          json['BaseUnit_Description'] ??
          'шт',
      baseUnitCode: json['ЕдиницаХраненияОстатков_КодОКЕИ'] ??
          json['BaseUnit_Code'] ??
          '',
      baseUnitFactor: (json['ЕдиницаХраненияОстатков_Коэффициент'] ??
              json['BaseUnit_Factor'] ??
              1)
          .toDouble(),
      salesUnitKey: json['ЕдиницаДляОтчетов_Key'] ?? json['SalesUnit_Key'],
      salesUnitName: json['ЕдиницаДляОтчетов_Description'] ??
          json['SalesUnit_Description'],
      salesUnitFactor: json['ЕдиницаДляОтчетов_Коэффициент']?.toDouble(),

      // Dimensions
      weight: json['ВесБрутто']?.toDouble() ?? json['Weight']?.toDouble(),
      netWeight: json['ВесНетто']?.toDouble() ?? json['NetWeight']?.toDouble(),
      volume: json['Объем']?.toDouble() ?? json['Volume']?.toDouble(),
      length: json['Длина']?.toDouble(),
      width: json['Ширина']?.toDouble(),
      height: json['Высота']?.toDouble(),

      // Prices
      priceGroupKey: json['ЦеноваяГруппа_Key'] ?? json['PriceGroup_Key'],
      priceGroupName:
          json['ЦеноваяГруппа_Description'] ?? json['PriceGroup_Description'],
      basePrice:
          json['ОсновнаяЦена']?.toDouble() ?? json['BasePrice']?.toDouble(),
      minPrice:
          json['МинимальнаяЦена']?.toDouble() ?? json['MinPrice']?.toDouble(),
      recommendedPrice: json['РекомендуемаяЦена']?.toDouble(),
      currency: json['ВалютаЦены'] ?? json['Currency'] ?? 'UZS',

      // Discounts
      hasAutomaticDiscount:
          json['АвтоматическаяСкидка'] ?? json['HasDiscount'] ?? false,
      discountPercent: json['ПроцентСкидки']?.toDouble() ??
          json['DiscountPercent']?.toDouble(),
      discountConditionKey: json['УсловиеСкидки_Key'],
      promotionKey: json['Акция_Key'] ?? json['Promotion_Key'],

      // Stock
      stockQuantity:
          (json['ОстатокНаСкладе'] ?? json['StockQuantity'] ?? 0).toDouble(),
      reservedQuantity:
          (json['ВРезерве'] ?? json['ReservedQuantity'] ?? 0).toDouble(),
      orderedQuantity:
          (json['ВЗаказах'] ?? json['OrderedQuantity'] ?? 0).toDouble(),
      availableQuantity:
          (json['Доступно'] ?? json['AvailableQuantity'] ?? 0).toDouble(),
      warehouseKey: json['ОсновнойСклад_Key'] ?? json['Warehouse_Key'],
      reorderPoint: json['ТочкаЗаказа']?.toDouble(),
      maxStock: json['МаксимальныйОстаток']?.toDouble(),

      // Manufacturer
      brandKey: json['Марка_Key'] ?? json['Brand_Key'],
      brandName: json['Марка_Description'] ?? json['Brand_Description'],
      manufacturerKey: json['Производитель_Key'] ?? json['Manufacturer_Key'],
      manufacturerName:
          json['Производитель_Description'] ?? json['Manufacturer_Description'],
      countryOfOriginKey: json['СтранаПроисхождения_Key'],
      countryOfOriginName:
          json['СтранаПроисхождения_Description'] ?? json['CountryOfOrigin'],

      // Image
      imageUrl: json['ФайлНоменклатуры_URL'] ?? json['ImageUrl'],
      imageRefKey: json['ФайлНоменклатуры_Key'],

      // Custom attributes
      color: json['Цвет'] ?? json['Color'],
      size: json['Размер'] ?? json['Size'],
      material: json['Материал'],
      season: json['Сезон'],
      gender: json['Пол'],

      // Status
      isActive: !(json['ПометкаУдаления'] ?? json['DeletionMark'] ?? false),
      isMarkedForDeletion:
          json['ПометкаУдаления'] ?? json['DeletionMark'] ?? false,
      isNew: json['Новинка'] ?? json['IsNew'] ?? false,
      isPopular: json['Популярный'] ?? json['IsPopular'] ?? false,
      isFeatured: json['Рекомендуемый'] ?? json['IsFeatured'] ?? false,

      // Dates
      createdAt: json['ДатаСоздания'] != null
          ? DateTime.parse(json['ДатаСоздания'])
          : DateTime.now(),
      updatedAt: json['ДатаИзменения'] != null
          ? DateTime.parse(json['ДатаИзменения'])
          : null,
      lastSaleDate: json['ДатаПоследнейПродажи'] != null
          ? DateTime.parse(json['ДатаПоследнейПродажи'])
          : null,
      lastReceiptDate: json['ДатаПоследнегоПоступления'] != null
          ? DateTime.parse(json['ДатаПоследнегоПоступления'])
          : null,

      // Description
      descriptionFull: json['Описание'] ?? json['Description'],
      specifications: json['Характеристики'] ?? json['Specifications'],
      notes: json['Комментарий'] ?? json['Notes'],
    );
  }
}

/// 1C Narx ma'lumotlari
class OneCPrice {
  final String refKey;
  final String productKey;
  final String productCode;
  final String productName;
  final String priceGroupKey;
  final String priceGroupName;
  final double price;
  final double? minPrice;
  final double? discountPercent;
  final double? discountAmount;
  final double finalPrice;
  final String currency;
  final DateTime period; // Narx sanasi
  final String? conditionType; // ТипЦены
  final String? conditionKey; // ВидЦены_Key

  const OneCPrice({
    required this.refKey,
    required this.productKey,
    required this.productCode,
    required this.productName,
    required this.priceGroupKey,
    required this.priceGroupName,
    required this.price,
    this.minPrice,
    this.discountPercent,
    this.discountAmount,
    required this.finalPrice,
    required this.currency,
    required this.period,
    this.conditionType,
    this.conditionKey,
  });

  factory OneCPrice.fromJson(Map<String, dynamic> json) {
    return OneCPrice(
      refKey: json['Ref_Key'] ?? '',
      productKey: json['Номенклатура_Key'] ?? json['Product_Key'] ?? '',
      productCode: json['Номенклатура_Code'] ?? json['Product_Code'] ?? '',
      productName:
          json['Номенклатура_Description'] ?? json['Product_Description'] ?? '',
      priceGroupKey: json['ВидЦены_Key'] ?? json['PriceGroup_Key'] ?? '',
      priceGroupName:
          json['ВидЦены_Description'] ?? json['PriceGroup_Description'] ?? '',
      price: (json['Цена'] ?? json['Price'] ?? 0).toDouble(),
      minPrice: json['МинимальнаяЦена']?.toDouble(),
      discountPercent: json['ПроцентСкидки']?.toDouble(),
      discountAmount: json['СуммаСкидки']?.toDouble(),
      finalPrice:
          (json['ЦенаСоСкидкой'] ?? json['FinalPrice'] ?? json['Цена'] ?? 0)
              .toDouble(),
      currency: json['Валюта'] ?? json['Currency'] ?? 'UZS',
      period: json['Период'] != null
          ? DateTime.parse(json['Период'])
          : DateTime.now(),
      conditionType: json['ТипЦены'],
      conditionKey: json['ВидЦены_Key'],
    );
  }
}

/// 1C Ombor qoldig'i
class OneCStock {
  final String productKey;
  final String productCode;
  final String productName;
  final String warehouseKey;
  final String warehouseName;
  final double quantity; // Остаток
  final double reserved; // ВРезерве
  double get available => quantity - reserved;
  final String unitOfMeasure;
  final DateTime period;

  const OneCStock({
    required this.productKey,
    required this.productCode,
    required this.productName,
    required this.warehouseKey,
    required this.warehouseName,
    required this.quantity,
    required this.reserved,
    required this.unitOfMeasure,
    required this.period,
  });

  factory OneCStock.fromJson(Map<String, dynamic> json) {
    return OneCStock(
      productKey: json['Номенклатура_Key'] ?? json['Product_Key'] ?? '',
      productCode: json['Номенклатура_Code'] ?? json['Product_Code'] ?? '',
      productName:
          json['Номенклатура_Description'] ?? json['Product_Description'] ?? '',
      warehouseKey: json['Склад_Key'] ?? json['Warehouse_Key'] ?? '',
      warehouseName:
          json['Склад_Description'] ?? json['Warehouse_Description'] ?? '',
      quantity: (json['КоличествоОстаток'] ?? json['Quantity'] ?? 0).toDouble(),
      reserved:
          (json['КоличествоВРезерве'] ?? json['Reserved'] ?? 0).toDouble(),
      unitOfMeasure: json['ЕдиницаИзмерения'] ?? json['UnitOfMeasure'] ?? 'шт',
      period: json['Период'] != null
          ? DateTime.parse(json['Период'])
          : DateTime.now(),
    );
  }
}

/// 1C Kategoriya
class OneCCategory {
  final String refKey;
  final String code;
  final String description;
  final String? parentKey;
  final String? parentDescription;
  final int level;
  final bool isFolder; // ЭтоГруппа
  final bool isMarkedForDeletion;
  final int productCount;

  const OneCCategory({
    required this.refKey,
    required this.code,
    required this.description,
    this.parentKey,
    this.parentDescription,
    required this.level,
    required this.isFolder,
    required this.isMarkedForDeletion,
    required this.productCount,
  });

  factory OneCCategory.fromJson(Map<String, dynamic> json) {
    return OneCCategory(
      refKey: json['Ref_Key'] ?? '',
      code: json['Code'] ?? '',
      description: json['Description'] ?? '',
      parentKey: json['Родитель_Key'] ?? json['Parent_Key'],
      parentDescription:
          json['Родитель_Description'] ?? json['Parent_Description'],
      level: json['Уровень'] ?? json['Level'] ?? 0,
      isFolder: json['ЭтоГруппа'] ?? json['IsFolder'] ?? false,
      isMarkedForDeletion:
          json['ПометкаУдаления'] ?? json['DeletionMark'] ?? false,
      productCount: json['КоличествоНоменклатуры'] ?? json['ProductCount'] ?? 0,
    );
  }
}
