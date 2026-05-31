import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'models/location_models.dart';
import 'location_service.dart';
import 'location_repository.dart';

// ============================================================
// LOCATION BLOC - GPS Tracking boshqaruvi
// ============================================================

// ============ EVENTS ============

abstract class LocationEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LocationInitializeRequested extends LocationEvent {}

class LocationStartTrackingRequested extends LocationEvent {
  final TrackingConfig? config;
  LocationStartTrackingRequested({this.config});
}

class LocationStopTrackingRequested extends LocationEvent {}

class LocationPauseTrackingRequested extends LocationEvent {}

class LocationResumeTrackingRequested extends LocationEvent {}

class LocationGetCurrentRequested extends LocationEvent {}

class LocationPointReceived extends LocationEvent {
  final LocationPoint point;
  LocationPointReceived(this.point);
}

class LocationGeofenceAddRequested extends LocationEvent {
  final GeofenceZone zone;
  LocationGeofenceAddRequested(this.zone);
}

class LocationGeofenceRemoveRequested extends LocationEvent {
  final String zoneId;
  LocationGeofenceRemoveRequested(this.zoneId);
}

class LocationRouteLoadRequested extends LocationEvent {
  final String driverId;
  final DateTime date;
  LocationRouteLoadRequested({required this.driverId, required this.date});
}

class LocationAgentsLoadRequested extends LocationEvent {
  final String? supervisorId;
  LocationAgentsLoadRequested({this.supervisorId});
}

class LocationSyncRequested extends LocationEvent {}

// ============ STATES ============

abstract class LocationState extends Equatable {
  @override
  List<Object?> get props => [];
}

class LocationInitial extends LocationState {}

class LocationLoading extends LocationState {}

class LocationInitialized extends LocationState {
  final bool isReady;
  LocationInitialized({required this.isReady});
}

class LocationTrackingActive extends LocationState {
  final LocationPoint? currentPoint;
  final List<LocationPoint> points;
  final double totalDistance;
  final TrackingStatus status;

  LocationTrackingActive({
    this.currentPoint,
    required this.points,
    required this.totalDistance,
    required this.status,
  });

  @override
  List<Object?> get props => [currentPoint, status];
}

class LocationTrackingPaused extends LocationState {}

class LocationCurrentPoint extends LocationState {
  final LocationPoint point;
  LocationCurrentPoint(this.point);
}

class LocationRouteLoaded extends LocationState {
  final DailyRoute route;
  LocationRouteLoaded(this.route);
}

class LocationAgentsLoaded extends LocationState {
  final List<AgentLocation> agents;
  LocationAgentsLoaded(this.agents);
}

class LocationGeofenceEventState extends LocationState {
  final GeofenceEvent event;
  LocationGeofenceEventState(this.event);
}

class LocationSyncCompleted extends LocationState {
  final int syncedCount;
  LocationSyncCompleted(this.syncedCount);
}

class LocationError extends LocationState {
  final String message;
  final String? code;
  LocationError({required this.message, this.code});
}

// ============ BLOC ============

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  final LocationService _locationService;
  final LocationRepository _repository;

  StreamSubscription<LocationPoint>? _locationSubscription;
  StreamSubscription<GeofenceEvent>? _geofenceSubscription;
  StreamSubscription<TrackingStatus>? _statusSubscription;

  LocationBloc({
    required LocationService locationService,
    required LocationRepository repository,
  })  : _locationService = locationService,
        _repository = repository,
        super(LocationInitial()) {
    on<LocationInitializeRequested>(_onInitialize);
    on<LocationStartTrackingRequested>(_onStartTracking);
    on<LocationStopTrackingRequested>(_onStopTracking);
    on<LocationPauseTrackingRequested>(_onPauseTracking);
    on<LocationResumeTrackingRequested>(_onResumeTracking);
    on<LocationGetCurrentRequested>(_onGetCurrent);
    on<LocationPointReceived>(_onPointReceived);
    on<LocationGeofenceAddRequested>(_onGeofenceAdd);
    on<LocationGeofenceRemoveRequested>(_onGeofenceRemove);
    on<LocationRouteLoadRequested>(_onRouteLoad);
    on<LocationAgentsLoadRequested>(_onAgentsLoad);
    on<LocationSyncRequested>(_onSync);
  }

  // ============ INITIALIZE ============

  Future<void> _onInitialize(
    LocationInitializeRequested event,
    Emitter<LocationState> emit,
  ) async {
    emit(LocationLoading());

    final isReady = await _locationService.initialize();
    emit(LocationInitialized(isReady: isReady));

    if (isReady) {
      // Stream larni tinglash
      _locationSubscription = _locationService.locationStream.listen(
        (point) => add(LocationPointReceived(point)),
      );

      _geofenceSubscription = _locationService.geofenceStream.listen(
        (event) => emit(LocationGeofenceEventState(event)),
      );
    }
  }

  // ============ START TRACKING ============

  Future<void> _onStartTracking(
    LocationStartTrackingRequested event,
    Emitter<LocationState> emit,
  ) async {
    final started = await _locationService.startTracking(
      config: event.config,
    );

    if (started) {
      emit(LocationTrackingActive(
        points: [],
        totalDistance: 0,
        status: TrackingStatus.active,
      ));
    } else {
      emit(LocationError(message: 'Tracking boshlanmadi'));
    }
  }

  // ============ STOP TRACKING ============

  Future<void> _onStopTracking(
    LocationStopTrackingRequested event,
    Emitter<LocationState> emit,
  ) async {
    await _locationService.stopTracking();

    // Oxirgi ma'lumotlarni serverga yuborish
    final points = _locationService.points;
    if (points.isNotEmpty) {
      await _repository.sendBatchLocations(points);
    }

    _locationService.clearData();
    emit(LocationInitial());
  }

  // ============ PAUSE/RESUME ============

  Future<void> _onPauseTracking(
    LocationPauseTrackingRequested event,
    Emitter<LocationState> emit,
  ) async {
    await _locationService.pauseTracking();
    emit(LocationTrackingPaused());
  }

  Future<void> _onResumeTracking(
    LocationResumeTrackingRequested event,
    Emitter<LocationState> emit,
  ) async {
    await _locationService.resumeTracking();
    emit(LocationTrackingActive(
      points: _locationService.points,
      totalDistance: _locationService.getDailyDistance(),
      status: TrackingStatus.active,
    ));
  }

  // ============ GET CURRENT ============

  Future<void> _onGetCurrent(
    LocationGetCurrentRequested event,
    Emitter<LocationState> emit,
  ) async {
    emit(LocationLoading());

    final point = await _locationService.getCurrentLocation();
    if (point != null) {
      emit(LocationCurrentPoint(point));
    } else {
      emit(LocationError(message: 'Lokatsiya olinmadi'));
    }
  }

  // ============ POINT RECEIVED ============

  void _onPointReceived(
    LocationPointReceived event,
    Emitter<LocationState> emit,
  ) {
    final points = _locationService.points;
    final distance = _locationService.getDailyDistance();

    emit(LocationTrackingActive(
      currentPoint: event.point,
      points: points,
      totalDistance: distance,
      status: TrackingStatus.active,
    ));
  }

  // ============ GEOFENCE ============

  void _onGeofenceAdd(
    LocationGeofenceAddRequested event,
    Emitter<LocationState> emit,
  ) {
    _locationService.addGeofence(event.zone);
  }

  void _onGeofenceRemove(
    LocationGeofenceRemoveRequested event,
    Emitter<LocationState> emit,
  ) {
    _locationService.removeGeofence(event.zoneId);
  }

  // ============ ROUTE ============

  Future<void> _onRouteLoad(
    LocationRouteLoadRequested event,
    Emitter<LocationState> emit,
  ) async {
    emit(LocationLoading());

    final result = await _repository.getDailyRoute(
      driverId: event.driverId,
      date: event.date,
    );

    result.fold(
      (failure) => emit(LocationError(message: failure.message)),
      (route) => emit(LocationRouteLoaded(route)),
    );
  }

  // ============ AGENTS ============

  Future<void> _onAgentsLoad(
    LocationAgentsLoadRequested event,
    Emitter<LocationState> emit,
  ) async {
    emit(LocationLoading());

    final result = await _repository.getAgentsLocations(
      supervisorId: event.supervisorId,
    );

    result.fold(
      (failure) => emit(LocationError(message: failure.message)),
      (agents) => emit(LocationAgentsLoaded(agents)),
    );
  }

  // ============ SYNC ============

  Future<void> _onSync(
    LocationSyncRequested event,
    Emitter<LocationState> emit,
  ) async {
    final points = _locationService.points;
    if (points.isEmpty) {
      emit(LocationSyncCompleted(0));
      return;
    }

    final result = await _repository.sendBatchLocations(points);

    result.fold(
      (failure) => emit(LocationError(message: failure.message)),
      (_) {
        _locationService.clearData();
        emit(LocationSyncCompleted(points.length));
      },
    );
  }

  @override
  Future<void> close() {
    _locationSubscription?.cancel();
    _geofenceSubscription?.cancel();
    _statusSubscription?.cancel();
    return super.close();
  }
}
