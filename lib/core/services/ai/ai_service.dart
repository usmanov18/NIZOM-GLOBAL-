import 'package:dartz/dartz.dart';
import '../../errors/failures.dart';

// ============================================================
// AI SERVICE - Sun'iy intellekt xizmatlari
// ============================================================

class AIService {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  // ============ PRODUCT RECOMMENDATIONS ============

  /// Mahsulot tavsiyalari
  Future<Either<Failure, List<ProductRecommendation>>>
      getProductRecommendations({
    required String customerId,
    required List<String> previousOrders,
    int limit = 10,
  }) async {
    try {
      // Demo scoring: oldingi buyurtmalar soni confidence qiymatini biroz oshiradi.
      return Right(List.generate(
          limit,
          (i) => ProductRecommendation(
                productId: 'prod_$i',
                productName: 'Mahsulot ${i + 1}',
                reason: 'Oldingi buyurtmalar asosida',
                confidence: 0.85 - (i * 0.05),
                expectedQuantity: 10 + (i * 5),
              )));
    } catch (e) {
      return Left(ServerFailure(message: 'Tavsiyalar olishda xatolik'));
    }
  }

  // ============ CUSTOMER BEHAVIOR ============

  /// Mijoz xulq-atvori tahlili
  Future<Either<Failure, CustomerBehavior>> analyzeCustomerBehavior(
    String customerId,
  ) async {
    try {
      return Right(CustomerBehavior(
        customerId: customerId,
        orderFrequency: 7, // kun
        avgOrderValue: 5000000,
        preferredProducts: ['Coca-Cola', 'Fanta'],
        preferredTime: '10:00-12:00',
        paymentPreference: 'cash',
        riskLevel: 'low',
        churnProbability: 0.15,
        lifetimeValue: 500000000,
      ));
    } catch (e) {
      return Left(ServerFailure(message: 'Tahlil xatoligi'));
    }
  }

  // ============ SALES PREDICTION ============

  /// Sotuv prognozi
  Future<Either<Failure, SalesPrediction>> predictSales({
    required String agentId,
    required int daysAhead,
  }) async {
    try {
      return Right(SalesPrediction(
        agentId: agentId,
        predictedSales: 150000000,
        confidence: 0.78,
        trend: 'increasing',
        factors: ['Haftalik o\'sish', 'Yangi mijozlar', 'Mavsumiy'],
        dailyPredictions: List.generate(
            daysAhead,
            (i) => DailyPrediction(
                  date: DateTime.now().add(Duration(days: i + 1)),
                  amount: 5000000 + (i * 500000),
                  orders: 3 + (i ~/ 2),
                )),
      ));
    } catch (e) {
      return Left(ServerFailure(message: 'Prognoz xatoligi'));
    }
  }

  // ============ OPTIMAL VISIT TIME ============

  /// Eng yaxshi tashrif vaqti
  Future<Either<Failure, OptimalVisitTime>> getOptimalVisitTime(
    String customerId,
  ) async {
    try {
      return Right(OptimalVisitTime(
        customerId: customerId,
        bestDay: 'Dushanba',
        bestTime: '10:00',
        alternativeDays: ['Seshanba', 'Chorshanba'],
        alternativeTimes: ['11:00', '14:00'],
        reason: 'Mijoz eng faol vaqti',
      ));
    } catch (e) {
      return Left(ServerFailure(message: 'Vaqt tavsiyasi xatoligi'));
    }
  }
}

// ============ MODELS ============

class ProductRecommendation {
  final String productId;
  final String productName;
  final String reason;
  final double confidence;
  final int expectedQuantity;

  const ProductRecommendation({
    required this.productId,
    required this.productName,
    required this.reason,
    required this.confidence,
    required this.expectedQuantity,
  });
}

class CustomerBehavior {
  final String customerId;
  final int orderFrequency;
  final double avgOrderValue;
  final List<String> preferredProducts;
  final String preferredTime;
  final String paymentPreference;
  final String riskLevel;
  final double churnProbability;
  final double lifetimeValue;

  const CustomerBehavior({
    required this.customerId,
    required this.orderFrequency,
    required this.avgOrderValue,
    required this.preferredProducts,
    required this.preferredTime,
    required this.paymentPreference,
    required this.riskLevel,
    required this.churnProbability,
    required this.lifetimeValue,
  });
}

class SalesPrediction {
  final String agentId;
  final double predictedSales;
  final double confidence;
  final String trend;
  final List<String> factors;
  final List<DailyPrediction> dailyPredictions;

  const SalesPrediction({
    required this.agentId,
    required this.predictedSales,
    required this.confidence,
    required this.trend,
    required this.factors,
    required this.dailyPredictions,
  });
}

class DailyPrediction {
  final DateTime date;
  final double amount;
  final int orders;

  const DailyPrediction({
    required this.date,
    required this.amount,
    required this.orders,
  });
}

class OptimalVisitTime {
  final String customerId;
  final String bestDay;
  final String bestTime;
  final List<String> alternativeDays;
  final List<String> alternativeTimes;
  final String reason;

  const OptimalVisitTime({
    required this.customerId,
    required this.bestDay,
    required this.bestTime,
    required this.alternativeDays,
    required this.alternativeTimes,
    required this.reason,
  });
}
