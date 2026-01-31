class Vacancy {
  final String id;
  final String title;
  final String company;
  final String location;
  final String salaryRange;
  final String description;
  final List<String> tags;
  final String? companyLogoUrl;

  const Vacancy({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.salaryRange,
    required this.description,
    required this.tags,
    this.companyLogoUrl,
  });
}
