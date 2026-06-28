import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/visit_model.dart';
import '../../data/repositories/visit_repository.dart';

part 'visit_event.dart';
part 'visit_state.dart';

class VisitBloc extends Bloc<VisitEvent, VisitState> {
  final VisitRepository repository;

  VisitBloc(this.repository) : super(const VisitInitial()) {
    on<LoadVisits>(_onLoadVisits);
    on<LoadVisit>(_onLoadVisit);
    on<LoadVisitsByPatient>(_onLoadVisitsByPatient);
    on<AddVisit>(_onAddVisit);
    on<UpdateVisit>(_onUpdateVisit);
    on<DeleteVisit>(_onDeleteVisit);
  }

  Future<void> _onLoadVisits(LoadVisits event, Emitter<VisitState> emit) async {
    emit(const VisitLoading());
    try {
      final visits = await repository.getAllVisits();
      emit(VisitsLoadSuccess(visits));
    } catch (e) {
      emit(VisitFailure(e.toString()));
    }
  }

  Future<void> _onLoadVisit(LoadVisit event, Emitter<VisitState> emit) async {
    emit(const VisitLoading());
    try {
      final visit = await repository.getVisit(event.visitId);
      if (visit != null) {
        emit(VisitLoadSuccess(visit));
      } else {
        emit(const VisitFailure('Visit not found'));
      }
    } catch (e) {
      emit(VisitFailure(e.toString()));
    }
  }

  Future<void> _onLoadVisitsByPatient(
      LoadVisitsByPatient event,
      Emitter<VisitState> emit,
      ) async {
    emit(const VisitLoading());
    try {
      final visits = await repository.getVisitsByPatient(event.patientId);
      emit(VisitsLoadSuccess(visits));
    } catch (e) {
      emit(VisitFailure(e.toString()));
    }
  }

  Future<void> _onAddVisit(AddVisit event, Emitter<VisitState> emit) async {
    emit(const VisitLoading());
    try {
      final id = await repository.addVisit(event.visit);
      emit(VisitOperationSuccess('Visit added (id: $id)'));
    } catch (e) {
      emit(VisitFailure(e.toString()));
    }
  }

  Future<void> _onUpdateVisit(UpdateVisit event, Emitter<VisitState> emit) async {
    emit(const VisitLoading());
    try {
      await repository.updateVisit(event.visitId, event.visit);
      emit(const VisitOperationSuccess('Visit updated'));
    } catch (e) {
      emit(VisitFailure(e.toString()));
    }
  }

  Future<void> _onDeleteVisit(DeleteVisit event, Emitter<VisitState> emit) async {
    emit(const VisitLoading());
    try {
      await repository.deleteVisit(event.visitId);
      emit(const VisitOperationSuccess('Visit deleted'));
    } catch (e) {
      emit(VisitFailure(e.toString()));
    }
  }
}