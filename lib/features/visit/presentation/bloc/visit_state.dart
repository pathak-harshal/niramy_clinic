part of 'visit_bloc.dart';

abstract class VisitState extends Equatable {
  const VisitState();

  @override
  List<Object?> get props => [];
}

class VisitInitial extends VisitState {
  const VisitInitial();
}

class VisitLoading extends VisitState {
  const VisitLoading();
}

class VisitsLoadSuccess extends VisitState {
  final List<Visit> visits;
  const VisitsLoadSuccess(this.visits);

  @override
  List<Object?> get props => [visits];
}

class VisitLoadSuccess extends VisitState {
  final Visit visit;
  const VisitLoadSuccess(this.visit);

  @override
  List<Object?> get props => [visit];
}

class VisitOperationSuccess extends VisitState {
  final String message;
  const VisitOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class VisitFailure extends VisitState {
  final String error;
  const VisitFailure(this.error);

  @override
  List<Object?> get props => [error];
}