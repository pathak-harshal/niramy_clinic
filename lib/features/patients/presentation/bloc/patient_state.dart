part of 'patient_bloc.dart';

abstract class PatientState extends Equatable {
  const PatientState();

  @override
  List<Object?> get props => [];
}

class PatientInitial extends PatientState {
  const PatientInitial();
  // no extra props
}

class PatientLoading extends PatientState {
  const PatientLoading();
  // no extra props
}

class PatientLoadSuccess extends PatientState {
  final Patient patient;
  const PatientLoadSuccess(this.patient);

  @override
  List<Object?> get props => [patient];
}

class PatientOperationSuccess extends PatientState {
  final String message;
  const PatientOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class PatientFailure extends PatientState {
  final String error;
  const PatientFailure(this.error);

  @override
  List<Object?> get props => [error];
}
