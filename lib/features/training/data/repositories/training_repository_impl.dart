import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/training_course.dart';
import '../../domain/repositories/training_repository.dart';

class TrainingRepositoryImpl implements TrainingRepository {
  final Map<String, TrainingCourse> _courses = {
    for (final course in _initialCourses) course.id: course,
  };

  static final List<TrainingCourse> _initialCourses = [
    const TrainingCourse(
      id: 'sales_basics',
      title: 'Sotuv asoslari',
      description: 'Mijozlar bilan muloqot va sotuv texnikalari',
      category: 'Sotuv',
      duration: Duration(hours: 2),
      lessons: 8,
      progress: 0.75,
      status: TrainingCourseStatus.inProgress,
    ),
    const TrainingCourse(
      id: 'product_knowledge',
      title: 'Mahsulot bilimi',
      description: 'Barcha mahsulotlar haqida ma’lumot',
      category: 'Mahsulot',
      duration: Duration(hours: 3),
      lessons: 12,
      progress: 1,
      status: TrainingCourseStatus.completed,
    ),
    const TrainingCourse(
      id: 'one_c_workflow',
      title: '1C tizimi bilan ishlash',
      description: '1C da buyurtma yaratish va boshqarish',
      category: 'Tizim',
      duration: Duration(minutes: 90),
      lessons: 6,
      progress: 0.3,
      status: TrainingCourseStatus.inProgress,
    ),
    const TrainingCourse(
      id: 'work_safety',
      title: 'Xavfsizlik qoidalari',
      description: 'Ish joyida xavfsizlik',
      category: 'Xavfsizlik',
      duration: Duration(hours: 1),
      lessons: 4,
      progress: 0,
      status: TrainingCourseStatus.notStarted,
    ),
  ];

  @override
  Future<Either<Failure, List<TrainingCourse>>> getCourses(
      {String? category}) async {
    try {
      final items = _courses.values
          .where((course) => category == null || course.category == category)
          .toList()
        ..sort((a, b) => a.title.compareTo(b.title));
      return Right(items);
    } catch (e) {
      return const Left(CacheFailure(message: 'Kurslar yuklanmadi'));
    }
  }

  @override
  Future<Either<Failure, TrainingCourse>> getCourseById(String id) async {
    final course = _courses[id];
    if (course == null) return const Left(NotFoundFailure(resource: 'Kurs'));
    return Right(course);
  }

  @override
  Future<Either<Failure, TrainingCourse>> updateProgress(
      {required String id, required double progress}) async {
    final course = _courses[id];
    if (course == null) return const Left(NotFoundFailure(resource: 'Kurs'));
    final safeProgress = progress.clamp(0.0, 1.0);
    final updated = course.copyWith(
      progress: safeProgress,
      status: safeProgress >= 1
          ? TrainingCourseStatus.completed
          : safeProgress > 0
              ? TrainingCourseStatus.inProgress
              : TrainingCourseStatus.notStarted,
    );
    _courses[id] = updated;
    return Right(updated);
  }
}
