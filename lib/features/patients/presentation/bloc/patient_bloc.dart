import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../patients/data/models/patient_model.dart';
import '../../../patients/data/repositories/patient_repository.dart';

part 'patient_event.dart';
part 'patient_state.dart';

class PatientBloc extends Bloc<PatientEvent, PatientState> {
  final PatientRepository repository;

  PatientBloc(this.repository) : super(const PatientInitial()) {
    on<LoadPatient>(_onLoadPatient);
    on<AddPatient>(_onAddPatient);
    on<UpdatePatient>(_onUpdatePatient);
  }

  Future<void> _onLoadPatient(
    LoadPatient event,
    Emitter<PatientState> emit,
  ) async {
    emit(const PatientLoading());
    try {
      final patient = await repository.getPatient(event.patientId);
      if (patient != null) {
        emit(PatientLoadSuccess(patient));
      } else {
        emit(const PatientFailure('Patient not found'));
      }
    } catch (e) {
      emit(PatientFailure(e.toString()));
    }
  }

  Future<void> _onAddPatient(
    AddPatient event,
    Emitter<PatientState> emit,
  ) async {
    emit(const PatientLoading());
    try {
      final id = await repository.addPatient(event.patient);
      emit(PatientOperationSuccess('Patient added (id: $id)'));
    } catch (e) {
      emit(PatientFailure(e.toString()));
    }
  }

  Future<void> _onUpdatePatient(
    UpdatePatient event,
    Emitter<PatientState> emit,
  ) async {
    emit(const PatientLoading());
    try {
      await repository.updatePatient(event.patientId, event.patient);
      emit(const PatientOperationSuccess('Patient updated'));
    } catch (e) {
      emit(PatientFailure(e.toString()));
    }
  }
}
