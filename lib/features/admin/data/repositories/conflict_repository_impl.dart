import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/conflicts.dart';
import '../../domain/repositories/conflict_repository.dart';

class ConflictRepositoryImpl implements ConflictRepository {
  @override
  Future<Either<Failure, List<DataConflict>>> getPendingConflicts() async {
    // Kelajakda 1C va SAP dan farqlarni solishtirish mantiqi shu yerda bo'ladi
    return const Right([]);
  }

  @override
  Future<Either<Failure, bool>> resolveConflict(
      String entityId, String preferredSource) async {
    return const Right(true);
  }
}
