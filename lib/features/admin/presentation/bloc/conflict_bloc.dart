import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/repositories/conflict_repository.dart';
import '../../../../core/errors/conflicts.dart';

abstract class ConflictEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadConflicts extends ConflictEvent {}

class ResolveConflict extends ConflictEvent {
  final String entityId;
  final String preferredSource;
  ResolveConflict(this.entityId, this.preferredSource);
}

abstract class ConflictState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ConflictInitial extends ConflictState {}

class ConflictLoading extends ConflictState {}

class ConflictsLoaded extends ConflictState {
  final List<DataConflict> conflicts;
  ConflictsLoaded(this.conflicts);
}

class ConflictError extends ConflictState {
  final String message;
  ConflictError(this.message);
}

class ConflictBloc extends Bloc<ConflictEvent, ConflictState> {
  final ConflictRepository repository;
  ConflictBloc(this.repository) : super(ConflictInitial()) {
    on<LoadConflicts>((event, emit) async {
      emit(ConflictLoading());
      final result = await repository.getPendingConflicts();
      result.fold((f) => emit(ConflictError(f.message)),
          (c) => emit(ConflictsLoaded(c)));
    });
    on<ResolveConflict>((event, emit) async {
      final result = await repository.resolveConflict(
          event.entityId, event.preferredSource);
      result.fold(
          (f) => emit(ConflictError(f.message)), (_) => add(LoadConflicts()));
    });
  }
}
