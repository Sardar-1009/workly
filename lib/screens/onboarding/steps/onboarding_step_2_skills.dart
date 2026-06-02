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
          'Какие у вас ключевые навыки?',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Выберите до 5 навыков.',
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
                          content: Text('Можно выбрать не более 5 навыков'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                      return;
                    }
                    onToggle(skill);
                  },
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  selectedColor: Theme.of(context).colorScheme.primaryContainer,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  labelStyle: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? Theme.of(context).colorScheme.onPrimaryContainer
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
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
