class UserProfile {
  String name;
  String surname;
  String email;
  String experience;
  List<String> interests;
  String? resumePath;
  String? resumeSize;
  String? resumeDate;

  UserProfile({
    this.name = '',
    this.surname = '',
    this.email = '',
    this.experience = 'No Experience',
    this.interests = const [],
    this.resumePath,
    this.resumeSize,
    this.resumeDate,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'surname': surname,
        'email': email,
        'experience': experience,
        'interests': interests,
        'resumePath': resumePath,
        'resumeSize': resumeSize,
        'resumeDate': resumeDate,
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
    );
  }
}
