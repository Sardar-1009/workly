import 'package:flutter/material.dart';

class OnboardingStep5Priorities extends StatelessWidget {
  final List<String> selectedPriorities;
  final Function(String) onToggle;

  const OnboardingStep5Priorities({
    super.key,
    required this.selectedPriorities,
    required this.onToggle,
  });

  final List<String> _priorities = const [
    'Meaningful work',
    'Experienced leaders',
    'Top investors',
    'Wear many hats',
    'Work with smart people',
    'Challenging work',
    'Growing fast',
    'Cool startup',
    'Stable company',
    'Innovative technology',
    'Flexible hours',
    'Great benefits',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'What’s most important in a new job?',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'This will be used to calibrate your job matches.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select ${selectedPriorities.length}/3 interests',
          style: TextStyle(
            color: selectedPriorities.length == 3 ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 32),
        Expanded(
          child: SingleChildScrollView(
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _priorities.map((priority) {
                final isSelected = selectedPriorities.contains(priority);
                return FilterChip(
                  label: Text(priority),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected && selectedPriorities.length >= 3) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Select up to 3'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                      return;
                    }
                    onToggle(priority);
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
