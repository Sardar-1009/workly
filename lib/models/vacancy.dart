import 'package:cloud_firestore/cloud_firestore.dart';

class Vacancy {
  final String id;
  final String title;
  final String company;
  final String location;
  final String salaryRange;
  final String description;
  final List<String> tags;
  final String? companyLogoUrl;

  // New Fields for Filters
  final String workFormat; // Remote, Office, Hybrid
  final String experience; // 0-1, 1-3, 3-5, 5+
  final String employerId; // Add employerId field

  const Vacancy({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.salaryRange,
    required this.description,
    required this.tags,
    this.companyLogoUrl,
    this.workFormat = 'Office',
    this.experience = '1-3 years',
    this.employerId = '',
  });

  factory Vacancy.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Vacancy(
      id: doc.id,
      title: data['title'] ?? '',
      company: data['company'] ?? 'Company Name',
      location: data['location'] ?? '',
      salaryRange: data['salaryRange'] ?? data['salary'] ?? '',
      description: data['description'] ?? '',
      tags: List<String>.from(data['tags'] ?? data['requirements'] ?? []),
      companyLogoUrl: data['companyLogoUrl'],
      workFormat: data['workFormat'] ?? 'Office',
      experience: data['experience'] ?? '1-3 years',
      employerId: data['employerId'] ?? '',
    );
  }
}
