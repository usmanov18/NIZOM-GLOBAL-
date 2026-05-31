import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/conflicts.dart';

abstract class ConflictRepository {
  Future<Either<Failure, List<DataConflict>>> getPendingConflicts();
  Future<Either<Failure, bool>> resolveConflict(
      String entityId, String preferredSource);
}
