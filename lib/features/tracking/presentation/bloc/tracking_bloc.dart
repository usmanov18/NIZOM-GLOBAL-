import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/config/env_config.dart';
import '../../domain/entities/tracking_entities.dart';

// ============================================================
// TRACKING BLOC - Real vaqt kuzatish
// ============================================================

// ============ EVENTS ============

abstract class TrackingEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class TrackingStartRequested extends TrackingEvent {}

class TrackingStopRequested extends TrackingEvent {}

class AgentStatusesLoadRequested extends TrackingEvent {}

class AgentRouteLoadRequested extends TrackingEvent {
  final String agentId;
  final DateTime date;
  AgentRouteLoadRequested({required this.agentId, required this.date});
}

class SOSAlertReceived extends TrackingEvent {
  final SOSAlert alert;
  SOSAlertReceived(this.alert);
}

class GeofenceAddRequested extends TrackingEvent {
  final GeofenceZone zone;
  GeofenceAddRequested(this.zone);
}

class GeofenceRemoveRequested extends TrackingEvent {
  final String zoneId;
  GeofenceRemoveRequested(this.zoneId);
}

// ============ STATES ============

abstract class TrackingState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TrackingInitial extends TrackingState {}

class TrackingLoading extends TrackingState {}

class TrackingActive extends TrackingState {
  final List<AgentLiveStatus> agents;
  final int onlineCount;
  final int offlineCount;

  TrackingActive({
    required this.agents,
    required this.onlineCount,
    required this.offlineCount,
  });
}

class AgentRouteLoaded extends TrackingState {
  final AgentRoute route;
  AgentRouteLoaded(this.route);
}

class SOSAlertState extends TrackingState {
  final SOSAlert alert;
  SOSAlertState(this.alert);
}

class GeofenceAdded extends TrackingState {
  final GeofenceZone zone;
  GeofenceAdded(this.zone);
}

class TrackingError extends TrackingState {
  final String message;
  TrackingError(this.message);
}

// ============ BLOC ============

class TrackingBloc extends Bloc<TrackingEvent, TrackingState> {
  Timer? _refreshTimer;

  TrackingBloc() : super(TrackingInitial()) {
    on<TrackingStartRequested>(_onStart);
    on<TrackingStopRequested>(_onStop);
    on<AgentStatusesLoadRequested>(_onAgentStatuses);
    on<AgentRouteLoadRequested>(_onAgentRoute);
    on<SOSAlertReceived>(_onSOSAlert);
    on<GeofenceAddRequested>(_onGeofenceAdd);
    on<GeofenceRemoveRequested>(_onGeofenceRemove);
  }

  Future<void> _onStart(
    TrackingStartRequested event,
    Emitter<TrackingState> emit,
  ) async {
    // Har 10 soniyada yangilash
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => add(AgentStatusesLoadRequested()),
    );

    add(AgentStatusesLoadRequested());
  }

  Future<void> _onStop(
    TrackingStopRequested event,
    Emitter<TrackingState> emit,
  ) async {
    _refreshTimer?.cancel();
    emit(TrackingInitial());
  }

  Future<void> _onAgentStatuses(
    AgentStatusesLoadRequested event,
    Emitter<TrackingState> emit,
  ) async {
    if (!EnvConfig.isDemoMode) {
      emit(TrackingError('Tracking ma’lumotlari real servisga ulanmagan'));
      return;
    }
    final agents = List.generate(
        15,
        (i) => AgentLiveStatus(
              agentId: 'agent_$i',
              agentName: 'Agent ${i + 1}',
              agentCode: 'AG${(i + 1).toString().padLeft(3, '0')}',
              status: i < 10 ? 'on_route' : 'offline',
              latitude: 41.2995 + (i * 0.005),
              longitude: 69.2401 + (i * 0.005),
              speed: i < 10 ? 30.0 + (i * 2) : 0,
              lastUpdate: DateTime.now().subtract(Duration(minutes: i)),
              batteryLevel: 100 - (i * 5).toDouble(),
            ));

    emit(TrackingActive(
      agents: agents,
      onlineCount: agents.where((a) => a.isOnline).length,
      offlineCount: agents.where((a) => !a.isOnline).length,
    ));
  }

  Future<void> _onAgentRoute(
    AgentRouteLoadRequested event,
    Emitter<TrackingState> emit,
  ) async {
    emit(TrackingLoading());
    if (!EnvConfig.isDemoMode) {
      emit(TrackingError('Agent marshruti real servisga ulanmagan'));
      return;
    }
    final points = List.generate(
        50,
        (i) => RoutePoint(
              latitude: 41.2995 + (i * 0.001),
              longitude: 69.2401 + (i * 0.001),
              timestamp:
                  DateTime.now().subtract(Duration(hours: 8 - (i ~/ 10))),
              speed: 30.0 + (i % 10),
            ));

    emit(AgentRouteLoaded(AgentRoute(
      agentId: event.agentId,
      date: event.date,
      points: points,
      totalDistance: 45.3,
      totalTime: const Duration(hours: 8),
      stopsCount: 12,
      startTime: DateTime.now().subtract(const Duration(hours: 8)),
      endTime: DateTime.now(),
    )));
  }

  void _onSOSAlert(SOSAlertReceived event, Emitter<TrackingState> emit) {
    emit(SOSAlertState(event.alert));
  }

  void _onGeofenceAdd(GeofenceAddRequested event, Emitter<TrackingState> emit) {
    emit(GeofenceAdded(event.zone));
  }

  void _onGeofenceRemove(
      GeofenceRemoveRequested event, Emitter<TrackingState> emit) {
    // Remove geofence
  }

  @override
  Future<void> close() {
    _refreshTimer?.cancel();
    return super.close();
  }
}
