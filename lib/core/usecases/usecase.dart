import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../errors/failures.dart';

/// Barcha UseCase lar uchun asosiy abstract class
///
/// [Type] - qaytariladigan ma'lumot turi
/// [Params] - parametrlar
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// UseCase lar uchun bo'sh parametr
class NoParams extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Pagination parametrlari
class PaginationParams extends Equatable {
  final int page;
  final int limit;
  final String? search;
  final String? sortBy;
  final bool? ascending;

  const PaginationParams({
    this.page = 1,
    this.limit = 20,
    this.search,
    this.sortBy,
    this.ascending,
  });

  @override
  List<Object?> get props => [page, limit, search, sortBy, ascending];
}

/// Date range parametrlari
class DateRangeParams extends Equatable {
  final DateTime startDate;
  final DateTime endDate;

  const DateRangeParams({
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [startDate, endDate];
}

/// ID parametri
class IdParams extends Equatable {
  final String id;

  const IdParams({required this.id});

  @override
  List<Object?> get props => [id];
}
