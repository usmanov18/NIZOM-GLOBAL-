import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/feature_settings.dart';
import '../../domain/repositories/feature_settings_repository.dart';

// ============================================================
// FEATURE SETTINGS BLOC
// ============================================================

// ============ EVENTS ============

abstract class FeatureSettingsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FeatureSettingsLoadRequested extends FeatureSettingsEvent {}

class FeatureSettingUpdateRequested extends FeatureSettingsEvent {
  final FeatureSettings settings;
  FeatureSettingUpdateRequested(this.settings);
}

class FeatureToggleRequested extends FeatureSettingsEvent {
  final String featureId;
  final bool enabled;
  FeatureToggleRequested({required this.featureId, required this.enabled});
}

class FeatureRoleAccessUpdateRequested extends FeatureSettingsEvent {
  final String featureId;
  final List<String> visibleFor;
  final List<String> allowedRoles;
  FeatureRoleAccessUpdateRequested({
    required this.featureId,
    required this.visibleFor,
    required this.allowedRoles,
  });
}

class FeatureCustomSettingsUpdateRequested extends FeatureSettingsEvent {
  final String featureId;
  final Map<String, dynamic> settings;
  FeatureCustomSettingsUpdateRequested({
    required this.featureId,
    required this.settings,
  });
}

class FeatureSettingsResetRequested extends FeatureSettingsEvent {}

// ============ STATES ============

abstract class FeatureSettingsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class FeatureSettingsInitial extends FeatureSettingsState {}

class FeatureSettingsLoading extends FeatureSettingsState {}

class FeatureSettingsLoaded extends FeatureSettingsState {
  final List<FeatureSettings> settings;
  FeatureSettingsLoaded(this.settings);
}

class FeatureSettingUpdated extends FeatureSettingsState {
  final FeatureSettings setting;
  FeatureSettingUpdated(this.setting);
}

class FeatureToggled extends FeatureSettingsState {
  final String featureId;
  final bool enabled;
  FeatureToggled({required this.featureId, required this.enabled});
}

class FeatureSettingsReset extends FeatureSettingsState {}

class FeatureSettingsError extends FeatureSettingsState {
  final String message;
  FeatureSettingsError(this.message);
}

// ============ BLOC ============

class FeatureSettingsBloc
    extends Bloc<FeatureSettingsEvent, FeatureSettingsState> {
  final FeatureSettingsRepository repository;

  FeatureSettingsBloc({required this.repository})
      : super(FeatureSettingsInitial()) {
    on<FeatureSettingsLoadRequested>(_onLoad);
    on<FeatureSettingUpdateRequested>(_onUpdate);
    on<FeatureToggleRequested>(_onToggle);
    on<FeatureRoleAccessUpdateRequested>(_onRoleAccessUpdate);
    on<FeatureCustomSettingsUpdateRequested>(_onCustomSettingsUpdate);
    on<FeatureSettingsResetRequested>(_onReset);
  }

  Future<void> _onLoad(
    FeatureSettingsLoadRequested event,
    Emitter<FeatureSettingsState> emit,
  ) async {
    emit(FeatureSettingsLoading());
    final result = await repository.getAllSettings();
    result.fold(
      (failure) => emit(FeatureSettingsError(failure.message)),
      (settings) => emit(FeatureSettingsLoaded(settings)),
    );
  }

  Future<void> _onUpdate(
    FeatureSettingUpdateRequested event,
    Emitter<FeatureSettingsState> emit,
  ) async {
    emit(FeatureSettingsLoading());
    final result = await repository.updateSetting(event.settings);
    result.fold(
      (failure) => emit(FeatureSettingsError(failure.message)),
      (setting) => emit(FeatureSettingUpdated(setting)),
    );
  }

  Future<void> _onToggle(
    FeatureToggleRequested event,
    Emitter<FeatureSettingsState> emit,
  ) async {
    final result =
        await repository.toggleFeature(event.featureId, event.enabled);
    result.fold(
      (failure) => emit(FeatureSettingsError(failure.message)),
      (_) => emit(FeatureToggled(
        featureId: event.featureId,
        enabled: event.enabled,
      )),
    );
  }

  Future<void> _onRoleAccessUpdate(
    FeatureRoleAccessUpdateRequested event,
    Emitter<FeatureSettingsState> emit,
  ) async {
    final result = await repository.setRoleAccess(
      featureId: event.featureId,
      visibleFor: event.visibleFor,
      allowedRoles: event.allowedRoles,
    );
    result.fold(
      (failure) => emit(FeatureSettingsError(failure.message)),
      (_) {},
    );
  }

  Future<void> _onCustomSettingsUpdate(
    FeatureCustomSettingsUpdateRequested event,
    Emitter<FeatureSettingsState> emit,
  ) async {
    final result = await repository.updateFeatureSettings(
      featureId: event.featureId,
      settings: event.settings,
    );
    result.fold(
      (failure) => emit(FeatureSettingsError(failure.message)),
      (_) {},
    );
  }

  Future<void> _onReset(
    FeatureSettingsResetRequested event,
    Emitter<FeatureSettingsState> emit,
  ) async {
    emit(FeatureSettingsLoading());
    final result = await repository.resetToDefaults();
    result.fold(
      (failure) => emit(FeatureSettingsError(failure.message)),
      (_) => emit(FeatureSettingsReset()),
    );
  }
}
