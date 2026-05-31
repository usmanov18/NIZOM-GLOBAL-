import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/customer_sync_entities.dart';
import 'package:equatable/equatable.dart';

// ============================================================
// CUSTOMER SEGMENTATION SERVICE - Professional Segmentatsiya
// ============================================================

class CustomerSegmentationService {
  // ============ SEGMENT TYPES ============

  static const String segmentVIP = 'vip';
  static const String segmentActive = 'active';
  static const String segmentNew = 'new';
  static const String segmentInactive = 'inactive';
  static const String segmentDebtor = 'debtor';
  static const String segmentAtRisk = 'at_risk';
  static const String segmentPotential = 'potential';

  // ============ SCORING WEIGHTS ============

  static const double weightSales = 0.35;
  static const double weightFrequency = 0.25;
  static const double weightRecency = 0.20;
  static const double weightLoyalty = 0.20;

  // ============ SEGMENTATION ============

  /// Mijozlarni segmentlarga ajratish
  Future<Either<Failure, List<SegmentedCustomer>>> segmentCustomers({
    required List<SyncedCustomer> customers,
  }) async {
    try {
      final segmented = customers.map((customer) {
        final score = _calculateScore(customer);
        final segment = _determineSegment(customer, score);
        final strategy = _getStrategy(segment);

        return SegmentedCustomer(
          customer: customer,
          score: score,
          segment: segment,
          strategy: strategy,
          segmentedAt: DateTime.now(),
        );
      }).toList();

      // Score bo'yicha saralash
      segmented
          .sort((a, b) => b.score.totalScore.compareTo(a.score.totalScore));

      return Right(segmented);
    } catch (e) {
      return Left(ServerFailure(message: 'Segmentatsiya xatoligi: $e'));
    }
  }

  // ============ SCORING ============

  /// Mijoz scoring hisoblash
  CustomerScore _calculateScore(SyncedCustomer customer) {
    // Sotuv balli (0-100)
    final salesScore = _calculateSalesScore(customer.totalSales);

    // Sadolik balli (0-100)
    final frequencyScore = _calculateFrequencyScore(customer.totalOrders);

    // Faollik balli (0-100)
    final recencyScore = _calculateRecencyScore(customer.lastOrderDate);

    // Sadoqat balli (0-100)
    final loyaltyScore = _calculateLoyaltyScore(customer);

    // Umumiy ball
    final totalScore = (salesScore * weightSales) +
        (frequencyScore * weightFrequency) +
        (recencyScore * weightRecency) +
        (loyaltyScore * weightLoyalty);

    return CustomerScore(
      salesScore: salesScore,
      frequencyScore: frequencyScore,
      recencyScore: recencyScore,
      loyaltyScore: loyaltyScore,
      totalScore: totalScore,
      grade: _getGrade(totalScore),
    );
  }

  /// Sotuv balli
  double _calculateSalesScore(double totalSales) {
    if (totalSales >= 100000000) return 100; // 100M+
    if (totalSales >= 50000000) return 85; // 50M+
    if (totalSales >= 20000000) return 70; // 20M+
    if (totalSales >= 10000000) return 55; // 10M+
    if (totalSales >= 5000000) return 40; // 5M+
    if (totalSales >= 1000000) return 25; // 1M+
    return 10;
  }

  /// Sadolik balli
  double _calculateFrequencyScore(int totalOrders) {
    if (totalOrders >= 50) return 100;
    if (totalOrders >= 30) return 85;
    if (totalOrders >= 20) return 70;
    if (totalOrders >= 10) return 55;
    if (totalOrders >= 5) return 40;
    if (totalOrders >= 1) return 25;
    return 0;
  }

  /// Faollik balli
  double _calculateRecencyScore(DateTime? lastOrderDate) {
    if (lastOrderDate == null) return 0;

    final daysSince = DateTime.now().difference(lastOrderDate).inDays;

    if (daysSince <= 3) return 100; // Bugun/kecha
    if (daysSince <= 7) return 90; // Bu hafta
    if (daysSince <= 14) return 75; // 2 hafta
    if (daysSince <= 30) return 60; // Bu oy
    if (daysSince <= 60) return 40; // 2 oy
    if (daysSince <= 90) return 20; // 3 oy
    return 5; // 3 oydan ko'p
  }

  /// Sadoqat balli
  double _calculateLoyaltyScore(SyncedCustomer customer) {
    double score = 0;

    // VIP bo'lsa
    if (customer.isVIP) score += 30;

    // Qarzdorlik bo'lmasa
    if (!customer.hasDebt) score += 20;

    // Muntazam tashriflar
    if (customer.visitFrequency <= 7) {
      score += 25; // Haftada 1 marta
    } else if (customer.visitFrequency <= 14)
      score += 15;
    else if (customer.visitFrequency <= 30) score += 10;

    // Oxirgi 3 oyda faol
    if (customer.lastOrderDate != null) {
      final daysSince =
          DateTime.now().difference(customer.lastOrderDate!).inDays;
      if (daysSince <= 90) score += 25;
    }

    return score.clamp(0, 100);
  }

  /// Daraja aniqlash
  String _getGrade(double score) {
    if (score >= 80) return 'A';
    if (score >= 60) return 'B';
    if (score >= 40) return 'C';
    if (score >= 20) return 'D';
    return 'E';
  }

  // ============ SEGMENT DETERMINATION ============

  /// Segment aniqlash
  String _determineSegment(SyncedCustomer customer, CustomerScore score) {
    // VIP
    if (customer.isVIP ||
        (score.totalScore >= 80 && customer.totalSales >= 100000000)) {
      return segmentVIP;
    }

    // Qarzdor
    if (customer.hasDebt && customer.currentDebt > 5000000) {
      return segmentDebtor;
    }

    // Yo'qotish xavfi
    if (customer.lastOrderDate != null) {
      final daysSince =
          DateTime.now().difference(customer.lastOrderDate!).inDays;
      if (daysSince > 30 && daysSince <= 60 && customer.totalOrders >= 5) {
        return segmentAtRisk;
      }
    }

    // Yangi
    if (customer.lastOrderDate != null) {
      final daysSince =
          DateTime.now().difference(customer.lastOrderDate!).inDays;
      if (daysSince <= 30 && customer.totalOrders <= 3) {
        return segmentNew;
      }
    }

    // Nofaol
    if (customer.lastOrderDate != null) {
      final daysSince =
          DateTime.now().difference(customer.lastOrderDate!).inDays;
      if (daysSince > 60) {
        return segmentInactive;
      }
    }

    // Faol
    if (score.totalScore >= 40) {
      return segmentActive;
    }

    // Potensial
    return segmentPotential;
  }

  // ============ STRATEGY ============

  /// Segment strategiya
  SegmentStrategy _getStrategy(String segment) {
    switch (segment) {
      case segmentVIP:
        return const SegmentStrategy(
          segment: segmentVIP,
          name: 'VIP Mijoz',
          description: 'Yuqori sotuvli sodiq mijozlar',
          priority: 1,
          actions: [
            'Shaxsiy menejer biriktirish',
            'Maxsus chegirmalar (20%+)',
            'Birinchi navbatda xizmat',
            'Yangi mahsulotlar taqdimoti',
            'Haftalik tashrif',
          ],
          discountPercent: 20,
          visitFrequencyDays: 3,
          alertOnInactiveDays: 3,
        );

      case segmentActive:
        return const SegmentStrategy(
          segment: segmentActive,
          name: 'Faol Mijoz',
          description: 'Muntazam buyurtma beruvchi',
          priority: 2,
          actions: [
            'Sodiq mijoz dasturi',
            'Cross-sell tavsiyalar',
            'Haftalik tashrif',
            'Yangi mahsulotlar',
          ],
          discountPercent: 10,
          visitFrequencyDays: 7,
          alertOnInactiveDays: 14,
        );

      case segmentNew:
        return const SegmentStrategy(
          segment: segmentNew,
          name: 'Yangi Mijoz',
          description: 'Yaqinda boshlagan',
          priority: 3,
          actions: [
            'Xush kelibsiz bonusi',
            'Birinchi buyurtma chegirmasi',
            'Mahsulotlar katalogi',
            'Tez-tez tashrif',
          ],
          discountPercent: 5,
          visitFrequencyDays: 5,
          alertOnInactiveDays: 14,
        );

      case segmentInactive:
        return const SegmentStrategy(
          segment: segmentInactive,
          name: 'Nofaol Mijoz',
          description: '60+ kun buyurtma yo\'q',
          priority: 4,
          actions: [
            'Qayta faollashtirish aksiyasi',
            'Maxsus taklif',
            'Telefon qo\'ng\'irog\'i',
            'SMS eslatma',
          ],
          discountPercent: 15,
          visitFrequencyDays: 30,
          alertOnInactiveDays: 7,
        );

      case segmentDebtor:
        return const SegmentStrategy(
          segment: segmentDebtor,
          name: 'Qarzdor Mijoz',
          description: 'Qarzdorlik mavjud',
          priority: 5,
          actions: [
            'To\'lov eslatmasi',
            'To\'lov rejalashtirish',
            'Yangi buyurtma cheklash',
            'Menejer aralashuvi',
          ],
          discountPercent: 0,
          visitFrequencyDays: 7,
          alertOnInactiveDays: 3,
        );

      case segmentAtRisk:
        return const SegmentStrategy(
          segment: segmentAtRisk,
          name: 'Yo\'qotish Xavfi',
          description: 'Kamayish tendensiyasi',
          priority: 6,
          actions: [
            'Saqlab qolish aksiyasi',
            'Maxsus taklif',
            'Shaxsiy murojaat',
            'Sababini aniqlash',
          ],
          discountPercent: 12,
          visitFrequencyDays: 5,
          alertOnInactiveDays: 3,
        );

      default: // potential
        return const SegmentStrategy(
          segment: segmentPotential,
          name: 'Potensial Mijoz',
          description: 'Hali faol emas',
          priority: 7,
          actions: [
            'Birinchi buyurtma taklifi',
            'Mahsulotlar taqdimoti',
            'Muntazam tashrif',
          ],
          discountPercent: 10,
          visitFrequencyDays: 14,
          alertOnInactiveDays: 30,
        );
    }
  }

  // ============ ANALYTICS ============

  /// Segmentlar statistikasi
  SegmentStatistics getStatistics(List<SegmentedCustomer> customers) {
    final Map<String, int> counts = {};
    final Map<String, double> sales = {};

    for (final customer in customers) {
      counts[customer.segment] = (counts[customer.segment] ?? 0) + 1;
      sales[customer.segment] =
          (sales[customer.segment] ?? 0) + customer.customer.totalSales;
    }

    return SegmentStatistics(
      totalCustomers: customers.length,
      segmentCounts: counts,
      segmentSales: sales,
      vipCount: counts[segmentVIP] ?? 0,
      activeCount: counts[segmentActive] ?? 0,
      newCount: counts[segmentNew] ?? 0,
      inactiveCount: counts[segmentInactive] ?? 0,
      debtorCount: counts[segmentDebtor] ?? 0,
      atRiskCount: counts[segmentAtRisk] ?? 0,
    );
  }
}

// ============ MODELS ============

/// Segmentatsiyalangan mijoz
class SegmentedCustomer extends Equatable {
  final SyncedCustomer customer;
  final CustomerScore score;
  final String segment;
  final SegmentStrategy strategy;
  final DateTime segmentedAt;

  const SegmentedCustomer({
    required this.customer,
    required this.score,
    required this.segment,
    required this.strategy,
    required this.segmentedAt,
  });

  @override
  List<Object?> get props => [customer.id, segment, score.totalScore];
}

/// Mijoz scoring
class CustomerScore extends Equatable {
  final double salesScore;
  final double frequencyScore;
  final double recencyScore;
  final double loyaltyScore;
  final double totalScore;
  final String grade;

  const CustomerScore({
    required this.salesScore,
    required this.frequencyScore,
    required this.recencyScore,
    required this.loyaltyScore,
    required this.totalScore,
    required this.grade,
  });

  @override
  List<Object?> get props => [totalScore, grade];
}

/// Segment strategiya
class SegmentStrategy extends Equatable {
  final String segment;
  final String name;
  final String description;
  final int priority;
  final List<String> actions;
  final double discountPercent;
  final int visitFrequencyDays;
  final int alertOnInactiveDays;

  const SegmentStrategy({
    required this.segment,
    required this.name,
    required this.description,
    required this.priority,
    required this.actions,
    required this.discountPercent,
    required this.visitFrequencyDays,
    required this.alertOnInactiveDays,
  });

  @override
  List<Object?> get props => [segment, priority];
}

/// Segmentlar statistikasi
class SegmentStatistics extends Equatable {
  final int totalCustomers;
  final Map<String, int> segmentCounts;
  final Map<String, double> segmentSales;
  final int vipCount;
  final int activeCount;
  final int newCount;
  final int inactiveCount;
  final int debtorCount;
  final int atRiskCount;

  const SegmentStatistics({
    required this.totalCustomers,
    required this.segmentCounts,
    required this.segmentSales,
    required this.vipCount,
    required this.activeCount,
    required this.newCount,
    required this.inactiveCount,
    required this.debtorCount,
    required this.atRiskCount,
  });

  @override
  List<Object?> get props => [totalCustomers];
}
