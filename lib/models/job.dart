import 'package:cloud_firestore/cloud_firestore.dart';

class Job {
  final String id;
  final String title;
  final String organisation;
  final String location;
  final String details;
  final double salaryPerWeek;
  final DateTime createdAt;

  Job({
    required this.id,
    required this.title,
    required this.organisation,
    required this.location,
    required this.details,
    required this.salaryPerWeek,
    required this.createdAt,
  });

  factory Job.fromMap(Map<String, dynamic> data, String documentId) {
    return Job(
      id: documentId,
      title: data['title'] ?? '',
      organisation: data['organisation'] ?? '',
      location: data['location'] ?? '',
      details: data['details'] ?? '',
      salaryPerWeek: data['salaryPerWeek'] is num
          ? (data['salaryPerWeek'] as num).toDouble()
          : 0.0,
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'organisation': organisation,
      'location': location,
      'details': details,
      'salaryPerWeek': salaryPerWeek,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
