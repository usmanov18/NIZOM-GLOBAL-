import 'package:equatable/equatable.dart';

// ============================================================
// ADMIN ENTITIES - Yuqori boshqaruv
// Global sozlamalar, cheglovlar, tizim boshqaruvi
// ============================================================

// ============ GLOBAL SOZLAMALAR ============

/// Tizim global sozlamalari
class SystemSettings extends Equatable {
  factory SystemSettings.fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError();
  final String id;
  final String companyName;
  final String companyCode;
  final String currency; // UZS
  final String timezone; // Asia/Tashkent
  final String language; // uz, ru

  // Integratsiya
  final bool is1CEnabled;
  final bool isSAPEnabled;
  final String? oneCBaseUrl;
  final String? sapBaseUrl;
  final int syncIntervalMinutes; // 30
  final bool autoSyncEnabled;
  final bool isSystemFrozen; // Kill-switch

  // Bildirishnomalar
  final bool pushNotificationsEnabled;
  final bool smsNotificationsEnabled;
  final bool emailNotificationsEnabled;

  // GPS
  final bool gpsTrackingEnabled;
  final int gpsIntervalSeconds; // 30
  final bool requireGPSForCheckIn;

  // Xavfsizlik
  final int sessionTimeoutMinutes; // 480
  final bool requireBiometric;
  final int maxLoginAttempts; // 5
  final int passwordMinLength; // 8

  const SystemSettings({
    required this.id,
    required this.companyName,
    required this.companyCode,
    required this.currency,
    required this.timezone,
    required this.language,
    required this.is1CEnabled,
    required this.isSAPEnabled,
    this.oneCBaseUrl,
    this.sapBaseUrl,
    required this.syncIntervalMinutes,
    required this.autoSyncEnabled,
    this.isSystemFrozen = false,
    required this.pushNotificationsEnabled,
    required this.smsNotificationsEnabled,
    required this.emailNotificationsEnabled,
    required this.gpsTrackingEnabled,
    required this.gpsIntervalSeconds,
    required this.requireGPSForCheckIn,
    required this.sessionTimeoutMinutes,
    required this.requireBiometric,
    required this.maxLoginAttempts,
    required this.passwordMinLength,
  });

  @override
  List<Object?> get props => [id, companyCode];
}

// ============ AGENT CHEKLOVLARI ============

/// Agent global cheklovlari (admin tomonidan belgilanadi)
class AgentRestrictions extends Equatable {
  factory AgentRestrictions.fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError();
  final String id;
  final String agentId;
  final String agentName;

  // Ish vaqti cheklovlari
  final String workStartTime; // 08:00
  final String workEndTime; // 18:00
  final List<String> workDays;
  final bool canWorkOnWeekends;
  final int maxWorkHoursPerDay;
  final int maxWorkHoursPerWeek;

  // Buyurtma cheklovlari
  final String orderStartTime; // 08:00
  final String orderEndTime; // 17:00
  final bool canOrderOutsideWorkHours;
  final int maxOrdersPerDay;
  final int maxOrdersPerWeek;
  final double maxSingleOrderAmount;
  final double maxDailyOrderAmount;
  final double maxWeeklyOrderAmount;
  final double maxDiscountPercent;
  final double maxDiscountAmount;
  final bool requireManagerApprovalAbove; // Limitdan oshsa tasdiqlash kerak
  final double approvalThresholdAmount;

  // To'lov cheklovlari
  final double maxCashCollection;
  final double maxSinglePayment;
  final bool requireReceiptPhoto;
  final bool requireSignature;
  final List<String> allowedPaymentMethods; // cash, card, transfer

  // Tashrif cheklovlari
  final int maxVisitsPerDay;
  final int minVisitDurationMinutes;
  final double maxTravelDistanceKm;
  final bool requireCheckInPhoto;
  final bool requireCheckOutPhoto;
  final double checkInRadiusMeters; // 100 metr

  // Chegirma cheklovlari
  final List<DiscountRule> discountRules;

  // Sana
  final DateTime effectiveFrom;
  final DateTime? effectiveTo;
  final bool isActive;
  final String createdBy;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const AgentRestrictions({
    required this.id,
    required this.agentId,
    required this.agentName,
    required this.workStartTime,
    required this.workEndTime,
    required this.workDays,
    required this.canWorkOnWeekends,
    required this.maxWorkHoursPerDay,
    required this.maxWorkHoursPerWeek,
    required this.orderStartTime,
    required this.orderEndTime,
    required this.canOrderOutsideWorkHours,
    required this.maxOrdersPerDay,
    required this.maxOrdersPerWeek,
    required this.maxSingleOrderAmount,
    required this.maxDailyOrderAmount,
    required this.maxWeeklyOrderAmount,
    required this.maxDiscountPercent,
    required this.maxDiscountAmount,
    required this.requireManagerApprovalAbove,
    required this.approvalThresholdAmount,
    required this.maxCashCollection,
    required this.maxSinglePayment,
    required this.requireReceiptPhoto,
    required this.requireSignature,
    required this.allowedPaymentMethods,
    required this.maxVisitsPerDay,
    required this.minVisitDurationMinutes,
    required this.maxTravelDistanceKm,
    required this.requireCheckInPhoto,
    required this.requireCheckOutPhoto,
    required this.checkInRadiusMeters,
    required this.discountRules,
    required this.effectiveFrom,
    this.effectiveTo,
    required this.isActive,
    required this.createdBy,
    required this.createdAt,
    this.updatedAt,
  });

  /// Buyurtma vaqtida ekanligini tekshirish
  bool canCreateOrderAt(DateTime dateTime) {
    if (!isActive) return false;

    final dayName = _getDayName(dateTime.weekday);
    if (!workDays.contains(dayName) && !canWorkOnWeekends) return false;

    if (!canOrderOutsideWorkHours) {
      final orderStart = _parseTime(orderStartTime);
      final orderEnd = _parseTime(orderEndTime);
      final current = dateTime.hour * 60 + dateTime.minute;

      if (current < orderStart || current > orderEnd) return false;
    }

    return true;
  }

  /// Buyurtma summasini tekshirish
  bool isOrderAmountAllowed(double amount) {
    return amount <= maxSingleOrderAmount;
  }

  /// Chegirma foizini tekshirish
  bool isDiscountAllowed(double percent) {
    return percent <= maxDiscountPercent;
  }

  /// Tasdiqlash kerakmi?
  bool requiresApproval(double amount) {
    return requireManagerApprovalAbove && amount > approvalThresholdAmount;
  }

  String _getDayName(int weekday) {
    const days = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ];
    return days[weekday - 1];
  }

  int _parseTime(String time) {
    final parts = time.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  @override
  List<Object?> get props => [id, agentId, isActive];
}

// ============ CHEGIRMA QOIDASI ============

/// Chegirma qoidasi
class DiscountRule extends Equatable {
  factory DiscountRule.fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError();
  final String id;
  final String name;
  final String type; // percent, amount, condition
  final double maxValue;
  final String? condition; // order_amount, customer_type, product_category
  final dynamic conditionValue;
  final bool requiresApproval;
  final String? approvalRole; // manager, supervisor

  const DiscountRule({
    required this.id,
    required this.name,
    required this.type,
    required this.maxValue,
    this.condition,
    this.conditionValue,
    required this.requiresApproval,
    this.approvalRole,
  });

  @override
  List<Object?> get props => [id, type, maxValue];
}

// ============ SKIDKA SHARTLARI (ADMIN) ============

/// Global skidka shartlari
class GlobalDiscountPolicy extends Equatable {
  factory GlobalDiscountPolicy.fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError();
  final String id;
  final String name;
  final String description;

  // Qo'llash shartlari
  final List<DiscountTier> tiers; // Bosqichli chegirmalar
  final double maxOverallDiscount; // Umumiy max chegirma
  final bool allowStacking; // Bir nechta chegirma qo'llash
  final int maxStackCount; // Max chegirma soni

  // Mijoz turlari uchun
  final Map<String, double> customerTypeDiscounts; // vip: 20, regular: 10

  // Mavsumiy
  final bool isSeasonal;
  final DateTime? seasonStart;
  final DateTime? seasonEnd;

  // Faollik
  final bool isActive;
  final DateTime effectiveFrom;
  final DateTime? effectiveTo;
  final String createdBy;

  const GlobalDiscountPolicy({
    required this.id,
    required this.name,
    required this.description,
    required this.tiers,
    required this.maxOverallDiscount,
    required this.allowStacking,
    required this.maxStackCount,
    required this.customerTypeDiscounts,
    required this.isSeasonal,
    this.seasonStart,
    this.seasonEnd,
    required this.isActive,
    required this.effectiveFrom,
    this.effectiveTo,
    required this.createdBy,
  });

  /// Mijoz turiga qarab chegirma
  double getDiscountForCustomerType(String type) {
    return customerTypeDiscounts[type] ?? 0;
  }

  /// Summaga qarab bosqichli chegirma
  double getTierDiscount(double amount) {
    for (final tier in tiers.reversed) {
      if (amount >= tier.minAmount) {
        return tier.discountPercent;
      }
    }
    return 0;
  }

  @override
  List<Object?> get props => [id, isActive];
}

/// Chegirma bosqichi
class DiscountTier extends Equatable {
  factory DiscountTier.fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError();
  final double minAmount;
  final double maxAmount;
  final double discountPercent;
  final String description;

  const DiscountTier({
    required this.minAmount,
    required this.maxAmount,
    required this.discountPercent,
    required this.description,
  });

  @override
  List<Object?> get props => [minAmount, discountPercent];
}

// ============ ADMIN DASHBOARD ============

/// Admin dashboard ma'lumotlari
class AdminDashboard extends Equatable {
  factory AdminDashboard.fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError();
  // Umumiy statistika
  final int totalAgents;
  final int activeAgents;
  final int totalSupervisors;
  final int totalCustomers;
  final int activeCustomers;

  // Bugungi
  final int todayOrders;
  final double todaySales;
  final int todayVisits;
  final double todayCollections;

  // Haftalik
  final double weeklySales;
  final int weeklyOrders;
  final double weeklyCollections;

  // Oylik
  final double monthlySales;
  final double monthlyTarget;
  final double monthlyProgress;

  // Tizim holati
  final bool is1CConnected;
  final bool isSAPConnected;
  final DateTime? lastSyncTime;
  final int pendingSyncItems;

  // Ogohlantirishlar
  final int overdueTasks;
  final int overduePayments;
  final int blockedAgents;

  const AdminDashboard({
    required this.totalAgents,
    required this.activeAgents,
    required this.totalSupervisors,
    required this.totalCustomers,
    required this.activeCustomers,
    required this.todayOrders,
    required this.todaySales,
    required this.todayVisits,
    required this.todayCollections,
    required this.weeklySales,
    required this.weeklyOrders,
    required this.weeklyCollections,
    required this.monthlySales,
    required this.monthlyTarget,
    required this.monthlyProgress,
    required this.is1CConnected,
    required this.isSAPConnected,
    this.lastSyncTime,
    required this.pendingSyncItems,
    required this.overdueTasks,
    required this.overduePayments,
    required this.blockedAgents,
  });

  @override
  List<Object?> get props => [todayOrders, todaySales];
}
