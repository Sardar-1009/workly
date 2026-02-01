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
  });
}
