import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/competitor_entity.dart';

abstract class CompetitorRepository {
  Future<Either<Failure, List<CompetitorEntity>>> getCompetitors();
  Future<Either<Failure, CompetitorEntity>> addCompetitor(
      CompetitorEntity competitor);
}
