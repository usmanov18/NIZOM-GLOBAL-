import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/discount_entities.dart';
import '../../domain/repositories/discount_repository.dart';

// ============================================================
// DISCOUNT BLOC - Chegirmalar va Promolar
// ============================================================

// ============ EVENTS ============

abstract class DiscountEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class DiscountsLoadRequested extends DiscountEvent {
  final String? priceGroupId;
  DiscountsLoadRequested({this.priceGroupId});
}

class DiscountsForProductRequested extends DiscountEvent {
  final String productId;
  final String priceGroupId;
  final double quantity;
  final double amount;
  DiscountsForProductRequested({
    required this.productId,
    required this.priceGroupId,
    required this.quantity,
    required this.amount,
  });
}

class PromotionsLoadRequested extends DiscountEvent {
  final String? customerGroup;
  final String? region;
  PromotionsLoadRequested({this.customerGroup, this.region});
}

class PromoCodeValidateRequested extends DiscountEvent {
  final String code;
  PromoCodeValidateRequested(this.code);
}

class SpecialPricesLoadRequested extends DiscountEvent {
  final String priceGroupId;
  SpecialPricesLoadRequested(this.priceGroupId);
}

class DiscountSyncFrom1CRequested extends DiscountEvent {}

class DiscountSyncFromSAPRequested extends DiscountEvent {}

class DiscountSyncAllRequested extends DiscountEvent {}

// ============ STATES ============

abstract class DiscountState extends Equatable {
  @override
  List<Object?> get props => [];
}

class DiscountInitial extends DiscountState {}

class DiscountLoading extends DiscountState {}

class DiscountsLoaded extends DiscountState {
  final List<ProductDiscount> discounts;
  DiscountsLoaded(this.discounts);
}

class DiscountsForProductLoaded extends DiscountState {
  final List<ProductDiscount> discounts;
  final double totalDiscount;
  DiscountsForProductLoaded({
    required this.discounts,
    required this.totalDiscount,
  });
}

class PromotionsLoaded extends DiscountState {
  final List<Promotion> promotions;
  PromotionsLoaded(this.promotions);
}

class PromoCodeValidated extends DiscountState {
  final Promotion promotion;
  PromoCodeValidated(this.promotion);
}

class PromoCodeInvalid extends DiscountState {
  final String message;
  PromoCodeInvalid(this.message);
}

class SpecialPricesLoaded extends DiscountState {
  final List<SpecialPrice> prices;
  SpecialPricesLoaded(this.prices);
}

class DiscountSyncCompleted extends DiscountState {
  final DiscountSyncResult result;
  DiscountSyncCompleted(this.result);
}

class DiscountError extends DiscountState {
  final String message;
  DiscountError(this.message);
}

// ============ BLOC ============

class DiscountBloc extends Bloc<DiscountEvent, DiscountState> {
  final DiscountRepository repository;

  DiscountBloc({required this.repository}) : super(DiscountInitial()) {
    on<DiscountsLoadRequested>(_onDiscountsLoad);
    on<DiscountsForProductRequested>(_onDiscountsForProduct);
    on<PromotionsLoadRequested>(_onPromotionsLoad);
    on<PromoCodeValidateRequested>(_onPromoCodeValidate);
    on<SpecialPricesLoadRequested>(_onSpecialPricesLoad);
    on<DiscountSyncFrom1CRequested>(_onSyncFrom1C);
    on<DiscountSyncFromSAPRequested>(_onSyncFromSAP);
    on<DiscountSyncAllRequested>(_onSyncAll);
  }

  Future<void> _onDiscountsLoad(
    DiscountsLoadRequested event,
    Emitter<DiscountState> emit,
  ) async {
    emit(DiscountLoading());
    final result = await repository.getActiveDiscounts(
      priceGroupId: event.priceGroupId,
    );
    result.fold(
      (failure) => emit(DiscountError(failure.message)),
      (discounts) => emit(DiscountsLoaded(discounts)),
    );
  }

  Future<void> _onDiscountsForProduct(
    DiscountsForProductRequested event,
    Emitter<DiscountState> emit,
  ) async {
    emit(DiscountLoading());
    final result = await repository.getDiscountsForProduct(
      productId: event.productId,
      priceGroupId: event.priceGroupId,
      quantity: event.quantity,
      amount: event.amount,
    );
    result.fold((failure) => emit(DiscountError(failure.message)), (discounts) {
      final totalDiscount = discounts.fold<double>(
        0,
        (sum, d) =>
            sum +
            d.calculateDiscount(
              event.amount / event.quantity,
              event.quantity.toInt(),
              event.amount,
            ),
      );
      emit(
        DiscountsForProductLoaded(
          discounts: discounts,
          totalDiscount: totalDiscount,
        ),
      );
    });
  }

  Future<void> _onPromotionsLoad(
    PromotionsLoadRequested event,
    Emitter<DiscountState> emit,
  ) async {
    emit(DiscountLoading());
    final result = await repository.getActivePromotions(
      customerGroup: event.customerGroup,
      region: event.region,
    );
    result.fold(
      (failure) => emit(DiscountError(failure.message)),
      (promotions) => emit(PromotionsLoaded(promotions)),
    );
  }

  Future<void> _onPromoCodeValidate(
    PromoCodeValidateRequested event,
    Emitter<DiscountState> emit,
  ) async {
    emit(DiscountLoading());
    final result = await repository.validatePromoCode(event.code);
    result.fold(
      (failure) => emit(PromoCodeInvalid(failure.message)),
      (promo) => emit(PromoCodeValidated(promo)),
    );
  }

  Future<void> _onSpecialPricesLoad(
    SpecialPricesLoadRequested event,
    Emitter<DiscountState> emit,
  ) async {
    emit(DiscountLoading());
    final result = await repository.getSpecialPrices(
      priceGroupId: event.priceGroupId,
    );
    result.fold(
      (failure) => emit(DiscountError(failure.message)),
      (prices) => emit(SpecialPricesLoaded(prices)),
    );
  }

  Future<void> _onSyncFrom1C(
    DiscountSyncFrom1CRequested event,
    Emitter<DiscountState> emit,
  ) async {
    emit(DiscountLoading());
    final result = await repository.syncAllDiscounts();
    result.fold(
      (failure) => emit(DiscountError(failure.message)),
      (syncResult) => emit(DiscountSyncCompleted(syncResult)),
    );
  }

  Future<void> _onSyncFromSAP(
    DiscountSyncFromSAPRequested event,
    Emitter<DiscountState> emit,
  ) async {
    emit(DiscountLoading());
    final result = await repository.syncAllDiscounts();
    result.fold(
      (failure) => emit(DiscountError(failure.message)),
      (syncResult) => emit(DiscountSyncCompleted(syncResult)),
    );
  }

  Future<void> _onSyncAll(
    DiscountSyncAllRequested event,
    Emitter<DiscountState> emit,
  ) async {
    emit(DiscountLoading());
    final result = await repository.syncAllDiscounts();
    result.fold(
      (failure) => emit(DiscountError(failure.message)),
      (syncResult) => emit(DiscountSyncCompleted(syncResult)),
    );
  }
}
