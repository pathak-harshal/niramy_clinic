import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/visit_model.dart';

class VisitRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _visitsCollection = 'visits';

  Future<String> addVisit(Visit visit) async {
    try {
      final docRef = await _firestore
          .collection(_visitsCollection)
          .add(visit.toMap());
      return docRef.id;
    } on FirebaseException catch (e) {
      throw Exception('Failed to add visit: ${e.message}');
    } catch (e) {
      throw Exception('Failed to add visit: $e');
    }
  }

  Future<Visit?> getVisit(String visitId) async {
    try {
      final doc = await _firestore
          .collection(_visitsCollection)
          .doc(visitId)
          .get();
      if (doc.exists) return Visit.fromFirestore(doc);
      return null;
    } on FirebaseException catch (e) {
      throw Exception('Failed to fetch visit: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch visit: $e');
    }
  }

  Future<void> updateVisit(String visitId, Visit visit) async {
    try {
      await _firestore
          .collection(_visitsCollection)
          .doc(visitId)
          .update(visit.toMap());
    } on FirebaseException catch (e) {
      throw Exception('Failed to update visit: ${e.message}');
    } catch (e) {
      throw Exception('Failed to update visit: $e');
    }
  }

  Future<List<Visit>> getAllVisits() async {
    try {
      final querySnapshot = await _firestore
          .collection(_visitsCollection)
          .orderBy('visitDate', descending: true)
          .get();

      return querySnapshot.docs.map(Visit.fromFirestore).toList();
    } on FirebaseException catch (e) {
      throw Exception('Failed to fetch visits: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch visits: $e');
    }
  }

  Future<List<Visit>> getVisitsByPatient(String patientId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_visitsCollection)
          .where('patientId', isEqualTo: patientId)
          .get();

      final visits = querySnapshot.docs.map(Visit.fromFirestore).toList()
        ..sort((a, b) => b.visitDate.compareTo(a.visitDate));

      return visits;
    } on FirebaseException catch (e) {
      throw Exception('Failed to fetch patient visits: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch patient visits: $e');
    }
  }

  Future<void> deleteVisit(String visitId) async {
    try {
      await _firestore.collection(_visitsCollection).doc(visitId).delete();
    } on FirebaseException catch (e) {
      throw Exception('Failed to delete visit: ${e.message}');
    } catch (e) {
      throw Exception('Failed to delete visit: $e');
    }
  }
}