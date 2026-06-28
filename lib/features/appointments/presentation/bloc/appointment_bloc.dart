import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/appointment_model.dart';
import '../../data/repositories/appointment_repository.dart';

part 'appointment_event.dart';
part 'appointment_state.dart';

class AppointmentBloc extends Bloc<AppointmentEvent, AppointmentState> {
  final AppointmentRepository repository;

  AppointmentBloc(this.repository) : super(const AppointmentInitial()) {
    on<LoadAppointments>(_onLoadAppointments);
    on<LoadAppointment>(_onLoadAppointment);
    on<AddAppointment>(_onAddAppointment);
    on<UpdateAppointment>(_onUpdateAppointment);
    on<DeleteAppointment>(_onDeleteAppointment);
  }

  Future<void> _onLoadAppointments(
    LoadAppointments event,
    Emitter<AppointmentState> emit,
  ) async {
    emit(const AppointmentLoading());
    try {
      final appointments = await repository.getAllAppointments();
      emit(AppointmentsLoadSuccess(appointments));
    } catch (e) {
      emit(AppointmentFailure(e.toString()));
    }
  }

  Future<void> _onLoadAppointment(
    LoadAppointment event,
    Emitter<AppointmentState> emit,
  ) async {
    emit(const AppointmentLoading());
    try {
      final appointment = await repository.getAppointment(event.appointmentId);
      if (appointment != null) {
        emit(AppointmentLoadSuccess(appointment));
      } else {
        emit(const AppointmentFailure('Appointment not found'));
      }
    } catch (e) {
      emit(AppointmentFailure(e.toString()));
    }
  }

  Future<void> _onAddAppointment(
    AddAppointment event,
    Emitter<AppointmentState> emit,
  ) async {
    emit(const AppointmentLoading());
    try {
      final id = await repository.addAppointment(event.appointment);
      emit(AppointmentOperationSuccess('Appointment added (id: $id)'));
    } catch (e) {
      emit(AppointmentFailure(e.toString()));
    }
  }

  Future<void> _onUpdateAppointment(
    UpdateAppointment event,
    Emitter<AppointmentState> emit,
  ) async {
    emit(const AppointmentLoading());
    try {
      await repository.updateAppointment(
        event.appointmentId,
        event.appointment,
      );
      emit(const AppointmentOperationSuccess('Appointment updated'));
    } catch (e) {
      emit(AppointmentFailure(e.toString()));
    }
  }

  Future<void> _onDeleteAppointment(
    DeleteAppointment event,
    Emitter<AppointmentState> emit,
  ) async {
    emit(const AppointmentLoading());
    try {
      await repository.deleteAppointment(event.appointmentId);
      emit(const AppointmentOperationSuccess('Appointment deleted'));
    } catch (e) {
      emit(AppointmentFailure(e.toString()));
    }
  }
}
