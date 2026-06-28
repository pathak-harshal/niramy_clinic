import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/patient_model.dart';

class PatientRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _patientsCollection = 'patients';

  // Add a new patient
  Future<String> addPatient(Patient patient) async {
    try {
      final docRef = await _firestore
          .collection(_patientsCollection)
          .add(patient.toMap());
      return docRef.id;
    } on FirebaseException catch (e) {
      throw Exception('Failed to add patient: ${e.message}');
    } catch (e) {
      throw Exception('Failed to add patient: $e');
    }
  }

  // Get patient by ID
  Future<Patient?> getPatient(String patientId) async {
    try {
      final doc = await _firestore
          .collection(_patientsCollection)
          .doc(patientId)
          .get();
      if (doc.exists) {
        return Patient.fromFirestore(doc);
      }
      return null;
    } on FirebaseException catch (e) {
      throw Exception('Failed to fetch patient: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch patient: $e');
    }
  }

  // Update an existing patient
  Future<void> updatePatient(String patientId, Patient patient) async {
    try {
      await _firestore
          .collection(_patientsCollection)
          .doc(patientId)
          .update(patient.toMap());
    } on FirebaseException catch (e) {
      throw Exception('Failed to update patient: ${e.message}');
    } catch (e) {
      throw Exception('Failed to update patient: $e');
    }
  }

  // Get all patients
  Future<List<Patient>> getAllPatients() async {
    try {
      final querySnapshot = await _firestore
          .collection(_patientsCollection)
          .orderBy('createdAt')
          .get();
      return querySnapshot.docs.map(Patient.fromFirestore).toList();
    } on FirebaseException catch (e) {
      throw Exception('Failed to fetch patients: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch patients: $e');
    }
  }

  // Delete a patient
  Future<void> deletePatient(String patientId) async {
    try {
      await _firestore.collection(_patientsCollection).doc(patientId).delete();
    } on FirebaseException catch (e) {
      throw Exception('Failed to delete patient: ${e.message}');
    } catch (e) {
      throw Exception('Failed to delete patient: $e');
    }
  }
}
