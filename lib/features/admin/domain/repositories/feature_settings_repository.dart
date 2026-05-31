import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/feature_settings.dart';

// ============================================================
// FEATURE SETTINGS REPOSITORY
// ============================================================

abstract class FeatureSettingsRepository {
  /// Barcha funksiya sozlamalarini olish
  Future<Either<Failure, List<FeatureSettings>>> getAllSettings();

  /// Bitta funksiya sozlamasini olish
  Future<Either<Failure, FeatureSettings>> getSetting(String featureId);

  /// Funksiya sozlamasini yangilash
  Future<Either<Failure, FeatureSettings>> updateSetting(
      FeatureSettings settings);

  /// Funksiyani yoqish/o'chirish
  Future<Either<Failure, bool>> toggleFeature(String featureId, bool enabled);

  /// Funksiyani role bo'yicha sozlash
  Future<Either<Failure, bool>> setRoleAccess({
    required String featureId,
    required List<String> visibleFor,
    required List<String> allowedRoles,
  });

  /// Funksiya sozlamalarini yangilash
  Future<Either<Failure, bool>> updateFeatureSettings({
    required String featureId,
    required Map<String, dynamic> settings,
  });

  /// Default sozlamalarni qayta tiklash
  Future<Either<Failure, bool>> resetToDefaults();
}
