import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import '../../domain/entities/delivery_entities.dart';
import '../../domain/repositories/delivery_repository.dart';

// ============================================================
// DELIVERY BLOC - Yetkazib berish boshqaruvi
// ============================================================

// ============ EVENTS ============

abstract class DeliveryEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// Dashboard
class DeliveryDashboardLoadRequested extends DeliveryEvent {}

class DeliveryDashboardRefreshRequested extends DeliveryEvent {}

// Deliveries
class DeliveryOrdersLoadRequested extends DeliveryEvent {
  final String? status;
  final DateTime? date;
  final int page;

  DeliveryOrdersLoadRequested({this.status, this.date, this.page = 1});
}

class DeliveryDetailLoadRequested extends DeliveryEvent {
  final String deliveryId;
  DeliveryDetailLoadRequested(this.deliveryId);
}

// Actions
class DeliveryPickOrderRequested extends DeliveryEvent {
  final String deliveryId;
  final List<DeliveryItem>? items;
  DeliveryPickOrderRequested({required this.deliveryId, this.items});
}

class DeliveryDepartRequested extends DeliveryEvent {
  final String deliveryId;
  final double latitude;
  final double longitude;
  DeliveryDepartRequested({
    required this.deliveryId,
    required this.latitude,
    required this.longitude,
  });
}

class DeliveryArriveRequested extends DeliveryEvent {
  final String deliveryId;
  final double latitude;
  final double longitude;
  DeliveryArriveRequested({
    required this.deliveryId,
    required this.latitude,
    required this.longitude,
  });
}

class DeliveryConfirmRequested extends DeliveryEvent {
  final DeliveryConfirmation confirmation;
  DeliveryConfirmRequested(this.confirmation);
}

class DeliveryFailedRequested extends DeliveryEvent {
  final String deliveryId;
  final String reason;
  final String? notes;
  final List<String>? photos;
  final double latitude;
  final double longitude;
  DeliveryFailedRequested({
    required this.deliveryId,
    required this.reason,
    this.notes,
    this.photos,
    required this.latitude,
    required this.longitude,
  });
}

class DeliveryReturnRequested extends DeliveryEvent {
  final String deliveryId;
  final List<DeliveryReturnItem> items;
  final String returnReason;
  final String? notes;
  DeliveryReturnRequested({
    required this.deliveryId,
    required this.items,
    required this.returnReason,
    this.notes,
  });
}

// Route
class DeliveryRouteLoadRequested extends DeliveryEvent {
  final DateTime? date;
  DeliveryRouteLoadRequested({this.date});
}

class DeliveryRouteOptimizeRequested extends DeliveryEvent {
  final List<String> deliveryIds;
  DeliveryRouteOptimizeRequested(this.deliveryIds);
}

class DeliveryRouteStartRequested extends DeliveryEvent {}

class DeliveryRouteCompleteRequested extends DeliveryEvent {}

// GPS
class DeliveryLocationUpdateRequested extends DeliveryEvent {
  final double latitude;
  final double longitude;
  final double? altitude;
  final double? accuracy;
  final double? speed;
  final double? heading;

  DeliveryLocationUpdateRequested({
    required this.latitude,
    required this.longitude,
    this.altitude,
    this.accuracy,
    this.speed,
    this.heading,
  });
}

class DeliveryTrackingStartRequested extends DeliveryEvent {}

class DeliveryTrackingStopRequested extends DeliveryEvent {}

// Driver
class DriverStatusLoadRequested extends DeliveryEvent {
  final String? driverId;
  DriverStatusLoadRequested({this.driverId});
}

// ============ STATES ============

abstract class DeliveryState extends Equatable {
  @override
  List<Object?> get props => [];
}

class DeliveryInitial extends DeliveryState {}

class DeliveryLoading extends DeliveryState {}

class DeliveryDashboardLoaded extends DeliveryState {
  final DriverStatus driverStatus;
  final List<DeliveryOrder> todayDeliveries;
  final DeliveryRoute? todayRoute;

  DeliveryDashboardLoaded({
    required this.driverStatus,
    required this.todayDeliveries,
    this.todayRoute,
  });
}

class DeliveryOrdersLoaded extends DeliveryState {
  final List<DeliveryOrder> deliveries;
  final bool hasMore;
  final int currentPage;

  DeliveryOrdersLoaded({
    required this.deliveries,
    this.hasMore = false,
    this.currentPage = 1,
  });
}

class DeliveryDetailLoaded extends DeliveryState {
  final DeliveryOrder delivery;
  DeliveryDetailLoaded(this.delivery);
}

class DeliveryPicked extends DeliveryState {
  final DeliveryOrder delivery;
  DeliveryPicked(this.delivery);
}

class DeliveryDeparted extends DeliveryState {
  final DeliveryOrder delivery;
  DeliveryDeparted(this.delivery);
}

class DeliveryArrived extends DeliveryState {
  final DeliveryOrder delivery;
  DeliveryArrived(this.delivery);
}

class DeliveryConfirmed extends DeliveryState {
  final DeliveryOrder delivery;
  final bool syncedTo1C;
  final bool syncedToSAP;

  DeliveryConfirmed({
    required this.delivery,
    required this.syncedTo1C,
    required this.syncedToSAP,
  });
}

class DeliveryFailedState extends DeliveryState {
  final DeliveryOrder delivery;
  DeliveryFailedState(this.delivery);
}

class DeliveryReturnedState extends DeliveryState {
  final DeliveryOrder delivery;
  DeliveryReturnedState(this.delivery);
}

class DeliveryRouteLoaded extends DeliveryState {
  final DeliveryRoute route;
  DeliveryRouteLoaded(this.route);
}

class DeliveryRouteOptimized extends DeliveryState {
  final DeliveryRoute route;
  DeliveryRouteOptimized(this.route);
}

class DeliveryRouteStarted extends DeliveryState {}

class DeliveryRouteCompleted extends DeliveryState {}

class DeliveryLocationSent extends DeliveryState {}

class DeliveryTrackingActive extends DeliveryState {
  final bool isActive;
  DeliveryTrackingActive({required this.isActive});
}

class DriverStatusLoaded extends DeliveryState {
  final DriverStatus status;
  DriverStatusLoaded(this.status);
}

class DeliveryError extends DeliveryState {
  final String message;
  DeliveryError(this.message);
}

// ============ BLOC ============

class DeliveryBloc extends Bloc<DeliveryEvent, DeliveryState> {
  final DeliveryRepository repository;
  StreamSubscription<Position>? _locationSubscription;

  DeliveryBloc({required this.repository}) : super(DeliveryInitial()) {
    on<DeliveryDashboardLoadRequested>(_onDashboardLoad);
    on<DeliveryDashboardRefreshRequested>(_onDashboardRefresh);
    on<DeliveryOrdersLoadRequested>(_onOrdersLoad);
    on<DeliveryDetailLoadRequested>(_onDetailLoad);
    on<DeliveryPickOrderRequested>(_onPickOrder);
    on<DeliveryDepartRequested>(_onDepart);
    on<DeliveryArriveRequested>(_onArrive);
    on<DeliveryConfirmRequested>(_onConfirm);
    on<DeliveryFailedRequested>(_onFailed);
    on<DeliveryReturnRequested>(_onReturn);
    on<DeliveryRouteLoadRequested>(_onRouteLoad);
    on<DeliveryRouteOptimizeRequested>(_onRouteOptimize);
    on<DeliveryRouteStartRequested>(_onRouteStart);
    on<DeliveryRouteCompleteRequested>(_onRouteComplete);
    on<DeliveryLocationUpdateRequested>(_onLocationUpdate);
    on<DeliveryTrackingStartRequested>(_onTrackingStart);
    on<DeliveryTrackingStopRequested>(_onTrackingStop);
    on<DriverStatusLoadRequested>(_onDriverStatusLoad);
  }

  // ============ DASHBOARD ============

  Future<void> _onDashboardLoad(
    DeliveryDashboardLoadRequested event,
    Emitter<DeliveryState> emit,
  ) async {
    emit(DeliveryLoading());

    final statusResult = await repository.getDriverStatus('current');
    final deliveriesResult = await repository.getDeliveries(
      date: DateTime.now(),
    );
    final routeResult = await repository.getRoute(
      driverId: 'current',
      date: DateTime.now(),
    );

    statusResult.fold(
      (failure) => emit(DeliveryError(failure.message)),
      (status) {
        deliveriesResult.fold(
          (failure) => emit(DeliveryError(failure.message)),
          (deliveries) {
            routeResult.fold(
              (_) => emit(DeliveryDashboardLoaded(
                driverStatus: status,
                todayDeliveries: deliveries,
              )),
              (route) => emit(DeliveryDashboardLoaded(
                driverStatus: status,
                todayDeliveries: deliveries,
                todayRoute: route,
              )),
            );
          },
        );
      },
    );
  }

  Future<void> _onDashboardRefresh(
    DeliveryDashboardRefreshRequested event,
    Emitter<DeliveryState> emit,
  ) async {
    add(DeliveryDashboardLoadRequested());
  }

  // ============ DELIVERIES ============

  Future<void> _onOrdersLoad(
    DeliveryOrdersLoadRequested event,
    Emitter<DeliveryState> emit,
  ) async {
    emit(DeliveryLoading());

    final result = await repository.getDeliveries(
      status: event.status,
      date: event.date,
      page: event.page,
    );

    result.fold(
      (failure) => emit(DeliveryError(failure.message)),
      (deliveries) => emit(DeliveryOrdersLoaded(
        deliveries: deliveries,
        hasMore: deliveries.length >= 20,
        currentPage: event.page,
      )),
    );
  }

  Future<void> _onDetailLoad(
    DeliveryDetailLoadRequested event,
    Emitter<DeliveryState> emit,
  ) async {
    emit(DeliveryLoading());

    final result = await repository.getDeliveryById(event.deliveryId);

    result.fold(
      (failure) => emit(DeliveryError(failure.message)),
      (delivery) => emit(DeliveryDetailLoaded(delivery)),
    );
  }

  // ============ ACTIONS ============

  Future<void> _onPickOrder(
    DeliveryPickOrderRequested event,
    Emitter<DeliveryState> emit,
  ) async {
    emit(DeliveryLoading());

    final result = await repository.pickOrder(
      deliveryId: event.deliveryId,
      pickedItems: event.items,
    );

    result.fold(
      (failure) => emit(DeliveryError(failure.message)),
      (delivery) => emit(DeliveryPicked(delivery)),
    );
  }

  Future<void> _onDepart(
    DeliveryDepartRequested event,
    Emitter<DeliveryState> emit,
  ) async {
    emit(DeliveryLoading());

    final result = await repository.depart(
      deliveryId: event.deliveryId,
      latitude: event.latitude,
      longitude: event.longitude,
    );

    result.fold(
      (failure) => emit(DeliveryError(failure.message)),
      (delivery) => emit(DeliveryDeparted(delivery)),
    );
  }

  Future<void> _onArrive(
    DeliveryArriveRequested event,
    Emitter<DeliveryState> emit,
  ) async {
    emit(DeliveryLoading());

    final result = await repository.arrive(
      deliveryId: event.deliveryId,
      latitude: event.latitude,
      longitude: event.longitude,
    );

    result.fold(
      (failure) => emit(DeliveryError(failure.message)),
      (delivery) => emit(DeliveryArrived(delivery)),
    );
  }

  Future<void> _onConfirm(
    DeliveryConfirmRequested event,
    Emitter<DeliveryState> emit,
  ) async {
    emit(DeliveryLoading());

    final result = await repository.confirmDelivery(
      confirmation: event.confirmation,
    );

    result.fold(
      (failure) => emit(DeliveryError(failure.message)),
      (delivery) async {
        // 1C/SAP ga sinxronlash
        final sync1C = await repository.syncDeliveryTo1C(delivery.id);
        final syncSAP = await repository.syncDeliveryToSAP(delivery.id);

        bool synced1C = false;
        bool syncedSAP = false;

        sync1C.fold((_) {}, (_) => synced1C = true);
        syncSAP.fold((_) {}, (_) => syncedSAP = true);

        emit(DeliveryConfirmed(
          delivery: delivery,
          syncedTo1C: synced1C,
          syncedToSAP: syncedSAP,
        ));
      },
    );
  }

  Future<void> _onFailed(
    DeliveryFailedRequested event,
    Emitter<DeliveryState> emit,
  ) async {
    emit(DeliveryLoading());

    final result = await repository.markAsFailed(
      deliveryId: event.deliveryId,
      reason: event.reason,
      notes: event.notes,
      photoUrls: event.photos,
      latitude: event.latitude,
      longitude: event.longitude,
    );

    result.fold(
      (failure) => emit(DeliveryError(failure.message)),
      (delivery) => emit(DeliveryFailedState(delivery)),
    );
  }

  Future<void> _onReturn(
    DeliveryReturnRequested event,
    Emitter<DeliveryState> emit,
  ) async {
    emit(DeliveryLoading());

    final result = await repository.markAsReturned(
      deliveryId: event.deliveryId,
      returnedItems: event.items,
      returnReason: event.returnReason,
      notes: event.notes,
    );

    result.fold(
      (failure) => emit(DeliveryError(failure.message)),
      (delivery) => emit(DeliveryReturnedState(delivery)),
    );
  }

  // ============ ROUTE ============

  Future<void> _onRouteLoad(
    DeliveryRouteLoadRequested event,
    Emitter<DeliveryState> emit,
  ) async {
    emit(DeliveryLoading());

    final result = await repository.getRoute(
      driverId: 'current',
      date: event.date ?? DateTime.now(),
    );

    result.fold(
      (failure) => emit(DeliveryError(failure.message)),
      (route) => emit(DeliveryRouteLoaded(route)),
    );
  }

  Future<void> _onRouteOptimize(
    DeliveryRouteOptimizeRequested event,
    Emitter<DeliveryState> emit,
  ) async {
    emit(DeliveryLoading());

    final result = await repository.optimizeRoute(
      driverId: 'current',
      date: DateTime.now(),
      deliveryIds: event.deliveryIds,
    );

    result.fold(
      (failure) => emit(DeliveryError(failure.message)),
      (route) => emit(DeliveryRouteOptimized(route)),
    );
  }

  Future<void> _onRouteStart(
    DeliveryRouteStartRequested event,
    Emitter<DeliveryState> emit,
  ) async {
    emit(DeliveryLoading());

    // GPS dan lokatsiya olish
    final position = await Geolocator.getCurrentPosition();

    final result = await repository.startRoute(
      routeId: 'current',
      latitude: position.latitude,
      longitude: position.longitude,
    );

    result.fold(
      (failure) => emit(DeliveryError(failure.message)),
      (_) => emit(DeliveryRouteStarted()),
    );

    // GPS tracking boshlash
    add(DeliveryTrackingStartRequested());
  }

  Future<void> _onRouteComplete(
    DeliveryRouteCompleteRequested event,
    Emitter<DeliveryState> emit,
  ) async {
    final result = await repository.completeRoute(routeId: 'current');

    result.fold(
      (failure) => emit(DeliveryError(failure.message)),
      (_) {
        emit(DeliveryRouteCompleted());
        add(DeliveryTrackingStopRequested());
      },
    );
  }

  // ============ GPS TRACKING ============

  Future<void> _onLocationUpdate(
    DeliveryLocationUpdateRequested event,
    Emitter<DeliveryState> emit,
  ) async {
    final result = await repository.sendLocation(
      driverId: 'current',
      latitude: event.latitude,
      longitude: event.longitude,
      altitude: event.altitude,
      accuracy: event.accuracy,
      speed: event.speed,
      heading: event.heading,
      timestamp: DateTime.now(),
    );

    result.fold(
      (failure) {}, // Silent fail
      (_) => emit(DeliveryLocationSent()),
    );
  }

  Future<void> _onTrackingStart(
    DeliveryTrackingStartRequested event,
    Emitter<DeliveryState> emit,
  ) async {
    _locationSubscription?.cancel();

    _locationSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
        timeLimit: Duration(seconds: 30),
      ),
    ).listen((position) {
      add(DeliveryLocationUpdateRequested(
        latitude: position.latitude,
        longitude: position.longitude,
        altitude: position.altitude,
        accuracy: position.accuracy,
        speed: position.speed,
        heading: position.heading,
      ));
    });

    emit(DeliveryTrackingActive(isActive: true));
  }

  Future<void> _onTrackingStop(
    DeliveryTrackingStopRequested event,
    Emitter<DeliveryState> emit,
  ) async {
    _locationSubscription?.cancel();
    _locationSubscription = null;
    emit(DeliveryTrackingActive(isActive: false));
  }

  // ============ DRIVER STATUS ============

  Future<void> _onDriverStatusLoad(
    DriverStatusLoadRequested event,
    Emitter<DeliveryState> emit,
  ) async {
    final result = await repository.getDriverStatus(
      event.driverId ?? 'current',
    );

    result.fold(
      (failure) => emit(DeliveryError(failure.message)),
      (status) => emit(DriverStatusLoaded(status)),
    );
  }

  @override
  Future<void> close() {
    _locationSubscription?.cancel();
    return super.close();
  }
}
