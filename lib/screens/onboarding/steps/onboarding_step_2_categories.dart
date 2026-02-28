import 'package:flutter/material.dart';

class OnboardingStep2Categories extends StatelessWidget {
  final List<String> selectedCategories;
  final Function(String) onToggle;

  const OnboardingStep2Categories({
    super.key,
    required this.selectedCategories,
    required this.onToggle,
  });

  final List<String> _categories = const [
    'Software Engineering',
    'Healthcare',
    'Consulting',
    'Data',
    'Design',
    'Finance',
    'Legal',
    'Human Resources',
    'Marketing',
    'Operations & Strategy',
    'Product',
    'Sales',
    'Customer Success',
    'Security',
    'Misc. Engineering',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'What kind of job are you looking for?',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select up to 3 job categories that interest you most.',
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
              children: _categories.map((category) {
                final isSelected = selectedCategories.contains(category);
                return FilterChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected && selectedCategories.length >= 3) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('You can select up to 3 categories'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                      return;
                    }
                    onToggle(category);
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
