import '../models/vacancy.dart';

class MockVacancyService {
  static List<Vacancy> getVacancies() {
    return const [
      Vacancy(
        id: '1',
        title: 'Senior Flutter Developer',
        company: 'TechCorp',
        location: 'New York, USA',
        salaryRange: '\$100k - \$150k',
        description:
            'We are looking for an experienced Flutter developer to join our team...',
        tags: ['Flutter', 'Dart', 'Mobile'],
        workFormat: 'Remote',
        experience: '5+ years',
      ),
      Vacancy(
        id: '2',
        title: 'UI/UX Designer',
        company: 'Creative Studio',
        location: 'London, UK',
        salaryRange: '£40k - £60k',
        description:
            'Creative designer needed for mobile and web apps. Figma expert required.',
        tags: ['Figma', 'Design', 'Prototyping'],
        workFormat: 'Hybrid',
        experience: '3-5 years',
      ),
      Vacancy(
        id: '3',
        title: 'Backend Engineer (Go)',
        company: 'StreamScale',
        location: 'Berlin, Germany',
        salaryRange: '€70k - €90k',
        description:
            'Scalable backend systems expert needed. Go and Kubernetes experience is a plus.',
        tags: ['Go', 'Kubernetes', 'Backend'],
        workFormat: 'Office',
        experience: '3-5 years',
      ),
      Vacancy(
        id: '4',
        title: 'Junior Flutter Developer',
        company: 'StartUp Inc',
        location: 'Remote',
        salaryRange: '\$40k - \$60k',
        description: 'Great opportunity for juniors to learn and grow.',
        tags: ['Flutter', 'Dart'],
        workFormat: 'Remote',
        experience: '0-1 year',
      ),
      Vacancy(
        id: '5',
        title: 'Product Manager',
        company: 'BigTech',
        location: 'San Francisco, USA',
        salaryRange: '\$130k - \$180k',
        description: 'Lead product development for our core mobile app.',
        tags: ['Product', 'Agile', 'scrum'],
        workFormat: 'Office',
        experience: '5+ years',
      ),
    ];
  }
}
