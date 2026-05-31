import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/feature_settings.dart';
import '../../domain/repositories/feature_settings_repository.dart';

// ============================================================
// FEATURE SETTINGS REPOSITORY IMPLEMENTATION
// Hozircha local/in-memory repository. Backend tayyor bo'lganda
// remote/local datasource qatlamlari bilan almashtiriladi.
// ============================================================

class FeatureSettingsRepositoryImpl implements FeatureSettingsRepository {
  final Map<String, FeatureSettings> _store = {
    for (final item in DefaultFeatureSettings.defaults) item.featureId: item,
  };

  @override
  Future<Either<Failure, List<FeatureSettings>>> getAllSettings() async {
    try {
      final items = _store.values.toList()
        ..sort((a, b) => a.featureId.compareTo(b.featureId));
      return Right(items);
    } catch (_) {
      return const Left(
          CacheFailure(message: 'Funksiya sozlamalarini o‘qishda xatolik'));
    }
  }

  @override
  Future<Either<Failure, FeatureSettings>> getSetting(String featureId) async {
    final item = _store[featureId];
    if (item == null) {
      return const Left(NotFoundFailure(resource: 'Funksiya sozlamasi'));
    }
    return Right(item);
  }

  @override
  Future<Either<Failure, FeatureSettings>> updateSetting(
      FeatureSettings settings) async {
    _store[settings.featureId] = settings.copyWith();
    return Right(_store[settings.featureId]!);
  }

  @override
  Future<Either<Failure, bool>> toggleFeature(
      String featureId, bool enabled) async {
    final current = _store[featureId];
    if (current == null) {
      return const Left(NotFoundFailure(resource: 'Funksiya sozlamasi'));
    }
    _store[featureId] = current.copyWith(isEnabled: enabled);
    return const Right(true);
  }

  @override
  Future<Either<Failure, bool>> setRoleAccess({
    required String featureId,
    required List<String> visibleFor,
    required List<String> allowedRoles,
  }) async {
    final current = _store[featureId];
    if (current == null) {
      return const Left(NotFoundFailure(resource: 'Funksiya sozlamasi'));
    }
    _store[featureId] = current.copyWith(
      visibleFor: List<String>.from(visibleFor),
      allowedRoles: List<String>.from(allowedRoles),
    );
    return const Right(true);
  }

  @override
  Future<Either<Failure, bool>> updateFeatureSettings({
    required String featureId,
    required Map<String, dynamic> settings,
  }) async {
    final current = _store[featureId];
    if (current == null) {
      return const Left(NotFoundFailure(resource: 'Funksiya sozlamasi'));
    }
    _store[featureId] = current.copyWith(
      settings: <String, dynamic>{
        ...current.settings,
        ...settings,
      },
    );
    return const Right(true);
  }

  @override
  Future<Either<Failure, bool>> resetToDefaults() async {
    _store
      ..clear()
      ..addEntries(
        DefaultFeatureSettings.defaults
            .map((item) => MapEntry(item.featureId, item)),
      );
    return const Right(true);
  }
}
