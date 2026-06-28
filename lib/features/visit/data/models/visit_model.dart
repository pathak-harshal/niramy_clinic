import 'package:cloud_firestore/cloud_firestore.dart';

class Visit {
  final String? id;
  final String patientId;
  final String patientName;
  final DateTime visitDate;
  final String visitType; // New, Follow Up
  final String chiefComplaint;
  final String diagnosis;
  final String prescription;
  final String notes;
  final DateTime? followUpDate;
  final String status; // Open, Closed
  final DateTime createdAt;
  final DateTime? updatedAt;

  Visit({
    this.id,
    required this.patientId,
    required this.patientName,
    required this.visitDate,
    required this.visitType,
    required this.chiefComplaint,
    required this.diagnosis,
    required this.prescription,
    required this.notes,
    this.followUpDate,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
    'patientId': patientId,
    'patientName': patientName,
    'visitDate': visitDate.toIso8601String(),
    'visitType': visitType,
    'chiefComplaint': chiefComplaint,
    'diagnosis': diagnosis,
    'prescription': prescription,
    'notes': notes,
    'followUpDate': followUpDate?.toIso8601String(),
    'status': status,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': DateTime.now().toIso8601String(),
  };

  static DateTime _parseDate(dynamic value, DateTime fallback) {
    if (value == null) return fallback;
    if (value is Timestamp) return value.toDate();
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value) ?? fallback;
    }
    return fallback;
  }

  factory Visit.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final now = DateTime.now();

    return Visit(
      id: doc.id,
      patientId: data['patientId'] ?? '',
      patientName: data['patientName'] ?? '',
      visitDate: _parseDate(data['visitDate'], now),
      visitType: data['visitType'] ?? 'New',
      chiefComplaint: data['chiefComplaint'] ?? '',
      diagnosis: data['diagnosis'] ?? '',
      prescription: data['prescription'] ?? '',
      notes: data['notes'] ?? '',
      followUpDate: data['followUpDate'] != null
          ? _parseDate(data['followUpDate'], now)
          : null,
      status: data['status'] ?? 'Open',
      createdAt: _parseDate(data['createdAt'], now),
      updatedAt: data['updatedAt'] != null
          ? _parseDate(data['updatedAt'], now)
          : null,
    );
  }
}