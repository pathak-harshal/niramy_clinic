part of 'appointment_bloc.dart';

abstract class AppointmentEvent {
  const AppointmentEvent();
}

class LoadAppointments extends AppointmentEvent {
  const LoadAppointments();
}

class LoadAppointment extends AppointmentEvent {
  final String appointmentId;
  const LoadAppointment(this.appointmentId);
}

class AddAppointment extends AppointmentEvent {
  final Appointment appointment;
  const AddAppointment(this.appointment);
}

class UpdateAppointment extends AppointmentEvent {
  final String appointmentId;
  final Appointment appointment;
  const UpdateAppointment({
    required this.appointmentId,
    required this.appointment,
  });
}

class DeleteAppointment extends AppointmentEvent {
  final String appointmentId;
  const DeleteAppointment(this.appointmentId);
}
