// ============================================================
// 1C:ENTERPRISE - MIJOZ (КОНТРАГЕНТ/ПАРТНЕР) MODELS
// Haqiqiy 1C konfiguratsiyaga mos
// ============================================================

/// 1C Mijoz (Контрагент) - to'liq tuzilma
///
/// 1C da mijozlar "Справочник.Контрагенты" da saqlanadi
/// Ba'zi konfiguratsiyalarda "Справочник.Партнеры" ham ishlatiladi
class OneCCounterparty {
  final String refKey; // УникальныйИдентификатор (GUID)
  final String code; // Код (avtomatik)
  final String description; // Наименование (asosiy nom)
  final String fullName; // НаименованиеПолное (to'liq yuridik nom)

  // ============ ТАСНИФЛОВ (CLASSIFICATION) ============
  final String counterpartyType; // ВидКонтрагента (ЮрЛицо, ФизЛицо, ИП)
  final String counterpartyTypeName; // ВидКонтрагента наименование
  final String parentKey; // Родитель (kategoriya/guruh)
  final String parentDescription; // Родитель наименование
  final String groupKey; // ГруппаКонтрагентов (mijoz guruhi)
  final String groupDescription; // ГруппаКонтрагентов наименование

  // ============ СОЛИҚ (ИНН/СТИР) ============
  final String inn; // ИНН (СТИР/Soliq raqami)
  final String? oked; // ОКЭД (OKED kodi)
  final String? kpp; // КПП (Rus uchun)
  final String? okpo; // ОКПО

  // ============ МАНЗИЛ (АДРЕС) ============
  final String legalAddress; // ЮридическийАдрес (yuridik manzil)
  final String? actualAddress; // ФактическийАдрес (haqiqiy manzil)
  final String? deliveryAddress; // АдресДоставки (yetkazish manzili)
  final String? countryKey; // Страна
  final String? countryName; // Страна наименование
  final String? regionKey; // Регион
  final String? regionName; // Регион наименование
  final String? districtKey; // Район
  final String? districtName; // Район наименование
  final String? cityKey; // Город
  final String? cityName; // Город наименование
  final String? street; // Улица
  final String? houseNumber; // Дом
  final String? apartment; // Квартира/Офис
  final String? postalCode; // Индекс

  // ============ ГЕОЛОКАЦИЯ ============
  final double? latitude; // Широта
  final double? longitude; // Долгота
  final String? gpsNotes; // GPS примечание

  // ============ АЛОКА (КОНТАКТЫ) ============
  final String phone; // ТелефонОсновной
  final String? phone2; // ТелефонДополнительный
  final String? fax; // Факс
  final String? email; // ЭлектроннаяПочта
  final String? website; // ИнтернетСтраница
  final String? contactPerson; // КонтактноеЛицо
  final String? contactPersonPhone; // КонтактноеЛицоТелефон
  final String? contactPersonEmail; // КонтактноеЛицоEmail
  final String? contactPersonPosition; // КонтактноеЛицоДолжность

  // ============ САВДО (ПРОДАЖИ) ============
  final String agentKey; // Ответственный (Agent)
  final String agentCode; // Ответственный код
  final String agentName; // Ответственный наименование
  final String? supervisorKey; // Руководитель (Supervisor)
  final String? supervisorName; // Руководитель наименование
  final String priceGroupKey; // ЦеноваяГруппа (narx guruhi)
  final String priceGroupName; // ЦеноваяГруппа наименование
  final String customerGroupKey; // ГруппаПокупателей
  final String customerGroupName; // ГруппаПокупателей наименование
  final String? discountGroupKey; // ГруппаСкидок
  final String? discountGroupName; // ГруппаСкидок наименование
  final String? regionSalesKey; // ТерриторияПродаж (savdo hududi)
  final String? regionSalesName; // ТерриторияПродаж наименование

  // ============ ТУЛОВ (ОПЛАТА) ============
  final String paymentTerms; // УсловияОплаты (to'lov shartlari)
  final String paymentTermsDescription; // УсловияОплаты наименование
  final int paymentDelayDays; // Отсрочка (kun)
  final double creditLimit; // КредитныйЛимит
  final String currency; // ВалютаВзаиморасчетов
  final String? bankAccount; // РасчетныйСчет
  final String? bankName; // Банк наименование
  final String? bankMfo; // МФО (bank kodi)
  final String? bankInn; // БанкИНН

  // ============ КАРЗ (ЗАДОЛЖЕННОСТЬ) ============
  final double currentDebt; // ТекущийДолг
  final double overdueDebt; // ПросроченныйДолг
  final double totalDebt; // ОбщийДолг (currentDebt + overdueDebt)
  final DateTime? lastPaymentDate; // ДатаПоследнейОплаты
  final double lastPaymentAmount; // СуммаПоследнейОплаты
  final DateTime? lastOrderDate; // ДатаПоследнегоЗаказа
  final double lastOrderAmount; // СуммаПоследнегоЗаказа

  // ============ САВДО СТАТИСТИКАСИ ============
  final int totalOrders; // КоличествоЗаказов
  final double totalSales; // ОбъемПродаж
  final int ordersThisMonth; // ЗаказыЗаМесяц
  final double salesThisMonth; // ПродажиЗаМесяц
  final int ordersThisYear; // ЗаказыЗаГод
  final double salesThisYear; // ПродажиЗаГод
  final double averageOrderAmount; // СреднийЧек

  // ============ ТАШРИФЛАР (ПОСЕЩЕНИЯ) ============
  final int totalVisits; // КоличествоПосещений
  final DateTime? lastVisitDate; // ДатаПоследнегоПосещения
  final int visitFrequency; // ЧастотаПосещений (kun)
  final String? preferredVisitDay; // ПредпочтительныйДень
  final String? preferredVisitTime; // ПредпочтительноеВремя

  // ============ ХУСУСИЯТЛАР (ДОПОЛНИТЕЛЬНЫЕ РЕКВИЗИТЫ) ============
  final String
      customerType; // ТипКонтрагента (corporate, individual, government)
  final bool isVIP; // VIPКлиент
  final String? loyaltyCardNumber; // НомерКартыЛояльности
  final String? notes; // Комментарий
  final String? internalNotes; // ВнутреннийКомментарий
  final List<String> tags; // Теги

  // ============ ХОЛАТ (СОСТОЯНИЕ) ============
  final bool isActive; // Активный
  final bool isBlocked; // Заблокирован
  final String? blockReason; // ПричинаБлокировки
  final DateTime? blockedDate; // ДатаБлокировки
  final String? blockedBy; // КемЗаблокирован

  // ============ ВАКТ (ДАТЫ) ============
  final DateTime createdAt; // ДатаСоздания
  final DateTime? updatedAt; // ДатаИзменения
  final String? createdBy; // КемСоздан

  const OneCCounterparty({
    required this.refKey,
    required this.code,
    required this.description,
    required this.fullName,
    required this.counterpartyType,
    required this.counterpartyTypeName,
    required this.parentKey,
    required this.parentDescription,
    required this.groupKey,
    required this.groupDescription,
    required this.inn,
    this.oked,
    this.kpp,
    this.okpo,
    required this.legalAddress,
    this.actualAddress,
    this.deliveryAddress,
    this.countryKey,
    this.countryName,
    this.regionKey,
    this.regionName,
    this.districtKey,
    this.districtName,
    this.cityKey,
    this.cityName,
    this.street,
    this.houseNumber,
    this.apartment,
    this.postalCode,
    this.latitude,
    this.longitude,
    this.gpsNotes,
    required this.phone,
    this.phone2,
    this.fax,
    this.email,
    this.website,
    this.contactPerson,
    this.contactPersonPhone,
    this.contactPersonEmail,
    this.contactPersonPosition,
    required this.agentKey,
    required this.agentCode,
    required this.agentName,
    this.supervisorKey,
    this.supervisorName,
    required this.priceGroupKey,
    required this.priceGroupName,
    required this.customerGroupKey,
    required this.customerGroupName,
    this.discountGroupKey,
    this.discountGroupName,
    this.regionSalesKey,
    this.regionSalesName,
    required this.paymentTerms,
    required this.paymentTermsDescription,
    required this.paymentDelayDays,
    required this.creditLimit,
    required this.currency,
    this.bankAccount,
    this.bankName,
    this.bankMfo,
    this.bankInn,
    required this.currentDebt,
    required this.overdueDebt,
    required this.totalDebt,
    this.lastPaymentDate,
    required this.lastPaymentAmount,
    this.lastOrderDate,
    required this.lastOrderAmount,
    required this.totalOrders,
    required this.totalSales,
    required this.ordersThisMonth,
    required this.salesThisMonth,
    required this.ordersThisYear,
    required this.salesThisYear,
    required this.averageOrderAmount,
    required this.totalVisits,
    this.lastVisitDate,
    required this.visitFrequency,
    this.preferredVisitDay,
    this.preferredVisitTime,
    required this.customerType,
    required this.isVIP,
    this.loyaltyCardNumber,
    this.notes,
    this.internalNotes,
    this.tags = const [],
    required this.isActive,
    required this.isBlocked,
    this.blockReason,
    this.blockedDate,
    this.blockedBy,
    required this.createdAt,
    this.updatedAt,
    this.createdBy,
  });

  bool get canOrder => isActive && !isBlocked;
  bool get hasDebt => currentDebt > 0;
  bool get hasOverdueDebt => overdueDebt > 0;
  bool get hasLocation => latitude != null && longitude != null;
  double get availableCredit => creditLimit - currentDebt;

  /// 1C JSON dan yaratish
  factory OneCCounterparty.fromJson(Map<String, dynamic> json) {
    return OneCCounterparty(
      refKey: json['Ref_Key'] ?? '',
      code: json['Code'] ?? '',
      description: json['Description'] ?? '',
      fullName: json['НаименованиеПолное'] ??
          json['FullName'] ??
          json['Description'] ??
          '',

      // Classification
      counterpartyType:
          json['ВидКонтрагента'] ?? json['CounterpartyType'] ?? 'ЮрЛицо',
      counterpartyTypeName: json['ВидКонтрагента_Наименование'] ??
          json['CounterpartyTypeName'] ??
          '',
      parentKey: json['Родитель_Key'] ?? json['Parent_Key'] ?? '',
      parentDescription:
          json['Родитель_Description'] ?? json['Parent_Description'] ?? '',
      groupKey:
          json['ГруппаКонтрагентов_Key'] ?? json['CustomerGroup_Key'] ?? '',
      groupDescription: json['ГруппаКонтрагентов_Description'] ??
          json['CustomerGroup_Description'] ??
          '',

      // Tax
      inn: json['ИНН'] ?? json['INN'] ?? '',
      oked: json['ОКЭД'] ?? json['OKED'],
      kpp: json['КПП'] ?? json['KPP'],
      okpo: json['ОКПО'] ?? json['OKPO'],

      // Address
      legalAddress: json['ЮридическийАдрес'] ?? json['LegalAddress'] ?? '',
      actualAddress: json['ФактическийАдрес'] ?? json['ActualAddress'],
      deliveryAddress: json['АдресДоставки'] ?? json['DeliveryAddress'],
      countryKey: json['Страна_Key'] ?? json['Country_Key'],
      countryName: json['Страна_Description'] ?? json['Country_Description'],
      regionKey: json['Регион_Key'] ?? json['Region_Key'],
      regionName: json['Регион_Description'] ?? json['Region_Description'],
      districtKey: json['Район_Key'] ?? json['District_Key'],
      districtName: json['Район_Description'] ?? json['District_Description'],
      cityKey: json['Город_Key'] ?? json['City_Key'],
      cityName: json['Город_Description'] ?? json['City_Description'],
      street: json['Улица'] ?? json['Street'],
      houseNumber: json['Дом'] ?? json['HouseNumber'],
      apartment: json['Квартира'] ?? json['Apartment'],
      postalCode: json['Индекс'] ?? json['PostalCode'],

      // GPS
      latitude: json['Широта']?.toDouble() ?? json['Latitude']?.toDouble(),
      longitude: json['Долгота']?.toDouble() ?? json['Longitude']?.toDouble(),
      gpsNotes: json['GPSПримечание'] ?? json['GPSNotes'],

      // Contacts
      phone: json['ТелефонОсновной'] ?? json['Phone'] ?? '',
      phone2: json['ТелефонДополнительный'] ?? json['Phone2'],
      fax: json['Факс'] ?? json['Fax'],
      email: json['ЭлектроннаяПочта'] ?? json['Email'],
      website: json['ИнтернетСтраница'] ?? json['Website'],
      contactPerson: json['КонтактноеЛицо'] ?? json['ContactPerson'],
      contactPersonPhone:
          json['КонтактноеЛицоТелефон'] ?? json['ContactPersonPhone'],
      contactPersonEmail:
          json['КонтактноеЛицоEmail'] ?? json['ContactPersonEmail'],
      contactPersonPosition:
          json['КонтактноеЛицоДолжность'] ?? json['ContactPersonPosition'],

      // Sales
      agentKey: json['Ответственный_Key'] ?? json['Agent_Key'] ?? '',
      agentCode: json['Ответственный_Code'] ?? json['Agent_Code'] ?? '',
      agentName:
          json['Ответственный_Description'] ?? json['Agent_Description'] ?? '',
      supervisorKey: json['Руководитель_Key'] ?? json['Supervisor_Key'],
      supervisorName:
          json['Руководитель_Description'] ?? json['Supervisor_Description'],
      priceGroupKey: json['ЦеноваяГруппа_Key'] ?? json['PriceGroup_Key'] ?? '',
      priceGroupName: json['ЦеноваяГруппа_Description'] ??
          json['PriceGroup_Description'] ??
          '',
      customerGroupKey:
          json['ГруппаПокупателей_Key'] ?? json['CustomerGroup_Key'] ?? '',
      customerGroupName: json['ГруппаПокупателей_Description'] ??
          json['CustomerGroup_Description'] ??
          '',
      discountGroupKey: json['ГруппаСкидок_Key'] ?? json['DiscountGroup_Key'],
      discountGroupName:
          json['ГруппаСкидок_Description'] ?? json['DiscountGroup_Description'],
      regionSalesKey:
          json['ТерриторияПродаж_Key'] ?? json['SalesTerritory_Key'],
      regionSalesName: json['ТерриторияПродаж_Description'] ??
          json['SalesTerritory_Description'],

      // Payment
      paymentTerms: json['УсловияОплаты'] ?? json['PaymentTerms'] ?? 'NET30',
      paymentTermsDescription: json['УсловияОплаты_Наименование'] ??
          json['PaymentTermsDescription'] ??
          '',
      paymentDelayDays: json['Отсрочка'] ?? json['PaymentDelayDays'] ?? 30,
      creditLimit:
          (json['КредитныйЛимит'] ?? json['CreditLimit'] ?? 0).toDouble(),
      currency: json['ВалютаВзаиморасчетов'] ?? json['Currency'] ?? 'UZS',
      bankAccount: json['РасчетныйСчет'] ?? json['BankAccount'],
      bankName: json['Банк'] ?? json['BankName'],
      bankMfo: json['МФО'] ?? json['BankMFO'],
      bankInn: json['БанкИНН'] ?? json['BankINN'],

      // Debt
      currentDebt: (json['ТекущийДолг'] ?? json['CurrentDebt'] ?? 0).toDouble(),
      overdueDebt:
          (json['ПросроченныйДолг'] ?? json['OverdueDebt'] ?? 0).toDouble(),
      totalDebt: (json['ОбщийДолг'] ?? json['TotalDebt'] ?? 0).toDouble(),
      lastPaymentDate: json['ДатаПоследнейОплаты'] != null
          ? DateTime.parse(json['ДатаПоследнейОплаты'])
          : json['LastPaymentDate'] != null
              ? DateTime.parse(json['LastPaymentDate'])
              : null,
      lastPaymentAmount:
          (json['СуммаПоследнейОплаты'] ?? json['LastPaymentAmount'] ?? 0)
              .toDouble(),
      lastOrderDate: json['ДатаПоследнегоЗаказа'] != null
          ? DateTime.parse(json['ДатаПоследнегоЗаказа'])
          : json['LastOrderDate'] != null
              ? DateTime.parse(json['LastOrderDate'])
              : null,
      lastOrderAmount:
          (json['СуммаПоследнегоЗаказа'] ?? json['LastOrderAmount'] ?? 0)
              .toDouble(),

      // Statistics
      totalOrders: json['КоличествоЗаказов'] ?? json['TotalOrders'] ?? 0,
      totalSales: (json['ОбъемПродаж'] ?? json['TotalSales'] ?? 0).toDouble(),
      ordersThisMonth: json['ЗаказыЗаМесяц'] ?? json['OrdersThisMonth'] ?? 0,
      salesThisMonth:
          (json['ПродажиЗаМесяц'] ?? json['SalesThisMonth'] ?? 0).toDouble(),
      ordersThisYear: json['ЗаказыЗаГод'] ?? json['OrdersThisYear'] ?? 0,
      salesThisYear:
          (json['ПродажиЗаГод'] ?? json['SalesThisYear'] ?? 0).toDouble(),
      averageOrderAmount:
          (json['СреднийЧек'] ?? json['AverageOrderAmount'] ?? 0).toDouble(),

      // Visits
      totalVisits: json['КоличествоПосещений'] ?? json['TotalVisits'] ?? 0,
      lastVisitDate: json['ДатаПоследнегоПосещения'] != null
          ? DateTime.parse(json['ДатаПоследнегоПосещения'])
          : json['LastVisitDate'] != null
              ? DateTime.parse(json['LastVisitDate'])
              : null,
      visitFrequency: json['ЧастотаПосещений'] ?? json['VisitFrequency'] ?? 7,
      preferredVisitDay:
          json['ПредпочтительныйДень'] ?? json['PreferredVisitDay'],
      preferredVisitTime:
          json['ПредпочтительноеВремя'] ?? json['PreferredVisitTime'],

      // Attributes
      customerType:
          json['ТипКонтрагента'] ?? json['CustomerType'] ?? 'corporate',
      isVIP: json['VIPКлиент'] ?? json['IsVIP'] ?? false,
      loyaltyCardNumber:
          json['НомерКартыЛояльности'] ?? json['LoyaltyCardNumber'],
      notes: json['Комментарий'] ?? json['Notes'],
      internalNotes: json['ВнутреннийКомментарий'] ?? json['InternalNotes'],
      tags: (json['Теги'] as List?)?.cast<String>() ??
          (json['Tags'] as List?)?.cast<String>() ??
          [],

      // Status
      isActive: !(json['ПометкаУдаления'] ?? json['DeletionMark'] ?? false),
      isBlocked: json['Заблокирован'] ?? json['IsBlocked'] ?? false,
      blockReason: json['ПричинаБлокировки'] ?? json['BlockReason'],
      blockedDate: json['ДатаБлокировки'] != null
          ? DateTime.parse(json['ДатаБлокировки'])
          : null,
      blockedBy: json['КемЗаблокирован'] ?? json['BlockedBy'],

      // Dates
      createdAt: json['ДатаСоздания'] != null
          ? DateTime.parse(json['ДатаСоздания'])
          : json['CreatedAt'] != null
              ? DateTime.parse(json['CreatedAt'])
              : DateTime.now(),
      updatedAt: json['ДатаИзменения'] != null
          ? DateTime.parse(json['ДатаИзменения'])
          : json['UpdatedAt'] != null
              ? DateTime.parse(json['UpdatedAt'])
              : null,
      createdBy: json['КемСоздан'] ?? json['CreatedBy'],
    );
  }
}

/// 1C Mijoz aloqa ma'lumotlari (КонтактнаяИнформация)
class OneCContactInfo {
  final String refKey;
  final String counterpartyKey;
  final String type; // Телефон, Адрес, Email
  final String typeName;
  final String value; // Qiymat
  final String? description; // Tavsif
  final bool isPrimary; // Asosiy

  const OneCContactInfo({
    required this.refKey,
    required this.counterpartyKey,
    required this.type,
    required this.typeName,
    required this.value,
    this.description,
    required this.isPrimary,
  });

  factory OneCContactInfo.fromJson(Map<String, dynamic> json) {
    return OneCContactInfo(
      refKey: json['Ref_Key'] ?? '',
      counterpartyKey: json['Объект_Key'] ?? json['Counterparty_Key'] ?? '',
      type: json['Тип'] ?? json['Type'] ?? '',
      typeName: json['Вид'] ?? json['TypeName'] ?? '',
      value: json['Представление'] ?? json['Value'] ?? '',
      description: json['Комментарий'] ?? json['Description'],
      isPrimary: json['ЗначениеПоУмолчанию'] ?? json['IsPrimary'] ?? false,
    );
  }
}
