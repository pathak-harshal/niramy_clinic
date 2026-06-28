import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/appointment_model.dart';

class AppointmentRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _appointmentsCollection = 'appointments';

  Future<String> addAppointment(Appointment appointment) async {
    try {
      final docRef = await _firestore
          .collection(_appointmentsCollection)
          .add(appointment.toMap());
      return docRef.id;
    } on FirebaseException catch (e) {
      throw Exception('Failed to add appointment: ${e.message}');
    } catch (e) {
      throw Exception('Failed to add appointment: $e');
    }
  }

  Future<Appointment?> getAppointment(String appointmentId) async {
    try {
      final doc = await _firestore
          .collection(_appointmentsCollection)
          .doc(appointmentId)
          .get();
      if (doc.exists) {
        return Appointment.fromFirestore(doc);
      }
      return null;
    } on FirebaseException catch (e) {
      throw Exception('Failed to fetch appointment: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch appointment: $e');
    }
  }

  Future<void> updateAppointment(
    String appointmentId,
    Appointment appointment,
  ) async {
    try {
      await _firestore
          .collection(_appointmentsCollection)
          .doc(appointmentId)
          .update(appointment.toMap());
    } on FirebaseException catch (e) {
      throw Exception('Failed to update appointment: ${e.message}');
    } catch (e) {
      throw Exception('Failed to update appointment: $e');
    }
  }

  Future<List<Appointment>> getAllAppointments() async {
    try {
      final querySnapshot = await _firestore
          .collection(_appointmentsCollection)
          .orderBy('appointmentDate', descending: true)
          .get();
      return querySnapshot.docs.map(Appointment.fromFirestore).toList();
    } on FirebaseException catch (e) {
      throw Exception('Failed to fetch appointments: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch appointments: $e');
    }
  }

  Future<List<Appointment>> getAppointmentsByDate(DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      final querySnapshot = await _firestore
          .collection(_appointmentsCollection)
          .where(
            'appointmentDate',
            isGreaterThanOrEqualTo: startOfDay.toIso8601String(),
          )
          .where(
            'appointmentDate',
            isLessThanOrEqualTo: endOfDay.toIso8601String(),
          )
          .orderBy('appointmentDate')
          .get();
      return querySnapshot.docs.map(Appointment.fromFirestore).toList();
    } on FirebaseException catch (e) {
      throw Exception('Failed to fetch appointments by date: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch appointments by date: $e');
    }
  }

  Future<void> deleteAppointment(String appointmentId) async {
    try {
      await _firestore
          .collection(_appointmentsCollection)
          .doc(appointmentId)
          .delete();
    } on FirebaseException catch (e) {
      throw Exception('Failed to delete appointment: ${e.message}');
    } catch (e) {
      throw Exception('Failed to delete appointment: $e');
    }
  }
}
