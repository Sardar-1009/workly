class UserPreferences {
  String experienceLevel;
  List<String> jobCategories;
  String jobUrgency;
  int salaryMin;
  int salaryMax;
  List<String> jobPriorities;

  UserPreferences({
    this.experienceLevel = '',
    List<String>? jobCategories,
    this.jobUrgency = '',
    this.salaryMin = 0,
    this.salaryMax = 500000,
    List<String>? jobPriorities,
  })  : jobCategories = jobCategories ?? [],
        jobPriorities = jobPriorities ?? [];

  Map<String, dynamic> toJson() => {
        'experienceLevel': experienceLevel,
        'jobCategories': jobCategories,
        'jobUrgency': jobUrgency,
        'salaryMin': salaryMin,
        'salaryMax': salaryMax,
        'jobPriorities': jobPriorities,
      };

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      experienceLevel: json['experienceLevel'] ?? '',
      jobCategories: List<String>.from(json['jobCategories'] ?? []),
      jobUrgency: json['jobUrgency'] ?? '',
      salaryMin: json['salaryMin'] ?? 0,
      salaryMax: json['salaryMax'] ?? 500000,
      jobPriorities: List<String>.from(json['jobPriorities'] ?? []),
    );
  }
}

class UserProfile {
  String name;
  String surname;
  String email;
  String experience;
  List<String> interests;
  String? resumePath;
  String? resumeSize;
  String? resumeDate;

  // Onboarding Data
  bool onboardingCompleted;
  UserPreferences preferences;

  UserProfile({
    this.name = '',
    this.surname = '',
    this.email = '',
    this.experience = 'No Experience',
    List<String>? interests,
    this.resumePath,
    this.resumeSize,
    this.resumeDate,
    this.onboardingCompleted = false,
    UserPreferences? preferences,
  })  : interests = interests ?? [],
        preferences = preferences ?? UserPreferences();

  Map<String, dynamic> toJson() => {
        'name': name,
        'surname': surname,
        'email': email,
        'experience': experience,
        'interests': interests,
        'resumePath': resumePath,
        'resumeSize': resumeSize,
        'resumeDate': resumeDate,
        'onboardingCompleted': onboardingCompleted,
        'preferences': preferences.toJson(),
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] ?? '',
      surname: json['surname'] ?? '',
      email: json['email'] ?? '',
      experience: json['experience'] ?? 'No Experience',
      interests: List<String>.from(json['interests'] ?? []),
      resumePath: json['resumePath'],
      resumeSize: json['resumeSize'],
      resumeDate: json['resumeDate'],
      onboardingCompleted: json['onboardingCompleted'] ?? false,
      preferences: json['preferences'] != null
          ? UserPreferences.fromJson(json['preferences'])
          : null,
    );
  }
}
