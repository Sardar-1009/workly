import 'package:flutter/material.dart';

class OnboardingStep3Education extends StatelessWidget {
  final String? selectedEducation;
  final ValueChanged<String> onSelect;

  const OnboardingStep3Education({
    super.key,
    required this.selectedEducation,
    required this.onSelect,
  });

  final List<String> _options = const [
    'High School',
    'Associate Degree',
    'Bachelor\'s Degree',
    'Master\'s Degree',
    'PhD or equivalent',
    'Self-taught / Bootcamp',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'What is your highest level of education?',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Employers often filter by education level.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey,
              ),
        ),
        const SizedBox(height: 32),
        Expanded(
          child: ListView.separated(
            itemCount: _options.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final option = _options[index];
              final isSelected = option == selectedEducation;
              return InkWell(
                onTap: () => onSelect(option),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primaryContainer
                        : Theme.of(context).colorScheme.surface,
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey.shade300,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          option,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isSelected
                                ? Theme.of(context).colorScheme.onPrimaryContainer
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                      if (isSelected)
                        Icon(Icons.check_circle,
                            color: Theme.of(context).colorScheme.primary),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
