import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/visit_entities.dart';
import '../../domain/repositories/visit_repository.dart';
import '../datasources/visit_remote_datasource.dart';

// ============================================================
// VISIT REPOSITORY IMPLEMENTATION
// ============================================================

class VisitRepositoryImpl implements VisitRepository {
  final VisitRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  VisitRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Visit>>> getVisits({
    required String agentId,
    DateTime? date,
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final data = await remoteDataSource.getVisits(
        agentId: agentId,
        date: date,
        status: status,
        page: page,
        limit: limit,
      );
      return Right(data.map((d) => _parseVisit(d)).toList());
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, Visit>> getVisitById(String visitId) async {
    try {
      final data = await remoteDataSource.getVisitById(visitId);
      return Right(_parseVisit(data));
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, Visit>> createVisit({
    required String agentId,
    required String customerId,
    required VisitType type,
    required DateTime scheduledDate,
    required String scheduledTime,
    String? purpose,
  }) async {
    try {
      final data = await remoteDataSource.createVisit({
        'agent_id': agentId,
        'customer_id': customerId,
        'type': type.name,
        'scheduled_date': scheduledDate.toIso8601String().substring(0, 10),
        'scheduled_time': scheduledTime,
        'purpose': purpose,
      });
      return Right(_parseVisit(data));
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, Visit>> checkIn({
    required String visitId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final data = await remoteDataSource.checkIn(visitId, latitude, longitude);
      return Right(_parseVisit(data));
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, Visit>> checkOut({
    required String visitId,
    required double latitude,
    required double longitude,
    String? notes,
    double? orderAmount,
    double? collectionAmount,
    List<String>? photoUrls,
  }) async {
    try {
      final data = await remoteDataSource.checkOut(visitId, {
        'latitude': latitude,
        'longitude': longitude,
        'notes': notes,
        'order_amount': orderAmount,
        'collection_amount': collectionAmount,
        'photo_urls': photoUrls,
      });
      return Right(_parseVisit(data));
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, bool>> cancelVisit({
    required String visitId,
    required String reason,
  }) async {
    try {
      final result = await remoteDataSource.cancelVisit(visitId, reason);
      return Right(result);
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, Visit>> rescheduleVisit({
    required String visitId,
    required DateTime newDate,
    required String newTime,
  }) async {
    try {
      final data = await remoteDataSource.rescheduleVisit(visitId, {
        'scheduled_date': newDate.toIso8601String().substring(0, 10),
        'scheduled_time': newTime,
      });
      return Right(_parseVisit(data));
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, VisitStatistics>> getStatistics({
    required String agentId,
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    try {
      final data =
          await remoteDataSource.getStatistics(agentId, fromDate, toDate);
      return Right(VisitStatistics(
        totalPlanned: data['total_planned'] ?? 0,
        totalCompleted: data['total_completed'] ?? 0,
        totalMissed: data['total_missed'] ?? 0,
        totalCancelled: data['total_cancelled'] ?? 0,
        completionRate: (data['completion_rate'] ?? 0).toDouble(),
        avgDuration: (data['avg_duration'] ?? 0).toDouble(),
        totalOrderAmount: (data['total_order_amount'] ?? 0).toDouble(),
        totalCollectionAmount:
            (data['total_collection_amount'] ?? 0).toDouble(),
      ));
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, List<Visit>>> getWeeklyPlan({
    required String agentId,
    required DateTime weekStart,
  }) async {
    try {
      final data = await remoteDataSource.getWeeklyPlan(agentId, weekStart);
      return Right(data.map((d) => _parseVisit(d)).toList());
    } catch (e) {
      return Left(ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString())));
    }
  }

  Visit _parseVisit(Map<String, dynamic> d) {
    return Visit(
      id: d['id'] ?? '',
      agentId: d['agent_id'] ?? '',
      agentName: d['agent_name'] ?? '',
      customerId: d['customer_id'] ?? '',
      customerName: d['customer_name'] ?? '',
      customerAddress: d['customer_address'] ?? '',
      customerLatitude: d['customer_latitude']?.toDouble(),
      customerLongitude: d['customer_longitude']?.toDouble(),
      type: VisitType.values.firstWhere(
        (t) => t.name == d['type'],
        orElse: () => VisitType.sales,
      ),
      status: VisitStatus.values.firstWhere(
        (s) => s.name == d['status'],
        orElse: () => VisitStatus.planned,
      ),
      scheduledDate: DateTime.parse(
          d['scheduled_date'] ?? DateTime.now().toIso8601String()),
      scheduledTime: d['scheduled_time'] ?? '',
      checkedInAt: d['checked_in_at'] != null
          ? DateTime.parse(d['checked_in_at'])
          : null,
      checkedOutAt: d['checked_out_at'] != null
          ? DateTime.parse(d['checked_out_at'])
          : null,
      checkInLatitude: d['check_in_latitude']?.toDouble(),
      checkInLongitude: d['check_in_longitude']?.toDouble(),
      checkOutLatitude: d['check_out_latitude']?.toDouble(),
      checkOutLongitude: d['check_out_longitude']?.toDouble(),
      durationMinutes: d['duration_minutes'],
      notes: d['notes'],
      purpose: d['purpose'],
      orderAmount: d['order_amount']?.toDouble(),
      collectionAmount: d['collection_amount']?.toDouble(),
      photoUrls: List<String>.from(d['photo_urls'] ?? []),
      createdAt:
          DateTime.parse(d['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          d['updated_at'] != null ? DateTime.parse(d['updated_at']) : null,
    );
  }
}
