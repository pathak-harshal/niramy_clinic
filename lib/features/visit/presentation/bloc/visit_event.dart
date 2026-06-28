part of 'visit_bloc.dart';

abstract class VisitEvent {
  const VisitEvent();
}

class LoadVisits extends VisitEvent {
  const LoadVisits();
}

class LoadVisit extends VisitEvent {
  final String visitId;
  const LoadVisit(this.visitId);
}

class LoadVisitsByPatient extends VisitEvent {
  final String patientId;
  const LoadVisitsByPatient(this.patientId);
}

class AddVisit extends VisitEvent {
  final Visit visit;
  const AddVisit(this.visit);
}

class UpdateVisit extends VisitEvent {
  final String visitId;
  final Visit visit;

  const UpdateVisit({required this.visitId, required this.visit});
}

class DeleteVisit extends VisitEvent {
  final String visitId;
  const DeleteVisit(this.visitId);
}