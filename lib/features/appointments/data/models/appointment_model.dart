import 'package:cloud_firestore/cloud_firestore.dart';

class Appointment {
  final String? id;
  final String patientId;
  final String patientName;
  final String appointmentType; // 'New' or 'Follow Up'
  final DateTime appointmentDate;
  final String startTime; // e.g., '09:00 AM'
  final String endTime; // e.g., '09:30 AM'
  final String status; // 'Scheduled', 'Completed', 'Cancelled'
  final DateTime createdAt;
  final DateTime? updatedAt;

  Appointment({
    this.id,
    required this.patientId,
    required this.patientName,
    required this.appointmentType,
    required this.appointmentDate,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
    'patientId': patientId,
    'patientName': patientName,
    'appointmentType': appointmentType,
    'appointmentDate': appointmentDate.toIso8601String(),
    'startTime': startTime,
    'endTime': endTime,
    'status': status,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': DateTime.now().toIso8601String(),
  };

  factory Appointment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Appointment(
      id: doc.id,
      patientId: data['patientId'] ?? '',
      patientName: data['patientName'] ?? '',
      appointmentType: data['appointmentType'] ?? 'New',
      appointmentDate: data['appointmentDate'] != null
          ? DateTime.parse(data['appointmentDate'])
          : DateTime.now(),
      startTime: data['startTime'] ?? '',
      endTime: data['endTime'] ?? '',
      status: data['status'] ?? 'Scheduled',
      createdAt: data['createdAt'] != null
          ? DateTime.parse(data['createdAt'])
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null
          ? DateTime.parse(data['updatedAt'])
          : null,
    );
  }
}