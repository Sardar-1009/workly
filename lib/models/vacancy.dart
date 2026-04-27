import 'package:cloud_firestore/cloud_firestore.dart';

class Vacancy {
  final String id;
  final String employerId;
  final String title;
  final String description;
  final String salary;
  final String location;
  final String workType;
  final List<String> skills;
  final DateTime? createdAt;
  
  // UI Helpers (Might be missing from strict DB schema but useful locally)
  final String company;
  final String? companyLogoUrl;

  const Vacancy({
    required this.id,
    required this.employerId,
    required this.title,
    required this.description,
    required this.salary,
    required this.location,
    required this.workType,
    required this.skills,
    this.createdAt,
    this.company = 'Company Name',
    this.companyLogoUrl,
  });

  factory Vacancy.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Vacancy(
      id: doc.id,
      employerId: data['employerId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      salary: data['salary'] ?? data['salaryRange'] ?? '',
      location: data['location'] ?? '',
      workType: data['workType'] ?? data['workFormat'] ?? 'Office',
      skills: List<String>.from(data['skills'] ?? data['tags'] ?? []),
      createdAt: data['createdAt'] != null ? (data['createdAt'] as Timestamp).toDate() : null,
      company: data['company'] ?? 'Company Name', // Kept for backwards compatibility
      companyLogoUrl: data['companyLogoUrl'],
    );
  }
}
