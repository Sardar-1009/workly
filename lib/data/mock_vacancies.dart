import '../models/vacancy.dart';

class MockVacancyService {
  static List<Vacancy> getVacancies() {
    return const [
      Vacancy(
        id: '1',
        title: 'Senior Flutter Developer',
        company: 'TechCorp',
        location: 'San Francisco, CA (Remote)',
        salaryRange: '\$140k - \$180k',
        description:
            'We are looking for an experienced Flutter developer to lead our mobile team. You will be building the next generation of our fintech app.',
        tags: ['Flutter', 'Dart', 'Mobile', 'Fintech'],
      ),
      Vacancy(
        id: '2',
        title: 'Product Designer',
        company: 'Creative Studio',
        location: 'New York, NY',
        salaryRange: '\$110k - \$150k',
        description:
            'Join our award-winning design team. You will be responsible for creating intuitive and beautiful user interfaces for our clients.',
        tags: ['UI/UX', 'Figma', 'Design System'],
      ),
      Vacancy(
        id: '3',
        title: 'Backend Engineer (Go)',
        company: 'StreamScale',
        location: 'Austin, TX',
        salaryRange: '\$130k - \$170k',
        description:
            'Scale our real-time data processing pipeline. Experience with Go, Kafka, and Kubernetes is required.',
        tags: ['Go', 'Backend', 'Kubernetes'],
      ),
      Vacancy(
        id: '4',
        title: 'Data Scientist',
        company: 'AI Solutions',
        location: 'Remote',
        salaryRange: '\$150k - \$200k',
        description:
            'Build predictive models and analyze large datasets to uncover insights. Proficiency in Python, PyTorch, and SQL is needed.',
        tags: ['Python', 'Machine Learning', 'Data Science'],
      ),
      Vacancy(
        id: '5',
        title: 'Frontend Developer (React)',
        company: 'Webify',
        location: 'London, UK',
        salaryRange: '£60k - £80k',
        description:
            'Create responsive and accessible web applications using React and TypeScript. Knowledge of Next.js is a plus.',
        tags: ['React', 'TypeScript', 'Frontend'],
      ),
    ];
  }
}
