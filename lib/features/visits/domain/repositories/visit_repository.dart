import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/visit_entities.dart';

// ============================================================
// VISIT REPOSITORY - Tashriflar API
// ============================================================

abstract class VisitRepository {
  /// Tashriflar ro'yxati
  Future<Either<Failure, List<Visit>>> getVisits({
    required String agentId,
    DateTime? date,
    String? status,
    int page = 1,
    int limit = 20,
  });

  /// Tashrif tafsilotlari
  Future<Either<Failure, Visit>> getVisitById(String visitId);

  /// Tashrif yaratish
  Future<Either<Failure, Visit>> createVisit({
    required String agentId,
    required String customerId,
    required VisitType type,
    required DateTime scheduledDate,
    required String scheduledTime,
    String? purpose,
  });

  /// Check-in (tashrifni boshlash)
  Future<Either<Failure, Visit>> checkIn({
    required String visitId,
    required double latitude,
    required double longitude,
  });

  /// Check-out (tashrifni tugatish)
  Future<Either<Failure, Visit>> checkOut({
    required String visitId,
    required double latitude,
    required double longitude,
    String? notes,
    double? orderAmount,
    double? collectionAmount,
    List<String>? photoUrls,
  });

  /// Tashrifni bekor qilish
  Future<Either<Failure, bool>> cancelVisit({
    required String visitId,
    required String reason,
  });

  /// Tashrifni qayta rejalashtirish
  Future<Either<Failure, Visit>> rescheduleVisit({
    required String visitId,
    required DateTime newDate,
    required String newTime,
  });

  /// Statistika
  Future<Either<Failure, VisitStatistics>> getStatistics({
    required String agentId,
    required DateTime fromDate,
    required DateTime toDate,
  });

  /// Haftalik reja
  Future<Either<Failure, List<Visit>>> getWeeklyPlan({
    required String agentId,
    required DateTime weekStart,
  });
}
