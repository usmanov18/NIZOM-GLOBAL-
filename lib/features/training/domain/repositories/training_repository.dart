import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/training_course.dart';

abstract class TrainingRepository {
  Future<Either<Failure, List<TrainingCourse>>> getCourses({String? category});
  Future<Either<Failure, TrainingCourse>> getCourseById(String id);
  Future<Either<Failure, TrainingCourse>> updateProgress(
      {required String id, required double progress});
}
