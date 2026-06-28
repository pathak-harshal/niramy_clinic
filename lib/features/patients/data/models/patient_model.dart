import 'package:cloud_firestore/cloud_firestore.dart';

class Patient {
  final String? id; // Firestore document ID
  final String name;
  final String address;
  final String dateOfBirth;
  final String gender;
  final String mobileNumber;
  final String email;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Patient({
    this.id,
    required this.name,
    required this.address,
    required this.dateOfBirth,
    required this.gender,
    required this.mobileNumber,
    required this.email,
    required this.createdAt,
    this.updatedAt,
  });

  // Convert Patient to Firestore JSON
  Map<String, dynamic> toMap() => {
    'name': name,
    'address': address,
    'dateOfBirth': dateOfBirth,
    'gender': gender,
    'mobileNumber': mobileNumber,
    'email': email,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': DateTime.now().toIso8601String(),
  };

  // Create Patient from Firestore document
  factory Patient.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Patient(
      id: doc.id,
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      dateOfBirth: data['dateOfBirth'] ?? '',
      gender: data['gender'] ?? 'Male',
      mobileNumber: data['mobileNumber'] ?? '',
      email: data['email'] ?? '',
      createdAt: data['createdAt'] != null
          ? DateTime.parse(data['createdAt'])
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null
          ? DateTime.parse(data['updatedAt'])
          : null,
    );
  }
}
