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

  // Company info — populated by enriching from employers/{employerId} or from vacancy doc itself
  final String company;       // company name
  final String companyLogo;   // base64 data URL or network URL, empty = use icon

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
    this.company = '',
    this.companyLogo = '',
  });

  factory Vacancy.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Vacancy(
      id: doc.id,
      employerId: data['employerId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      salary: data['salary'] ?? data['salaryRange'] ?? '',
      location: data['location'] ?? '',
      workType: data['workType'] ?? data['workFormat'] ?? 'Office',
      skills: List<String>.from(data['skills'] ?? data['tags'] ?? []),
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      company: (data['company'] as String? ?? '').trim(),
      companyLogo: (data['companyLogo'] as String? ??
              data['companyLogoUrl'] as String? ??
              '')
          .trim(),
    );
  }

  /// Returns a copy with employer info applied
  Vacancy withEmployer({required String name, required String logo}) {
    return Vacancy(
      id: id,
      employerId: employerId,
      title: title,
      description: description,
      salary: salary,
      location: location,
      workType: workType,
      skills: skills,
      createdAt: createdAt,
      company: name.isNotEmpty ? name : company,
      companyLogo: logo.isNotEmpty ? logo : companyLogo,
    );
  }
}
