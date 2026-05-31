import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/inventory_entities.dart';
import '../../domain/repositories/inventory_repository.dart';

// ============================================================
// INVENTORY BLOC - Inventarizatsiya boshqaruvi
// ============================================================

// ============ EVENTS ============

abstract class InventoryEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class InventoryListLoadRequested extends InventoryEvent {}

class InventoryStartRequested extends InventoryEvent {
  final String warehouseId;
  InventoryStartRequested({required this.warehouseId});
}

class InventoryItemScanRequested extends InventoryEvent {
  final String inventoryId;
  final String productId;
  final double actualQuantity;
  final String? notes;
  InventoryItemScanRequested({
    required this.inventoryId,
    required this.productId,
    required this.actualQuantity,
    this.notes,
  });
}

class InventoryCompleteRequested extends InventoryEvent {
  final String inventoryId;
  InventoryCompleteRequested(this.inventoryId);
}

class InventorySubmitRequested extends InventoryEvent {
  final String inventoryId;
  InventorySubmitRequested(this.inventoryId);
}

class InventoryResultsLoadRequested extends InventoryEvent {
  final String inventoryId;
  InventoryResultsLoadRequested(this.inventoryId);
}

// ============ STATES ============

abstract class InventoryState extends Equatable {
  @override
  List<Object?> get props => [];
}

class InventoryInitial extends InventoryState {}

class InventoryLoading extends InventoryState {}

class InventoryListLoaded extends InventoryState {
  final List<Inventory> inventories;
  InventoryListLoaded(this.inventories);
}

class InventoryStarted extends InventoryState {
  final Inventory inventory;
  InventoryStarted(this.inventory);
}

class InventoryItemScanned extends InventoryState {
  final InventoryItem item;
  InventoryItemScanned(this.item);
}

class InventoryCompleted extends InventoryState {
  final Inventory inventory;
  InventoryCompleted(this.inventory);
}

class InventorySubmitted extends InventoryState {
  final Inventory inventory;
  InventorySubmitted(this.inventory);
}

class InventoryResultsLoaded extends InventoryState {
  final InventoryResult result;
  InventoryResultsLoaded(this.result);
}

class InventoryError extends InventoryState {
  final String message;
  InventoryError(this.message);
}

// ============ BLOC ============

class InventoryBloc extends Bloc<InventoryEvent, InventoryState> {
  final InventoryRepository repository;

  InventoryBloc({required this.repository}) : super(InventoryInitial()) {
    on<InventoryListLoadRequested>(_onListLoad);
    on<InventoryStartRequested>(_onStart);
    on<InventoryItemScanRequested>(_onItemScan);
    on<InventoryCompleteRequested>(_onComplete);
    on<InventorySubmitRequested>(_onSubmit);
    on<InventoryResultsLoadRequested>(_onResultsLoad);
  }

  Future<void> _onListLoad(
      InventoryListLoadRequested event, Emitter<InventoryState> emit) async {
    emit(InventoryLoading());
    final result = await repository.getInventories();
    result.fold(
      (failure) => emit(InventoryError(failure.message)),
      (inventories) => emit(InventoryListLoaded(inventories)),
    );
  }

  Future<void> _onStart(
      InventoryStartRequested event, Emitter<InventoryState> emit) async {
    emit(InventoryLoading());
    final result = await repository.startInventory(
      warehouseId: event.warehouseId,
      agentId: 'current',
    );
    result.fold(
      (failure) => emit(InventoryError(failure.message)),
      (inventory) => emit(InventoryStarted(inventory)),
    );
  }

  Future<void> _onItemScan(
      InventoryItemScanRequested event, Emitter<InventoryState> emit) async {
    final result = await repository.countItem(
      inventoryId: event.inventoryId,
      productId: event.productId,
      actualQuantity: event.actualQuantity,
      notes: event.notes,
    );
    result.fold(
      (failure) => emit(InventoryError(failure.message)),
      (item) => emit(InventoryItemScanned(item)),
    );
  }

  Future<void> _onComplete(
      InventoryCompleteRequested event, Emitter<InventoryState> emit) async {
    emit(InventoryLoading());
    final result = await repository.completeInventory(event.inventoryId);
    result.fold(
      (failure) => emit(InventoryError(failure.message)),
      (inventory) => emit(InventoryCompleted(inventory)),
    );
  }

  Future<void> _onSubmit(
      InventorySubmitRequested event, Emitter<InventoryState> emit) async {
    emit(InventoryLoading());
    final result = await repository.submitInventory(event.inventoryId);
    result.fold(
      (failure) => emit(InventoryError(failure.message)),
      (inventory) => emit(InventorySubmitted(inventory)),
    );
  }

  Future<void> _onResultsLoad(
      InventoryResultsLoadRequested event, Emitter<InventoryState> emit) async {
    emit(InventoryLoading());
    final result = await repository.getResults(event.inventoryId);
    result.fold(
      (failure) => emit(InventoryError(failure.message)),
      (results) => emit(InventoryResultsLoaded(results)),
    );
  }
}
