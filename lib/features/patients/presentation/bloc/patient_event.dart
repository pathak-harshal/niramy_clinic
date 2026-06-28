part of 'patient_bloc.dart';

abstract class PatientEvent {
  const PatientEvent();
}

class LoadPatient extends PatientEvent {
  final String patientId;
  const LoadPatient(this.patientId);
}

class AddPatient extends PatientEvent {
  final Patient patient;
  const AddPatient(this.patient);
}

class UpdatePatient extends PatientEvent {
  final String patientId;
  final Patient patient;
  const UpdatePatient({required this.patientId, required this.patient});
}
