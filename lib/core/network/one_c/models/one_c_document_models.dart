// ============================================================
// 1C:ENTERPRISE - HUJJAT TUZILMASI
// To'lov turiga qarab hujjat yaratish
// ============================================================

/// 1C Hujjat turlari
enum OneCDocumentType {
  order, // ЗаказКлиента (Bank/Kredit uchun)
  sale, // РеализацияТоваровУслуг (Naqd/Plastik uchun)
  returnSale, // ВозвратТоваровОтПокупателя (Qaytarish)
  payment, // ПоступлениеНаРасчетныйСчет (Bank to'lov)
  cashReceipt, // ПриходныйКассовыйОрдер (Naqd to'lov)
}

/// 1C To'lov usuli
enum OneCPaymentType {
  cash, // Naqd pul → РеализацияТоваров ga tushadi
  card, // Plastik karta → РеализацияТоваров ga tushadi
  transfer, // Bank o'tkazmasi → ЗаказКлиента ga tushadi
  credit, // Kredit/Muddatli → ЗаказКлиента ga tushadi
}

/// 1C Buyurtma yaratish natijasi
class OneCOrderCreationResult {
  final OneCDocumentType documentType; // Qanday hujjat yaratildi
  final String documentRefKey; // Hujjat Ref_Key
  final String documentNumber; // Hujjat raqami
  final String documentDate; // Hujjat sanasi
  final String status; // Holat
  final double amount; // Summa
  final String? relatedDocumentRefKey; // Bog'liq hujjat (Realizatsiya → Zakaz)
  final String? relatedDocumentNumber; // Bog'liq hujjat raqami
  final bool posted; // Проведен (o'tkazildi)
  final String? errorMessage; // Xatolik

  const OneCOrderCreationResult({
    required this.documentType,
    required this.documentRefKey,
    required this.documentNumber,
    required this.documentDate,
    required this.status,
    required this.amount,
    this.relatedDocumentRefKey,
    this.relatedDocumentNumber,
    required this.posted,
    this.errorMessage,
  });

  factory OneCOrderCreationResult.fromJson(Map<String, dynamic> json) {
    return OneCOrderCreationResult(
      documentType: _parseDocumentType(json['DocumentType']),
      documentRefKey: json['Ref_Key'] ?? '',
      documentNumber: json['Number'] ?? '',
      documentDate: json['Date'] ?? '',
      status: json['Status'] ?? '',
      amount: (json['DocumentAmount'] ?? 0).toDouble(),
      relatedDocumentRefKey: json['RelatedDocument_Key'],
      relatedDocumentNumber: json['RelatedDocument_Number'],
      posted: json['Posted'] ?? false,
      errorMessage: json['ErrorMessage'],
    );
  }

  static OneCDocumentType _parseDocumentType(String? type) {
    switch (type) {
      case 'ЗаказКлиента':
        return OneCDocumentType.order;
      case 'РеализацияТоваровУслуг':
        return OneCDocumentType.sale;
      case 'ВозвратТоваровОтПокупателя':
        return OneCDocumentType.returnSale;
      case 'ПоступлениеНаРасчетныйСчет':
        return OneCDocumentType.payment;
      case 'ПриходныйКассовыйОрдер':
        return OneCDocumentType.cashReceipt;
      default:
        return OneCDocumentType.sale;
    }
  }

  bool get isSuccess => documentRefKey.isNotEmpty && posted;
  bool get isOrder => documentType == OneCDocumentType.order;
  bool get isSale => documentType == OneCDocumentType.sale;
}

// ============================================================
// 1C ЗАКАЗКЛИЕНТА (BUYURTMA) - Bank/Kredit uchun
// ============================================================

/// 1C ЗаказКлиента - Bank yoki Kredit to'lov uchun
///
/// Buyurtma yaratiladi, keyin РеализацияТоваров ga aylantiriladi
class OneCClientOrder {
  final String date; // Дата
  final String number; // Номер
  final String status; // Статус (Новый, ВРаботе, Выполнен, Отменен)

  // Контрагент
  final String counterpartyKey; // Контрагент_Key
  final String counterpartyCode; // Контрагент_Code
  final String counterpartyName; // Контрагент_Description

  // Организация
  final String organizationKey; // Организация_Key

  // Склад
  final String warehouseKey; // Склад_Key
  final String warehouseCode; // Склад_Code

  // Ответственный
  final String agentKey; // Ответственный_Key
  final String agentCode; // Ответственный_Code

  // Табличная часть
  final List<OneCOrderLineItem> items;

  // Суммы
  final double documentAmount; // СуммаДокумента
  final double discountAmount; // СуммаСкидки
  final double taxAmount; // СуммаНДС
  final String currency; // Валюта

  // Оплата
  final String paymentMethod; // СпособОплаты (bank, credit)
  final String paymentTerms; // УсловияОплаты
  final int paymentDays; // Отсрочка (kun)
  final DateTime? paymentDueDate; // ДатаПлатежа

  // Доставка
  final DateTime? deliveryDate; // ДатаДоставки
  final String? deliveryTimeSlot; // ВремяДоставки
  final String? deliveryAddress; // АдресДоставки

  // Прочее
  final String comment; // Комментарий
  final bool posted; // Проведен
  final bool deletionMark; // ПометкаУдаления

  // Связанные документы
  final String? saleDocumentKey; // Реализация_Key (agar yaratilgan bo'lsa)
  final String? saleDocumentNumber; // Реализация_Nomer
  final String? invoiceKey; // СчетНаОплату_Key
  final String? paymentKey; // ПоступлениеОплаты_Key

  const OneCClientOrder({
    required this.date,
    required this.number,
    required this.status,
    required this.counterpartyKey,
    required this.counterpartyCode,
    required this.counterpartyName,
    required this.organizationKey,
    required this.warehouseKey,
    required this.warehouseCode,
    required this.agentKey,
    required this.agentCode,
    required this.items,
    required this.documentAmount,
    required this.discountAmount,
    required this.taxAmount,
    required this.currency,
    required this.paymentMethod,
    required this.paymentTerms,
    required this.paymentDays,
    this.paymentDueDate,
    this.deliveryDate,
    this.deliveryTimeSlot,
    this.deliveryAddress,
    required this.comment,
    required this.posted,
    required this.deletionMark,
    this.saleDocumentKey,
    this.saleDocumentNumber,
    this.invoiceKey,
    this.paymentKey,
  });

  factory OneCClientOrder.fromJson(Map<String, dynamic> json) {
    return OneCClientOrder(
      date: json['Date'] ?? '',
      number: json['Number'] ?? '',
      status: json['Status'] ?? '',
      counterpartyKey: json['Контрагент_Key'] ?? '',
      counterpartyCode: json['Контрагент_Code'] ?? '',
      counterpartyName: json['Контрагент_Description'] ?? '',
      organizationKey: json['Организация_Key'] ?? '',
      warehouseKey: json['Склад_Key'] ?? '',
      warehouseCode: json['Склад_Code'] ?? '',
      agentKey: json['Ответственный_Key'] ?? '',
      agentCode: json['Ответственный_Code'] ?? '',
      items: (json['ТабличнаяЧасть'] as List?)
              ?.map((i) => OneCOrderLineItem.fromJson(i))
              .toList() ??
          [],
      documentAmount: (json['СуммаДокумента'] ?? 0).toDouble(),
      discountAmount: (json['СуммаСкидки'] ?? 0).toDouble(),
      taxAmount: (json['СуммаНДС'] ?? 0).toDouble(),
      currency: json['Валюта'] ?? 'UZS',
      paymentMethod: json['СпособОплаты'] ?? '',
      paymentTerms: json['УсловияОплаты'] ?? '',
      paymentDays: json['Отсрочка'] ?? 0,
      paymentDueDate: json['ДатаПлатежа'] != null
          ? DateTime.parse(json['ДатаПлатежа'])
          : null,
      deliveryDate: json['ДатаДоставки'] != null
          ? DateTime.parse(json['ДатаДоставки'])
          : null,
      deliveryTimeSlot: json['ВремяДоставки'],
      deliveryAddress: json['АдресДоставки'],
      comment: json['Комментарий'] ?? '',
      posted: json['Posted'] ?? false,
      deletionMark: json['DeletionMark'] ?? false,
      saleDocumentKey: json['Реализация_Key'],
      saleDocumentNumber: json['Реализация_Number'],
      invoiceKey: json['СчетНаОплату_Key'],
      paymentKey: json['ПоступлениеОплаты_Key'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Date': date,
      'Number': number,
      'Status': status,
      'Контрагент_Key': counterpartyKey,
      'Контрагент_Code': counterpartyCode,
      'Контрагент_Description': counterpartyName,
      'Организация_Key': organizationKey,
      'Склад_Key': warehouseKey,
      'Склад_Code': warehouseCode,
      'Ответственный_Key': agentKey,
      'Ответственный_Code': agentCode,
      'ТабличнаяЧасть': items.map((i) => i.toJson()).toList(),
      'СуммаДокумента': documentAmount,
      'СуммаСкидки': discountAmount,
      'СуммаНДС': taxAmount,
      'Валюта': currency,
      'СпособОплаты': paymentMethod,
      'УсловияОплаты': paymentTerms,
      'Отсрочка': paymentDays,
      if (paymentDueDate != null)
        'ДатаПлатежа': paymentDueDate!.toIso8601String(),
      if (deliveryDate != null) 'ДатаДоставки': deliveryDate!.toIso8601String(),
      if (deliveryTimeSlot != null) 'ВремяДоставки': deliveryTimeSlot,
      if (deliveryAddress != null) 'АдресДоставки': deliveryAddress,
      'Комментарий': comment,
    };
  }

  bool get isConfirmed => status == 'Выполнен' || status == 'ВРаботе';
  bool get hasSaleDocument =>
      saleDocumentKey != null && saleDocumentKey!.isNotEmpty;
  bool get isPaid => paymentKey != null && paymentKey!.isNotEmpty;
}

// ============================================================
// 1C РЕАЛИЗАЦИЯТОВАРОВУСЛУГ (SOTUV HUJJATI) - Naqd/Plastik uchun
// ============================================================

/// 1C РеализацияТоваровУслуг - Naqd yoki Plastik to'lov uchun
///
/// To'g'ridan-to'g'ri sotuv hujjati yaratiladi
class OneCSaleDocument {
  final String date; // Дата
  final String number; // Номер
  final String status; // Статус
  final String operationType; // ВидОперации (Реализация, Возврат)

  // Контрагент
  final String counterpartyKey;
  final String counterpartyCode;
  final String counterpartyName;

  // Организация
  final String organizationKey;

  // Склад
  final String warehouseKey;
  final String warehouseCode;

  // Ответственный
  final String agentKey;
  final String agentCode;

  // Договор
  final String contractKey; // Договор_Key
  final String contractNumber; // Договор_Nomer

  // Табличная часть
  final List<OneCSaleLineItem> items;

  // Суммы
  final double documentAmount;
  final double discountAmount;
  final double taxAmount;
  final String currency;

  // Оплата
  final String paymentMethod; // cash, card
  final double paidAmount; // Оплачено
  final double remainingAmount; // Остаток

  // Связанный заказ
  final String? orderKey; // ЗаказКлиента_Key
  final String? orderNumber; // ЗаказКлиента_Nomer

  // Доставка
  final String? deliveryAddress;

  // Прочее
  final String comment;
  final bool posted;
  final bool deletionMark;

  const OneCSaleDocument({
    required this.date,
    required this.number,
    required this.status,
    required this.operationType,
    required this.counterpartyKey,
    required this.counterpartyCode,
    required this.counterpartyName,
    required this.organizationKey,
    required this.warehouseKey,
    required this.warehouseCode,
    required this.agentKey,
    required this.agentCode,
    required this.contractKey,
    required this.contractNumber,
    required this.items,
    required this.documentAmount,
    required this.discountAmount,
    required this.taxAmount,
    required this.currency,
    required this.paymentMethod,
    required this.paidAmount,
    required this.remainingAmount,
    this.orderKey,
    this.orderNumber,
    this.deliveryAddress,
    required this.comment,
    required this.posted,
    required this.deletionMark,
  });

  factory OneCSaleDocument.fromJson(Map<String, dynamic> json) {
    return OneCSaleDocument(
      date: json['Date'] ?? '',
      number: json['Number'] ?? '',
      status: json['Status'] ?? '',
      operationType: json['ВидОперации'] ?? 'Реализация',
      counterpartyKey: json['Контрагент_Key'] ?? '',
      counterpartyCode: json['Контрагент_Code'] ?? '',
      counterpartyName: json['Контрагент_Description'] ?? '',
      organizationKey: json['Организация_Key'] ?? '',
      warehouseKey: json['Склад_Key'] ?? '',
      warehouseCode: json['Склад_Code'] ?? '',
      agentKey: json['Ответственный_Key'] ?? '',
      agentCode: json['Ответственный_Code'] ?? '',
      contractKey: json['Договор_Key'] ?? '',
      contractNumber: json['Договор_Nomer'] ?? '',
      items: (json['ТабличнаяЧасть'] as List?)
              ?.map((i) => OneCSaleLineItem.fromJson(i))
              .toList() ??
          [],
      documentAmount: (json['СуммаДокумента'] ?? 0).toDouble(),
      discountAmount: (json['СуммаСкидки'] ?? 0).toDouble(),
      taxAmount: (json['СуммаНДС'] ?? 0).toDouble(),
      currency: json['Валюта'] ?? 'UZS',
      paymentMethod: json['СпособОплаты'] ?? 'cash',
      paidAmount: (json['Оплачено'] ?? 0).toDouble(),
      remainingAmount: (json['Остаток'] ?? 0).toDouble(),
      orderKey: json['ЗаказКлиента_Key'],
      orderNumber: json['ЗаказКлиента_Nomer'],
      deliveryAddress: json['АдресДоставки'],
      comment: json['Комментарий'] ?? '',
      posted: json['Posted'] ?? false,
      deletionMark: json['DeletionMark'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Date': date,
      'Number': number,
      'Status': status,
      'ВидОперации': operationType,
      'Контрагент_Key': counterpartyKey,
      'Контрагент_Code': counterpartyCode,
      'Контрагент_Description': counterpartyName,
      'Организация_Key': organizationKey,
      'Склад_Key': warehouseKey,
      'Склад_Code': warehouseCode,
      'Ответственный_Key': agentKey,
      'Ответственный_Code': agentCode,
      'Договор_Key': contractKey,
      'Договор_Nomer': contractNumber,
      'ТабличнаяЧасть': items.map((i) => i.toJson()).toList(),
      'СуммаДокумента': documentAmount,
      'СуммаСкидки': discountAmount,
      'СуммаНДС': taxAmount,
      'Валюта': currency,
      'СпособОплаты': paymentMethod,
      'Оплачено': paidAmount,
      'Остаток': remainingAmount,
      if (orderKey != null) 'ЗаказКлиента_Key': orderKey,
      if (orderNumber != null) 'ЗаказКлиента_Nomer': orderNumber,
      if (deliveryAddress != null) 'АдресДоставки': deliveryAddress,
      'Комментарий': comment,
    };
  }

  bool get isFullyPaid => remainingAmount <= 0;
  bool get hasOrder => orderKey != null && orderKey!.isNotEmpty;
}

/// 1C Sotuv hujjati elementi
class OneCSaleLineItem {
  final int lineNumber;
  final String productKey;
  final String productCode;
  final String productName;
  final String characteristicKey;
  final double quantity;
  final String unitKey;
  final String unitName;
  final double unitFactor;
  final double price;
  final double amount;
  final double discountPercent;
  final double discountAmount;
  final double amountWithDiscount;
  final double taxRate;
  final double taxAmount;
  final double totalAmount;
  final String warehouseKey;
  final String? batchKey;
  final String comment;
  final double? costPrice; // Себестоимость
  final bool isGift;
  final String? promotionKey;

  const OneCSaleLineItem({
    required this.lineNumber,
    required this.productKey,
    required this.productCode,
    required this.productName,
    required this.characteristicKey,
    required this.quantity,
    required this.unitKey,
    required this.unitName,
    required this.unitFactor,
    required this.price,
    required this.amount,
    required this.discountPercent,
    required this.discountAmount,
    required this.amountWithDiscount,
    required this.taxRate,
    required this.taxAmount,
    required this.totalAmount,
    required this.warehouseKey,
    this.batchKey,
    required this.comment,
    this.costPrice,
    required this.isGift,
    this.promotionKey,
  });

  factory OneCSaleLineItem.fromJson(Map<String, dynamic> json) {
    return OneCSaleLineItem(
      lineNumber: json['НомерСтроки'] ?? 0,
      productKey: json['Номенклатура_Key'] ?? '',
      productCode: json['Номенклатура_Code'] ?? '',
      productName: json['Номенклатура_Description'] ?? '',
      characteristicKey: json['Характеристика_Key'] ?? '',
      quantity: (json['Количество'] ?? 0).toDouble(),
      unitKey: json['ЕдиницаИзмерения_Key'] ?? '',
      unitName: json['ЕдиницаИзмерения_Description'] ?? '',
      unitFactor: (json['Коэффициент'] ?? 1).toDouble(),
      price: (json['Цена'] ?? 0).toDouble(),
      amount: (json['Сумма'] ?? 0).toDouble(),
      discountPercent: (json['ПроцентСкидки'] ?? 0).toDouble(),
      discountAmount: (json['СуммаСкидки'] ?? 0).toDouble(),
      amountWithDiscount: (json['СуммаСоСкидкой'] ?? 0).toDouble(),
      taxRate: (json['СтавкаНДС'] ?? 0).toDouble(),
      taxAmount: (json['СуммаНДС'] ?? 0).toDouble(),
      totalAmount: (json['Всего'] ?? 0).toDouble(),
      warehouseKey: json['Склад_Key'] ?? '',
      batchKey: json['Серия_Key'],
      comment: json['Комментарий'] ?? '',
      costPrice: json['Себестоимость']?.toDouble(),
      isGift: json['Подарок'] ?? false,
      promotionKey: json['Акция_Key'],
    );
  }

  Map<String, dynamic> toJson() => {
        'НомерСтроки': lineNumber,
        'Номенклатура_Key': productKey,
        'Номенклатура_Code': productCode,
        'Номенклатура_Description': productName,
        'Характеристика_Key': characteristicKey,
        'Количество': quantity,
        'ЕдиницаИзмерения_Key': unitKey,
        'ЕдиницаИзмерения_Description': unitName,
        'Коэффициент': unitFactor,
        'Цена': price,
        'Сумма': amount,
        'ПроцентСкидки': discountPercent,
        'СуммаСкидки': discountAmount,
        'СуммаСоСкидкой': amountWithDiscount,
        'СтавкаНДС': taxRate,
        'СуммаНДС': taxAmount,
        'Всего': totalAmount,
        'Склад_Key': warehouseKey,
        if (batchKey != null) 'Серия_Key': batchKey,
        'Комментарий': comment,
        if (costPrice != null) 'Себестоимость': costPrice,
        'Подарок': isGift,
        if (promotionKey != null) 'Акция_Key': promotionKey,
      };
}

// ============================================================
// 1C РЕАЛИЗАЦИЯ ХОЛАТИ (PREVEDION/OTKAZ)
// ============================================================

/// 1C Реализация holati
class OneCSaleDocumentStatus {
  final String refKey; // Ref_Key
  final String number; // Номер
  final String date; // Дата
  final bool posted; // Проведен (o'tkazildi)
  final bool deletionMark; // ПометкаУдаления
  final String status; // Статус

  // Связанные документы
  final String? orderKey; // ЗаказКлиента_Key
  final String? orderNumber; // ЗаказКлиента_Nomer

  // Оплата
  final double documentAmount; // СуммаДокумента
  final double paidAmount; // Оплачено
  final double remainingAmount; // Остаток
  final bool isFullyPaid; // ПолностьюОплачено

  // Отгрузка
  final bool isShipped; // Отгружено
  final DateTime? shippedDate; // ДатаОтгрузки

  // Возврат
  final bool hasReturn; // ЕстьВозврат
  final String? returnKey; // Возврат_Key
  final double returnAmount; // СуммаВозврата

  // Ошибки
  final String? errorMessage;

  const OneCSaleDocumentStatus({
    required this.refKey,
    required this.number,
    required this.date,
    required this.posted,
    required this.deletionMark,
    required this.status,
    this.orderKey,
    this.orderNumber,
    required this.documentAmount,
    required this.paidAmount,
    required this.remainingAmount,
    required this.isFullyPaid,
    required this.isShipped,
    this.shippedDate,
    required this.hasReturn,
    this.returnKey,
    required this.returnAmount,
    this.errorMessage,
  });

  factory OneCSaleDocumentStatus.fromJson(Map<String, dynamic> json) {
    return OneCSaleDocumentStatus(
      refKey: json['Ref_Key'] ?? '',
      number: json['Number'] ?? '',
      date: json['Date'] ?? '',
      posted: json['Posted'] ?? false,
      deletionMark: json['DeletionMark'] ?? false,
      status: json['Status'] ?? '',
      orderKey: json['ЗаказКлиента_Key'],
      orderNumber: json['ЗаказКлиента_Nomer'],
      documentAmount: (json['СуммаДокумента'] ?? 0).toDouble(),
      paidAmount: (json['Оплачено'] ?? 0).toDouble(),
      remainingAmount: (json['Остаток'] ?? 0).toDouble(),
      isFullyPaid: json['ПолностьюОплачено'] ?? false,
      isShipped: json['Отгружено'] ?? false,
      shippedDate: json['ДатаОтгрузки'] != null
          ? DateTime.parse(json['ДатаОтгрузки'])
          : null,
      hasReturn: json['ЕстьВозврат'] ?? false,
      returnKey: json['Возврат_Key'],
      returnAmount: (json['СуммаВозврата'] ?? 0).toDouble(),
      errorMessage: json['ErrorMessage'],
    );
  }

  // Status helpers
  bool get isDraft => !posted && !deletionMark;
  bool get isPosted => posted && !deletionMark;
  bool get isCancelled => deletionMark;

  String get statusText {
    if (isCancelled) return 'Bekor qilingan';
    if (isDraft) return 'Qoralama';
    if (hasReturn) return 'Qaytarish bilan';
    if (isFullyPaid) return 'To\'liq to\'langan';
    if (isShipped) return 'Yetkazilgan';
    if (isPosted) return 'O\'tkazilgan';
    return status;
  }
}

// ============================================================
// 1C BUYURTMA LAR ELEMENTI
// ============================================================

/// 1C Buyurtma elementi
class OneCOrderLineItem {
  final int lineNumber;
  final String productKey;
  final String productCode;
  final String productName;
  final String characteristicKey;
  final double quantity;
  final String unitKey;
  final String unitName;
  final double unitFactor;
  final double price;
  final double amount;
  final double discountPercent;
  final double discountAmount;
  final double amountWithDiscount;
  final double taxRate;
  final double taxAmount;
  final double totalAmount;
  final String warehouseKey;
  final String? batchKey;
  final String comment;
  final bool isGift;
  final String? promotionKey;
  final String? promotionName;
  final double? shippedQuantity; // Отгружено
  final double? invoicedQuantity; // Счет выписан

  const OneCOrderLineItem({
    required this.lineNumber,
    required this.productKey,
    required this.productCode,
    required this.productName,
    required this.characteristicKey,
    required this.quantity,
    required this.unitKey,
    required this.unitName,
    required this.unitFactor,
    required this.price,
    required this.amount,
    required this.discountPercent,
    required this.discountAmount,
    required this.amountWithDiscount,
    required this.taxRate,
    required this.taxAmount,
    required this.totalAmount,
    required this.warehouseKey,
    this.batchKey,
    required this.comment,
    required this.isGift,
    this.promotionKey,
    this.promotionName,
    this.shippedQuantity,
    this.invoicedQuantity,
  });

  factory OneCOrderLineItem.fromJson(Map<String, dynamic> json) {
    return OneCOrderLineItem(
      lineNumber: json['НомерСтроки'] ?? 0,
      productKey: json['Номенклатура_Key'] ?? '',
      productCode: json['Номенклатура_Code'] ?? '',
      productName: json['Номенклатура_Description'] ?? '',
      characteristicKey: json['Характеристика_Key'] ?? '',
      quantity: (json['Количество'] ?? 0).toDouble(),
      unitKey: json['ЕдиницаИзмерения_Key'] ?? '',
      unitName: json['ЕдиницаИзмерения_Description'] ?? '',
      unitFactor: (json['Коэффициент'] ?? 1).toDouble(),
      price: (json['Цена'] ?? 0).toDouble(),
      amount: (json['Сумма'] ?? 0).toDouble(),
      discountPercent: (json['ПроцентСкидки'] ?? 0).toDouble(),
      discountAmount: (json['СуммаСкидки'] ?? 0).toDouble(),
      amountWithDiscount: (json['СуммаСоСкидкой'] ?? 0).toDouble(),
      taxRate: (json['СтавкаНДС'] ?? 0).toDouble(),
      taxAmount: (json['СуммаНДС'] ?? 0).toDouble(),
      totalAmount: (json['Всего'] ?? 0).toDouble(),
      warehouseKey: json['Склад_Key'] ?? '',
      batchKey: json['Серия_Key'],
      comment: json['Комментарий'] ?? '',
      isGift: json['Подарок'] ?? false,
      promotionKey: json['Акция_Key'],
      promotionName: json['Акция_Description'],
      shippedQuantity: json['Отгружено']?.toDouble(),
      invoicedQuantity: json['СчетВыписан']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'НомерСтроки': lineNumber,
        'Номенклатура_Key': productKey,
        'Номенклатура_Code': productCode,
        'Номенклатура_Description': productName,
        'Характеристика_Key': characteristicKey,
        'Количество': quantity,
        'ЕдиницаИзмерения_Key': unitKey,
        'ЕдиницаИзмерения_Description': unitName,
        'Коэффициент': unitFactor,
        'Цена': price,
        'Сумма': amount,
        'ПроцентСкидки': discountPercent,
        'СуммаСкидки': discountAmount,
        'СуммаСоСкидкой': amountWithDiscount,
        'СтавкаНДС': taxRate,
        'СуммаНДС': taxAmount,
        'Всего': totalAmount,
        'Склад_Key': warehouseKey,
        if (batchKey != null) 'Серия_Key': batchKey,
        'Комментарий': comment,
        'Подарок': isGift,
        if (promotionKey != null) 'Акция_Key': promotionKey,
        if (promotionName != null) 'Акция_Description': promotionName,
      };

  double get remainingQuantity => quantity - (shippedQuantity ?? 0);
  bool get isFullyShipped => (shippedQuantity ?? 0) >= quantity;
}
