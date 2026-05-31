// ============================================================
// 1C:ENTERPRISE - BUYURTMA VA QAYTARISH FORMATLARI
// Haqiqiy 1C konfiguratsiyaga mos
// ============================================================

/// 1C Buyurtma (ЗаказКлиента) - yuborish formati
///
/// 1C da buyurtmalar "Документ.ЗаказКлиента" da saqlanadi
class OneCOrderRequest {
  final String date; // Дата (ISO 8601)
  final String number; // Номер (avtomatik)
  final OneCOrderCustomer customer; // Контрагент
  final OneCOrderAgent agent; // Ответственный
  final OneCOrderWarehouse warehouse; // Склад
  final List<OneCOrderItem> items; // ТабличнаяЧасть
  final double documentAmount; // СуммаДокумента
  final String currency; // Валюта
  final String paymentMethod; // СпособОплаты
  final String paymentTerms; // УсловияОплаты
  final int paymentDays; // Отсрочка
  final DateTime? deliveryDate; // ДатаДоставки
  final String? deliveryTimeSlot; // ВремяДоставки
  final String? deliveryAddress; // АдресДоставки
  final double? deliveryLatitude; // Широта
  final double? deliveryLongitude; // Долгота
  final String comment; // Комментарий
  final String status; // Статус
  final Map<String, dynamic>? additionalData; // ДопРеквизиты

  const OneCOrderRequest({
    required this.date,
    required this.number,
    required this.customer,
    required this.agent,
    required this.warehouse,
    required this.items,
    required this.documentAmount,
    required this.currency,
    required this.paymentMethod,
    required this.paymentTerms,
    required this.paymentDays,
    this.deliveryDate,
    this.deliveryTimeSlot,
    this.deliveryAddress,
    this.deliveryLatitude,
    this.deliveryLongitude,
    required this.comment,
    required this.status,
    this.additionalData,
  });

  /// JSON ga aylantirish (1C ga yuborish uchun)
  Map<String, dynamic> toJson() {
    return {
      'Date': date,
      'Number': number,
      'Контрагент': customer.toJson(),
      'Ответственный': agent.toJson(),
      'Склад': warehouse.toJson(),
      'ТабличнаяЧасть': items.map((item) => item.toJson()).toList(),
      'СуммаДокумента': documentAmount,
      'Валюта': currency,
      'СпособОплаты': paymentMethod,
      'УсловияОплаты': paymentTerms,
      'Отсрочка': paymentDays,
      if (deliveryDate != null) 'ДатаДоставки': deliveryDate!.toIso8601String(),
      if (deliveryTimeSlot != null) 'ВремяДоставки': deliveryTimeSlot,
      if (deliveryAddress != null) 'АдресДоставки': deliveryAddress,
      if (deliveryLatitude != null) 'Широта': deliveryLatitude,
      if (deliveryLongitude != null) 'Долгота': deliveryLongitude,
      'Комментарий': comment,
      'Статус': status,
      if (additionalData != null) 'ДопРеквизиты': additionalData,
    };
  }
}

/// 1C Buyurtma mijoz ma'lumotlari
class OneCOrderCustomer {
  final String refKey; // Контрагент_Key (GUID)
  final String code; // Контрагент_Code
  final String description; // Контрагент_Description
  final String priceGroupKey; // ЦеноваяГруппа_Key
  final String agentKey; // Ответственный_Key

  const OneCOrderCustomer({
    required this.refKey,
    required this.code,
    required this.description,
    required this.priceGroupKey,
    required this.agentKey,
  });

  Map<String, dynamic> toJson() => {
        'Ref_Key': refKey,
        'Code': code,
        'Description': description,
        'ЦеноваяГруппа_Key': priceGroupKey,
        'Ответственный_Key': agentKey,
      };
}

/// 1C Buyurtma agent ma'lumotlari
class OneCOrderAgent {
  final String refKey; // Ответственный_Key
  final String code; // Код
  final String description; // Наименование

  const OneCOrderAgent({
    required this.refKey,
    required this.code,
    required this.description,
  });

  Map<String, dynamic> toJson() => {
        'Ref_Key': refKey,
        'Code': code,
        'Description': description,
      };
}

/// 1C Buyurtma ombor
class OneCOrderWarehouse {
  final String refKey; // Склад_Key
  final String code; // Код
  final String description; // Наименование

  const OneCOrderWarehouse({
    required this.refKey,
    required this.code,
    required this.description,
  });

  Map<String, dynamic> toJson() => {
        'Ref_Key': refKey,
        'Code': code,
        'Description': description,
      };
}

/// 1C Buyurtma elementi (ТабличнаяЧасть)
class OneCOrderItem {
  final int lineNumber; // НомерСтроки
  final String productKey; // Номенклатура_Key
  final String productCode; // Номенклатура_Code
  final String productName; // Номенклатура_Description
  final String characteristicKey; // Характеристика_Key (rang, hajm)
  final double quantity; // Количество
  final String unitKey; // ЕдиницаИзмерения_Key
  final String unitName; // ЕдиницаИзмерения_Description
  final double unitFactor; // Коэффициент
  final double price; // Цена
  final double amount; // Сумма
  final double discountPercent; // ПроцентСкидки
  final double discountAmount; // СуммаСкидки
  final double amountWithDiscount; // СуммаСоСкидкой
  final double taxRate; // СтавкаНДС
  final double taxAmount; // СуммаНДС
  final double totalAmount; // Всего
  final String? warehouseKey; // Склад_Key (ombor)
  final String? batchKey; // Серия_Key (partiya)
  final String comment; // Комментарий
  final double? weight; // Вес
  final double? volume; // Объем
  final bool isGift; // Подарок
  final String? promotionKey; // Акция_Key
  final String? promotionName; // Акция_Description

  const OneCOrderItem({
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
    this.warehouseKey,
    this.batchKey,
    required this.comment,
    this.weight,
    this.volume,
    required this.isGift,
    this.promotionKey,
    this.promotionName,
  });

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
        if (warehouseKey != null) 'Склад_Key': warehouseKey,
        if (batchKey != null) 'Серия_Key': batchKey,
        'Комментарий': comment,
        if (weight != null) 'Вес': weight,
        if (volume != null) 'Объем': volume,
        'Подарок': isGift,
        if (promotionKey != null) 'Акция_Key': promotionKey,
        if (promotionName != null) 'Акция_Description': promotionName,
      };
}

// ============================================================
// 1C QAYTARISH (ВозвратТоваровОтПокупателя) - yuborish formati
// ============================================================

/// 1C Qaytarish so'rovi
class OneCReturnRequest {
  final String date; // Дата
  final String number; // Номер
  final String orderKey; // ЗаказКлиента_Key (asosiy buyurtma)
  final String orderNumber; // ЗаказКлиента_Nomer
  final OneCOrderCustomer customer; // Контрагент
  final OneCOrderAgent agent; // Ответственный
  final OneCOrderWarehouse warehouse; // Склад
  final List<OneCReturnItem> items; // ТабличнаяЧасть
  final double documentAmount; // СуммаДокумента
  final String currency; // Валюта
  final String returnReason; // ПричинаВозврата
  final String returnReasonDescription; // ПричинаВозврата описание
  final String comment; // Комментарий
  final String status; // Статус
  final List<String> photoUrls; // Фото
  final String? signatureUrl; // Подпись

  const OneCReturnRequest({
    required this.date,
    required this.number,
    required this.orderKey,
    required this.orderNumber,
    required this.customer,
    required this.agent,
    required this.warehouse,
    required this.items,
    required this.documentAmount,
    required this.currency,
    required this.returnReason,
    required this.returnReasonDescription,
    required this.comment,
    required this.status,
    this.photoUrls = const [],
    this.signatureUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'Date': date,
      'Number': number,
      'ЗаказКлиента_Key': orderKey,
      'ЗаказКлиента_Nomer': orderNumber,
      'Контрагент': customer.toJson(),
      'Ответственный': agent.toJson(),
      'Склад': warehouse.toJson(),
      'ТабличнаяЧасть': items.map((item) => item.toJson()).toList(),
      'СуммаДокумента': documentAmount,
      'Валюта': currency,
      'ПричинаВозврата': returnReason,
      'ПричинаВозврата_Описание': returnReasonDescription,
      'Комментарий': comment,
      'Статус': status,
      'Фото': photoUrls,
      if (signatureUrl != null) 'Подпись': signatureUrl,
    };
  }
}

/// 1C Qaytarish elementi
class OneCReturnItem {
  final int lineNumber; // НомерСтроки
  final String productKey; // Номенклатура_Key
  final String productCode; // Номенклатура_Code
  final String productName; // Номенклатура_Description
  final double quantity; // Количество
  final String unitKey; // ЕдиницаИзмерения_Key
  final double price; // Цена
  final double amount; // Сумма
  final String returnReason; // ПричинаВозврата
  final String condition; // Состояние (good, damaged, expired)
  final String? batchNumber; // СерияНомер
  final String comment; // Комментарий

  const OneCReturnItem({
    required this.lineNumber,
    required this.productKey,
    required this.productCode,
    required this.productName,
    required this.quantity,
    required this.unitKey,
    required this.price,
    required this.amount,
    required this.returnReason,
    required this.condition,
    this.batchNumber,
    required this.comment,
  });

  Map<String, dynamic> toJson() => {
        'НомерСтроки': lineNumber,
        'Номенклатура_Key': productKey,
        'Номенклатура_Code': productCode,
        'Номенклатура_Description': productName,
        'Количество': quantity,
        'ЕдиницаИзмерения_Key': unitKey,
        'Цена': price,
        'Сумма': amount,
        'ПричинаВозврата': returnReason,
        'Состояние': condition,
        if (batchNumber != null) 'СерияНомер': batchNumber,
        'Комментарий': comment,
      };
}

// ============================================================
// 1C BUYURTMA JAVOBI (Response)
// ============================================================

/// 1C Buyurtma javobi
class OneCOrderResponse {
  final String refKey; // Ref_Key (GUID)
  final String number; // Номер
  final String date; // Дата
  final bool posted; // Проведен
  final bool deletionMark; // ПометкаУдаления
  final String status; // Статус
  final double documentAmount; // СуммаДокумента
  final String? errorMessage; // Ошибка

  const OneCOrderResponse({
    required this.refKey,
    required this.number,
    required this.date,
    required this.posted,
    required this.deletionMark,
    required this.status,
    required this.documentAmount,
    this.errorMessage,
  });

  factory OneCOrderResponse.fromJson(Map<String, dynamic> json) {
    return OneCOrderResponse(
      refKey: json['Ref_Key'] ?? '',
      number: json['Number'] ?? '',
      date: json['Date'] ?? '',
      posted: json['Posted'] ?? false,
      deletionMark: json['DeletionMark'] ?? false,
      status: json['Status'] ?? '',
      documentAmount: (json['DocumentAmount'] ?? 0).toDouble(),
      errorMessage: json['ErrorMessage'],
    );
  }

  bool get isSuccess => refKey.isNotEmpty && posted;
}

/// 1C Buyurtma holati
class OneCOrderStatus {
  final String refKey; // Ref_Key
  final String number; // Номер
  final String status; // Статус
  final String statusDescription; // Статус описание
  final DateTime? shippedDate; // ДатаОтгрузки
  final DateTime? deliveredDate; // ДатаДоставки
  final DateTime? paidDate; // ДатаОплаты
  final double paidAmount; // СуммаОплачено
  final double remainingAmount; // Остаток
  final String? invoiceKey; // СчетНаОплату_Key
  final String? shipmentKey; // Реализация_Key
  final List<OneCOrderStatusHistory> history; // ИсторияСтатусов

  const OneCOrderStatus({
    required this.refKey,
    required this.number,
    required this.status,
    required this.statusDescription,
    this.shippedDate,
    this.deliveredDate,
    this.paidDate,
    required this.paidAmount,
    required this.remainingAmount,
    this.invoiceKey,
    this.shipmentKey,
    required this.history,
  });

  factory OneCOrderStatus.fromJson(Map<String, dynamic> json) {
    return OneCOrderStatus(
      refKey: json['Ref_Key'] ?? '',
      number: json['Number'] ?? '',
      status: json['Status'] ?? '',
      statusDescription: json['StatusDescription'] ?? '',
      shippedDate: json['ShippedDate'] != null
          ? DateTime.parse(json['ShippedDate'])
          : null,
      deliveredDate: json['DeliveredDate'] != null
          ? DateTime.parse(json['DeliveredDate'])
          : null,
      paidDate:
          json['PaidDate'] != null ? DateTime.parse(json['PaidDate']) : null,
      paidAmount: (json['PaidAmount'] ?? 0).toDouble(),
      remainingAmount: (json['RemainingAmount'] ?? 0).toDouble(),
      invoiceKey: json['InvoiceKey'],
      shipmentKey: json['ShipmentKey'],
      history: (json['History'] as List?)
              ?.map((h) => OneCOrderStatusHistory.fromJson(h))
              .toList() ??
          [],
    );
  }
}

/// 1C Buyurtma holati tarixi
class OneCOrderStatusHistory {
  final DateTime date;
  final String status;
  final String statusDescription;
  final String? user;
  final String? comment;

  const OneCOrderStatusHistory({
    required this.date,
    required this.status,
    required this.statusDescription,
    this.user,
    this.comment,
  });

  factory OneCOrderStatusHistory.fromJson(Map<String, dynamic> json) {
    return OneCOrderStatusHistory(
      date: DateTime.parse(json['Date']),
      status: json['Status'] ?? '',
      statusDescription: json['StatusDescription'] ?? '',
      user: json['User'],
      comment: json['Comment'],
    );
  }
}
