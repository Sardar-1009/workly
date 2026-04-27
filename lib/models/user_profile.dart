import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  String fullName;
  String email;
  List<String> skills;
  String experience;
  String education;
  String about;
  String photoUrl;
  String resumeUrl;       // URL загруженного резюме в Firebase Storage
  String resumeFileName;  // Оригинальное имя файла резюме
  DateTime? createdAt;

  // Local helper
  bool onboardingCompleted;

  UserProfile({
    this.fullName = '',
    this.email = '',
    List<String>? skills,
    this.experience = '',
    this.education = '',
    this.about = '',
    this.photoUrl = '',
    this.resumeUrl = '',
    this.resumeFileName = '',
    this.createdAt,
    this.onboardingCompleted = false,
  }) : skills = skills ?? [];

  Map<String, dynamic> toJson() => {
        'fullName': fullName,
        'email': email,
        'skills': skills,
        'experience': experience,
        'education': education,
        'about': about,
        'photoUrl': photoUrl,
        'resumeUrl': resumeUrl,
        'resumeFileName': resumeFileName,
        if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
        'onboardingCompleted': onboardingCompleted,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      fullName: json['fullName'] ?? json['name'] ?? '',
      email: json['email'] ?? '',
      skills: List<String>.from(json['skills'] ?? []),
      experience: json['experience'] ?? '',
      education: json['education'] ?? '',
      about: json['about'] ?? '',
      photoUrl: json['photoUrl'] ?? '',
      resumeUrl: json['resumeUrl'] ?? '',
      resumeFileName: json['resumeFileName'] ?? '',
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : null,
      onboardingCompleted: json['onboardingCompleted'] ?? false,
    );
  }
}
