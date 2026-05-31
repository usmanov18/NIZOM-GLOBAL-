import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/services/customer_segmentation_service.dart';
import '../../domain/repositories/customer_repository.dart';

// ============================================================
// CUSTOMER SEGMENTATION BLOC
// ============================================================

// ============ EVENTS ============

abstract class CustomerSegmentationEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class CustomerSegmentationLoadRequested extends CustomerSegmentationEvent {
  final String agentId;
  CustomerSegmentationLoadRequested(this.agentId);
}

class CustomerSegmentationRefreshRequested extends CustomerSegmentationEvent {
  final String agentId;
  CustomerSegmentationRefreshRequested(this.agentId);
}

class CustomerSegmentFilterRequested extends CustomerSegmentationEvent {
  final String? segment;
  final String? search;
  CustomerSegmentFilterRequested({this.segment, this.search});
}

class CustomerSegmentStatisticsRequested extends CustomerSegmentationEvent {}

// ============ STATES ============

abstract class CustomerSegmentationState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CustomerSegmentationInitial extends CustomerSegmentationState {}

class CustomerSegmentationLoading extends CustomerSegmentationState {}

class CustomerSegmentationLoaded extends CustomerSegmentationState {
  final List<SegmentedCustomer> allCustomers;
  final List<SegmentedCustomer> filteredCustomers;
  final SegmentStatistics statistics;
  final String? currentFilter;
  final String? searchQuery;

  CustomerSegmentationLoaded({
    required this.allCustomers,
    required this.filteredCustomers,
    required this.statistics,
    this.currentFilter,
    this.searchQuery,
  });

  @override
  List<Object?> get props => [allCustomers, filteredCustomers, currentFilter];
}

class CustomerSegmentationError extends CustomerSegmentationState {
  final String message;
  CustomerSegmentationError(this.message);
}

// ============ BLOC ============

class CustomerSegmentationBloc
    extends Bloc<CustomerSegmentationEvent, CustomerSegmentationState> {
  final CustomerRepository repository;
  final CustomerSegmentationService segmentationService;

  List<SegmentedCustomer> _allCustomers = [];

  CustomerSegmentationBloc({
    required this.repository,
    required this.segmentationService,
  }) : super(CustomerSegmentationInitial()) {
    on<CustomerSegmentationLoadRequested>(_onLoad);
    on<CustomerSegmentationRefreshRequested>(_onRefresh);
    on<CustomerSegmentFilterRequested>(_onFilter);
    on<CustomerSegmentStatisticsRequested>(_onStatistics);
  }

  Future<void> _onLoad(
    CustomerSegmentationLoadRequested event,
    Emitter<CustomerSegmentationState> emit,
  ) async {
    emit(CustomerSegmentationLoading());

    // Mijozlarni olish
    final result = await repository.getAgentCustomers(agentId: event.agentId);

    result.fold(
      (failure) => emit(CustomerSegmentationError(failure.message)),
      (customers) async {
        // Segmentatsiya
        final segmentResult = await segmentationService.segmentCustomers(
          customers: customers,
        );

        segmentResult.fold(
          (failure) => emit(CustomerSegmentationError(failure.message)),
          (segmented) {
            _allCustomers = segmented;
            final stats = segmentationService.getStatistics(segmented);

            emit(CustomerSegmentationLoaded(
              allCustomers: segmented,
              filteredCustomers: segmented,
              statistics: stats,
            ));
          },
        );
      },
    );
  }

  Future<void> _onRefresh(
    CustomerSegmentationRefreshRequested event,
    Emitter<CustomerSegmentationState> emit,
  ) async {
    add(CustomerSegmentationLoadRequested(event.agentId));
  }

  void _onFilter(
    CustomerSegmentFilterRequested event,
    Emitter<CustomerSegmentationState> emit,
  ) {
    if (_allCustomers.isEmpty) return;

    var filtered = _allCustomers;

    // Segment filtri
    if (event.segment != null && event.segment != 'all') {
      filtered = filtered.where((c) => c.segment == event.segment).toList();
    }

    // Qidiruv filtri
    if (event.search != null && event.search!.isNotEmpty) {
      final query = event.search!.toLowerCase();
      filtered = filtered
          .where((c) =>
              c.customer.name.toLowerCase().contains(query) ||
              c.customer.code.toLowerCase().contains(query) ||
              c.customer.phone.contains(query))
          .toList();
    }

    final stats = segmentationService.getStatistics(_allCustomers);

    emit(CustomerSegmentationLoaded(
      allCustomers: _allCustomers,
      filteredCustomers: filtered,
      statistics: stats,
      currentFilter: event.segment,
      searchQuery: event.search,
    ));
  }

  void _onStatistics(
    CustomerSegmentStatisticsRequested event,
    Emitter<CustomerSegmentationState> emit,
  ) {
    if (_allCustomers.isEmpty) return;

    final stats = segmentationService.getStatistics(_allCustomers);

    emit(CustomerSegmentationLoaded(
      allCustomers: _allCustomers,
      filteredCustomers: _allCustomers,
      statistics: stats,
    ));
  }
}
