// ============================================================
// 1C:ENTERPRISE - AGENT (ОТВЕТСТВЕННЫЙ/ПОЛЬЗОВАТЕЛЬ) MODELS
// Haqiqiy 1C konfiguratsiyaga mos
// ============================================================

/// 1C Agent (Ответственный) - to'liq tuzilma
///
/// 1C da agentlar "Справочник.Пользователи" yoki
/// maxsus "Справочник.Сотрудники" da saqlanadi
class OneCAgent {
  final String refKey; // УникальныйИдентификатор (GUID)
  final String code; // Код (AG001, AG002)
  final String description; // Наименование (ism familiya)
  final String fullName; // ПолноеНаименование

  // ============ ШАХСИЙ МАЪЛУМОТЛАР ============
  final String firstName; // Имя
  final String lastName; // Фамилия
  final String? middleName; // Отчество
  final String? nickname; // Псевдоним
  final DateTime? birthDate; // ДатаРождения
  final String? gender; // Пол (Мужской, Женский)
  final String? inn; // ИНН (STIR)
  final String? passportNumber; // НомерПаспорта
  final String? passportSeries; // СерияПаспорта

  // ============ АЛОКА (КОНТАКТЫ) ============
  final String phone; // ТелефонОсновной
  final String? phone2; // ТелефонДополнительный
  final String? mobilePhone; // МобильныйТелефон
  final String? email; // ЭлектроннаяПочта
  final String? address; // АдресПроживания
  final String? emergencyContact; // ЭкстренныйКонтакт
  final String? emergencyPhone; // ЭкстренныйТелефон

  // ============ ИШ (РАБОТА) ============
  final String positionKey; // Должность_Key
  final String positionName; // Должность наименование
  final String departmentKey; // Подразделение_Key
  final String departmentName; // Подразделение наименование
  final String role; // Роль (Agent, Supervisor, Admin, Driver)
  final String roleName; // Роль наименование
  final DateTime hireDate; // ДатаПриемаНаРаботу
  final DateTime? fireDate; // ДатаУвольнения
  final String employeeNumber; // ТабельныйНомер

  // ============ ХУДУД (ТЕРРИТОРИЯ) ============
  final String regionKey; // Территория_Key
  final String regionName; // Территория наименование
  final String? districtKey; // Район_Key
  final String? districtName; // Район наименование
  final List<String> assignedRegions; // ЗакрепленныеТерритории

  // ============ СКЛАД (ОМБОР) ============
  final String warehouseKey; // Склад_Key
  final String warehouseName; // Склад наименование
  final String? warehouseCode; // Склад код

  // ============ СУПЕРВАЙЗЕР ============
  final String? supervisorKey; // Руководитель_Key
  final String? supervisorName; // Руководитель наименование
  final String? supervisorCode; // Руководитель код

  // ============ НАРХ ГУРУХИ ============
  final String? defaultPriceGroupKey; // ЦеноваяГруппаПоУмолчанию
  final String? defaultPriceGroupName;

  // ============ ИШ ВАҚТИ (РАСПИСАНИЕ) ============
  final String workStartTime; // ВремяНачалаРаботы (08:00)
  final String workEndTime; // ВремяОкончанияРаботы (18:00)
  final List<String> workDays; // РабочиеДни (monday, tuesday, ...)
  final int maxWorkHoursPerDay; // МаксимальныеЧасыВДень
  final int maxWorkHoursPerWeek; // МаксимальныеЧасыВНеделю
  final int breakDurationMinutes; // ПродолжительностьПерерыва

  // ============ BUYURTMA CHEKLOVLARI ============
  final String orderStartTime; // ВремяНачалаЗаказов
  final String orderEndTime; // ВремяОкончанияЗаказов
  final int maxOrdersPerDay; // МаксимумЗаказовВДень
  final int maxOrdersPerWeek; // МаксимумЗаказовВНеделю
  final double maxOrderAmount; // МаксимальнаяСуммаЗаказа
  final double maxDailyOrderAmount; // МаксимальнаяСуммаВДень
  final double maxDiscountPercent; // МаксимальныйПроцентСкидки
  final double maxDiscountAmount; // МаксимальнаяСуммаСкидки
  final bool canOrderOutsideWorkHours; // ЗаказВнеРабочегоВремени
  final bool canOrderOnWeekends; // ЗаказВВыходные

  // ============ ТАШРИФ CHEKLOVLARI ============
  final int maxVisitsPerDay; // МаксимумПосещенийВДень
  final int minVisitDurationMinutes; // МинимальнаяПродолжительностьВизита
  final double maxTravelDistance; // МаксимальнаяДальностьПоездки
  final bool requireCheckInPhoto; // ТребоватьФотоПриВходе
  final bool requireCheckOutPhoto; // ТребоватьФотоПриВыходе
  final double checkInRadius; // РадиусПроверки (metr)

  // ============ ТУЛОВ CHEKLOVLARI ============
  final double maxCashCollection; // МаксимальныйСборНаличных
  final double maxSinglePayment; // МаксимальныйЕдиноразовыйПлатеж
  final bool requirePaymentProof; // ТребоватьПодтверждениеОлатежа
  final bool requireSignature; // ТребоватьПодпись

  // ============ KPI ============
  final double monthlySalesTarget; // МесячныйПланПродаж
  final double monthlySalesFact; // МесячныйФактПродаж
  final double salesProgress; // ПроцентВыполненияПлана
  final int monthlyVisitPlan; // МесячныйПланПосещений
  final int monthlyVisitFact; // МесячныйФактПосещений
  final double monthlyCollectionPlan; // МесячныйПланСбора
  final double monthlyCollectionFact; // МесячныйФактСбора
  final double rating; // Рейтинг (1-5)

  // ============ СТАТИСТИКА ============
  final int totalOrders; // ОбщееКоличествоЗаказов
  final double totalSales; // ОбщийОбъемПродаж
  final int totalVisits; // ОбщееКоличествоПосещений
  final int totalCustomers; // ОбщееКоличествоКлиентов
  final double totalCollections; // ОбщийСбор
  final DateTime? lastOrderDate; // ДатаПоследнегоЗаказа
  final DateTime? lastVisitDate; // ДатаПоследнегоПосещения
  final DateTime? lastLoginDate; // ДатаПоследнегоВхода
  final DateTime? lastSyncDate; // ДатаПоследнейСинхронизации

  // ============ ТАШҚИЛОТ ============
  final String? organizationKey; // Организация_Key
  final String? organizationName; // Организация наименование
  final String? companyKey; // Компания_Key
  final String? companyName; // Компания наименование

  // ============ ХОЛАТ ============
  final bool isActive; // Активный
  final bool isBlocked; // Заблокирован
  final String? blockReason; // ПричинаБлокировки
  final bool isOnline; // Онлайн
  final String
      currentStatus; // ТекущийСтатус (online, offline, on_route, visiting, break)
  final double? currentLatitude; // ТекущаяШирота
  final double? currentLongitude; // ТекущаяДолгота
  final String? currentAddress; // ТекущийАдрес
  final DateTime? lastLocationUpdate; // ДатаПоследнегоОбновленияГеолокации

  // ============ ВАКТ ============
  final DateTime createdAt; // ДатаСоздания
  final DateTime? updatedAt; // ДатаИзменения
  final String? createdBy; // КемСоздан

  const OneCAgent({
    required this.refKey,
    required this.code,
    required this.description,
    required this.fullName,
    required this.firstName,
    required this.lastName,
    this.middleName,
    this.nickname,
    this.birthDate,
    this.gender,
    this.inn,
    this.passportNumber,
    this.passportSeries,
    required this.phone,
    this.phone2,
    this.mobilePhone,
    this.email,
    this.address,
    this.emergencyContact,
    this.emergencyPhone,
    required this.positionKey,
    required this.positionName,
    required this.departmentKey,
    required this.departmentName,
    required this.role,
    required this.roleName,
    required this.hireDate,
    this.fireDate,
    required this.employeeNumber,
    required this.regionKey,
    required this.regionName,
    this.districtKey,
    this.districtName,
    required this.assignedRegions,
    required this.warehouseKey,
    required this.warehouseName,
    this.warehouseCode,
    this.supervisorKey,
    this.supervisorName,
    this.supervisorCode,
    this.defaultPriceGroupKey,
    this.defaultPriceGroupName,
    required this.workStartTime,
    required this.workEndTime,
    required this.workDays,
    required this.maxWorkHoursPerDay,
    required this.maxWorkHoursPerWeek,
    required this.breakDurationMinutes,
    required this.orderStartTime,
    required this.orderEndTime,
    required this.maxOrdersPerDay,
    required this.maxOrdersPerWeek,
    required this.maxOrderAmount,
    required this.maxDailyOrderAmount,
    required this.maxDiscountPercent,
    required this.maxDiscountAmount,
    required this.canOrderOutsideWorkHours,
    required this.canOrderOnWeekends,
    required this.maxVisitsPerDay,
    required this.minVisitDurationMinutes,
    required this.maxTravelDistance,
    required this.requireCheckInPhoto,
    required this.requireCheckOutPhoto,
    required this.checkInRadius,
    required this.maxCashCollection,
    required this.maxSinglePayment,
    required this.requirePaymentProof,
    required this.requireSignature,
    required this.monthlySalesTarget,
    required this.monthlySalesFact,
    required this.salesProgress,
    required this.monthlyVisitPlan,
    required this.monthlyVisitFact,
    required this.monthlyCollectionPlan,
    required this.monthlyCollectionFact,
    required this.rating,
    required this.totalOrders,
    required this.totalSales,
    required this.totalVisits,
    required this.totalCustomers,
    required this.totalCollections,
    this.lastOrderDate,
    this.lastVisitDate,
    this.lastLoginDate,
    this.lastSyncDate,
    this.organizationKey,
    this.organizationName,
    this.companyKey,
    this.companyName,
    required this.isActive,
    required this.isBlocked,
    this.blockReason,
    required this.isOnline,
    required this.currentStatus,
    this.currentLatitude,
    this.currentLongitude,
    this.currentAddress,
    this.lastLocationUpdate,
    required this.createdAt,
    this.updatedAt,
    this.createdBy,
  });

  String get fullNameDisplay =>
      '$lastName $firstName${middleName != null ? ' $middleName' : ''}';
  bool get canWork => isActive && !isBlocked;
  bool get isAgent => role == 'Agent';
  bool get isSupervisor => role == 'Supervisor';
  bool get isAdmin => role == 'Admin';
  bool get isDriver => role == 'Driver';

  /// 1C JSON dan yaratish
  factory OneCAgent.fromJson(Map<String, dynamic> json) {
    return OneCAgent(
      refKey: json['Ref_Key'] ?? '',
      code: json['Code'] ?? '',
      description: json['Description'] ?? '',
      fullName: json['НаименованиеПолное'] ??
          json['FullName'] ??
          json['Description'] ??
          '',
      firstName: json['Имя'] ?? json['FirstName'] ?? '',
      lastName: json['Фамилия'] ?? json['LastName'] ?? '',
      middleName: json['Отчество'] ?? json['MiddleName'],
      nickname: json['Псевдоним'] ?? json['Nickname'],
      birthDate: json['ДатаРождения'] != null
          ? DateTime.parse(json['ДатаРождения'])
          : null,
      gender: json['Пол'] ?? json['Gender'],
      inn: json['ИНН'] ?? json['INN'],
      passportNumber: json['НомерПаспорта'] ?? json['PassportNumber'],
      passportSeries: json['СерияПаспорта'] ?? json['PassportSeries'],
      phone: json['ТелефонОсновной'] ?? json['Phone'] ?? '',
      phone2: json['ТелефонДополнительный'] ?? json['Phone2'],
      mobilePhone: json['МобильныйТелефон'] ?? json['MobilePhone'],
      email: json['ЭлектроннаяПочта'] ?? json['Email'],
      address: json['АдресПроживания'] ?? json['Address'],
      emergencyContact: json['ЭкстренныйКонтакт'] ?? json['EmergencyContact'],
      emergencyPhone: json['ЭкстренныйТелефон'] ?? json['EmergencyPhone'],
      positionKey: json['Должность_Key'] ?? json['Position_Key'] ?? '',
      positionName:
          json['Должность_Description'] ?? json['Position_Description'] ?? '',
      departmentKey: json['Подразделение_Key'] ?? json['Department_Key'] ?? '',
      departmentName: json['Подразделение_Description'] ??
          json['Department_Description'] ??
          '',
      role: json['Роль'] ?? json['Role'] ?? 'Agent',
      roleName: json['Роль_Наименование'] ?? json['RoleName'] ?? '',
      hireDate: json['ДатаПриемаНаРаботу'] != null
          ? DateTime.parse(json['ДатаПриемаНаРаботу'])
          : json['HireDate'] != null
              ? DateTime.parse(json['HireDate'])
              : DateTime.now(),
      fireDate: json['ДатаУвольнения'] != null
          ? DateTime.parse(json['ДатаУвольнения'])
          : null,
      employeeNumber: json['ТабельныйНомер'] ?? json['EmployeeNumber'] ?? '',
      regionKey: json['Территория_Key'] ?? json['Region_Key'] ?? '',
      regionName:
          json['Территория_Description'] ?? json['Region_Description'] ?? '',
      districtKey: json['Район_Key'] ?? json['District_Key'],
      districtName: json['Район_Description'] ?? json['District_Description'],
      assignedRegions:
          (json['ЗакрепленныеТерритории'] as List?)?.cast<String>() ??
              (json['AssignedRegions'] as List?)?.cast<String>() ??
              [],
      warehouseKey: json['Склад_Key'] ?? json['Warehouse_Key'] ?? '',
      warehouseName:
          json['Склад_Description'] ?? json['Warehouse_Description'] ?? '',
      warehouseCode: json['Склад_Code'] ?? json['Warehouse_Code'],
      supervisorKey: json['Руководитель_Key'] ?? json['Supervisor_Key'],
      supervisorName:
          json['Руководитель_Description'] ?? json['Supervisor_Description'],
      supervisorCode: json['Руководитель_Code'] ?? json['Supervisor_Code'],
      defaultPriceGroupKey:
          json['ЦеноваяГруппаПоУмолчанию_Key'] ?? json['DefaultPriceGroup_Key'],
      defaultPriceGroupName: json['ЦеноваяГруппаПоУмолчанию_Description'] ??
          json['DefaultPriceGroup_Description'],
      workStartTime:
          json['ВремяНачалаРаботы'] ?? json['WorkStartTime'] ?? '08:00',
      workEndTime:
          json['ВремяОкончанияРаботы'] ?? json['WorkEndTime'] ?? '18:00',
      workDays: (json['РабочиеДни'] as List?)?.cast<String>() ??
          (json['WorkDays'] as List?)?.cast<String>() ??
          ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday'],
      maxWorkHoursPerDay:
          json['МаксимальныеЧасыВДень'] ?? json['MaxWorkHoursPerDay'] ?? 8,
      maxWorkHoursPerWeek:
          json['МаксимальныеЧасыВНеделю'] ?? json['MaxWorkHoursPerWeek'] ?? 48,
      breakDurationMinutes: json['ПродолжительностьПерерыва'] ??
          json['BreakDurationMinutes'] ??
          60,
      orderStartTime:
          json['ВремяНачалаЗаказов'] ?? json['OrderStartTime'] ?? '08:00',
      orderEndTime:
          json['ВремяОкончанияЗаказов'] ?? json['OrderEndTime'] ?? '17:00',
      maxOrdersPerDay:
          json['МаксимумЗаказовВДень'] ?? json['MaxOrdersPerDay'] ?? 20,
      maxOrdersPerWeek:
          json['МаксимумЗаказовВНеделю'] ?? json['MaxOrdersPerWeek'] ?? 100,
      maxOrderAmount: (json['МаксимальнаяСуммаЗаказа'] ??
              json['MaxOrderAmount'] ??
              50000000)
          .toDouble(),
      maxDailyOrderAmount: (json['МаксимальнаяСуммаВДень'] ??
              json['MaxDailyOrderAmount'] ??
              200000000)
          .toDouble(),
      maxDiscountPercent: (json['МаксимальныйПроцентСкидки'] ??
              json['MaxDiscountPercent'] ??
              10)
          .toDouble(),
      maxDiscountAmount: (json['МаксимальнаяСуммаСкидки'] ??
              json['MaxDiscountAmount'] ??
              5000000)
          .toDouble(),
      canOrderOutsideWorkHours: json['ЗаказВнеРабочегоВремени'] ??
          json['CanOrderOutsideWorkHours'] ??
          false,
      canOrderOnWeekends:
          json['ЗаказВВыходные'] ?? json['CanOrderOnWeekends'] ?? false,
      maxVisitsPerDay:
          json['МаксимумПосещенийВДень'] ?? json['MaxVisitsPerDay'] ?? 15,
      minVisitDurationMinutes: json['МинимальнаяПродолжительностьВизита'] ??
          json['MinVisitDurationMinutes'] ??
          15,
      maxTravelDistance: (json['МаксимальнаяДальностьПоездки'] ??
              json['MaxTravelDistance'] ??
              50)
          .toDouble(),
      requireCheckInPhoto:
          json['ТребоватьФотоПриВходе'] ?? json['RequireCheckInPhoto'] ?? true,
      requireCheckOutPhoto: json['ТребоватьФотоПриВыходе'] ??
          json['RequireCheckOutPhoto'] ??
          false,
      checkInRadius:
          (json['РадиусПроверки'] ?? json['CheckInRadius'] ?? 100).toDouble(),
      maxCashCollection: (json['МаксимальныйСборНаличных'] ??
              json['MaxCashCollection'] ??
              100000000)
          .toDouble(),
      maxSinglePayment: (json['МаксимальныйЕдиноразовыйПлатеж'] ??
              json['MaxSinglePayment'] ??
              50000000)
          .toDouble(),
      requirePaymentProof: json['ТребоватьПодтверждениеОплаты'] ??
          json['RequirePaymentProof'] ??
          true,
      requireSignature:
          json['ТребоватьПодпись'] ?? json['RequireSignature'] ?? true,
      monthlySalesTarget:
          (json['МесячныйПланПродаж'] ?? json['MonthlySalesTarget'] ?? 0)
              .toDouble(),
      monthlySalesFact:
          (json['МесячныйФактПродаж'] ?? json['MonthlySalesFact'] ?? 0)
              .toDouble(),
      salesProgress:
          (json['ПроцентВыполненияПлана'] ?? json['SalesProgress'] ?? 0)
              .toDouble(),
      monthlyVisitPlan:
          json['МесячныйПланПосещений'] ?? json['MonthlyVisitPlan'] ?? 0,
      monthlyVisitFact:
          json['МесячныйФактПосещений'] ?? json['MonthlyVisitFact'] ?? 0,
      monthlyCollectionPlan:
          (json['МесячныйПланСбора'] ?? json['MonthlyCollectionPlan'] ?? 0)
              .toDouble(),
      monthlyCollectionFact:
          (json['МесячныйФактСбора'] ?? json['MonthlyCollectionFact'] ?? 0)
              .toDouble(),
      rating: (json['Рейтинг'] ?? json['Rating'] ?? 0).toDouble(),
      totalOrders: json['ОбщееКоличествоЗаказов'] ?? json['TotalOrders'] ?? 0,
      totalSales:
          (json['ОбщийОбъемПродаж'] ?? json['TotalSales'] ?? 0).toDouble(),
      totalVisits: json['ОбщееКоличествоПосещений'] ?? json['TotalVisits'] ?? 0,
      totalCustomers:
          json['ОбщееКоличествоКлиентов'] ?? json['TotalCustomers'] ?? 0,
      totalCollections:
          (json['ОбщийСбор'] ?? json['TotalCollections'] ?? 0).toDouble(),
      lastOrderDate: json['ДатаПоследнегоЗаказа'] != null
          ? DateTime.parse(json['ДатаПоследнегоЗаказа'])
          : null,
      lastVisitDate: json['ДатаПоследнегоПосещения'] != null
          ? DateTime.parse(json['ДатаПоследнегоПосещения'])
          : null,
      lastLoginDate: json['ДатаПоследнегоВхода'] != null
          ? DateTime.parse(json['ДатаПоследнегоВхода'])
          : null,
      lastSyncDate: json['ДатаПоследнейСинхронизации'] != null
          ? DateTime.parse(json['ДатаПоследнейСинхронизации'])
          : null,
      organizationKey: json['Организация_Key'] ?? json['Organization_Key'],
      organizationName:
          json['Организация_Description'] ?? json['Organization_Description'],
      companyKey: json['Компания_Key'] ?? json['Company_Key'],
      companyName: json['Компания_Description'] ?? json['Company_Description'],
      isActive: !(json['ПометкаУдаления'] ?? json['DeletionMark'] ?? false),
      isBlocked: json['Заблокирован'] ?? json['IsBlocked'] ?? false,
      blockReason: json['ПричинаБлокировки'] ?? json['BlockReason'],
      isOnline: json['Онлайн'] ?? json['IsOnline'] ?? false,
      currentStatus:
          json['ТекущийСтатус'] ?? json['CurrentStatus'] ?? 'offline',
      currentLatitude: json['ТекущаяШирота']?.toDouble() ??
          json['CurrentLatitude']?.toDouble(),
      currentLongitude: json['ТекущаяДолгота']?.toDouble() ??
          json['CurrentLongitude']?.toDouble(),
      currentAddress: json['ТекущийАдрес'] ?? json['CurrentAddress'],
      lastLocationUpdate: json['ДатаПоследнегоОбновленияГеолокации'] != null
          ? DateTime.parse(json['ДатаПоследнегоОбновленияГеолокации'])
          : null,
      createdAt: json['ДатаСоздания'] != null
          ? DateTime.parse(json['ДатаСоздания'])
          : json['CreatedAt'] != null
              ? DateTime.parse(json['CreatedAt'])
              : DateTime.now(),
      updatedAt: json['ДатаИзменения'] != null
          ? DateTime.parse(json['ДатаИзменения'])
          : null,
      createdBy: json['КемСоздан'] ?? json['CreatedBy'],
    );
  }
}
