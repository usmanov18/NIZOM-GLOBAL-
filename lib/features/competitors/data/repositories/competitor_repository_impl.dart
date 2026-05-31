import 'package:dartz/dartz.dart';

import '../../../../core/config/env_config.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/competitor_entity.dart';
import '../../domain/repositories/competitor_repository.dart';

class CompetitorRepositoryImpl implements CompetitorRepository {
  final Map<String, CompetitorEntity> _items = {
    for (final item in _initialItems) item.id: item,
  };

  static const List<CompetitorEntity> _initialItems = [
    CompetitorEntity(
      id: 'coca_comp',
      name: 'Coca-Cola Comp',
      marketShare: 35,
      avgPrice: 8200,
      ourPrice: 8500,
      strengths: ['Kuchli brend', 'Keng tarqalgan'],
      weaknesses: ['Yuqori narx'],
    ),
    CompetitorEntity(
      id: 'pepsi_co',
      name: 'Pepsi Co',
      marketShare: 25,
      avgPrice: 7800,
      ourPrice: 7000,
      strengths: ['Arzon narx', 'Aksiyalar'],
      weaknesses: ['Kam brend'],
    ),
    CompetitorEntity(
      id: 'local_drinks',
      name: 'Local Drinks',
      marketShare: 15,
      avgPrice: 5000,
      ourPrice: 5500,
      strengths: ['Juda arzon'],
      weaknesses: ['Sifat past'],
    ),
  ];

  @override
  Future<Either<Failure, List<CompetitorEntity>>> getCompetitors() async {
    if (!EnvConfig.isDemoMode && _items.isEmpty) {
      return const Left(
          CacheFailure(message: 'Raqobatchilar ma’lumotlari topilmadi'));
    }
    final items = _items.values.toList()
      ..sort((a, b) => b.marketShare.compareTo(a.marketShare));
    return Right(items);
  }

  @override
  Future<Either<Failure, CompetitorEntity>> addCompetitor(
      CompetitorEntity competitor) async {
    if (competitor.name.trim().isEmpty) {
      return const Left(
          ValidationFailure(message: 'Raqobatchi nomi kiritilishi shart'));
    }
    _items[competitor.id] = competitor;
    return Right(competitor);
  }
}
