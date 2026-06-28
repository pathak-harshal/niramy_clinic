part of 'appointment_bloc.dart';

abstract class AppointmentState extends Equatable {
  const AppointmentState();

  @override
  List<Object?> get props => [];
}

class AppointmentInitial extends AppointmentState {
  const AppointmentInitial();
}

class AppointmentLoading extends AppointmentState {
  const AppointmentLoading();
}

class AppointmentsLoadSuccess extends AppointmentState {
  final List<Appointment> appointments;
  const AppointmentsLoadSuccess(this.appointments);

  @override
  List<Object?> get props => [appointments];
}

class AppointmentLoadSuccess extends AppointmentState {
  final Appointment appointment;
  const AppointmentLoadSuccess(this.appointment);

  @override
  List<Object?> get props => [appointment];
}

class AppointmentOperationSuccess extends AppointmentState {
  final String message;
  const AppointmentOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class AppointmentFailure extends AppointmentState {
  final String error;
  const AppointmentFailure(this.error);

  @override
  List<Object?> get props => [error];
}
