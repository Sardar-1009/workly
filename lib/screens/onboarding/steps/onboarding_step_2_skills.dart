import 'package:flutter/material.dart';

class OnboardingStep2Skills extends StatelessWidget {
  final List<String> selectedSkills;
  final Function(String) onToggle;

  const OnboardingStep2Skills({
    super.key,
    required this.selectedSkills,
    required this.onToggle,
  });

  final List<String> _skills = const [
    'Flutter',
    'Dart',
    'React',
    'JavaScript',
    'TypeScript',
    'Python',
    'Java',
    'Kotlin',
    'Swift',
    'Node.js',
    'Firebase',
    'SQL',
    'UI/UX Design',
    'Product Management',
    'Marketing',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'What are your top skills?',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select up to 5 skills.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey,
              ),
        ),
        const SizedBox(height: 32),
        Expanded(
          child: SingleChildScrollView(
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _skills.map((skill) {
                final isSelected = selectedSkills.contains(skill);
                return FilterChip(
                  label: Text(skill),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected && selectedSkills.length >= 5) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('You can select up to 5 skills'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                      return;
                    }
                    onToggle(skill);
                  },
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  selectedColor: Theme.of(context).colorScheme.primaryContainer,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? Theme.of(context).colorScheme.onPrimaryContainer
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey.shade300,
                    ),
                  ),
                  showCheckmark: false,
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
