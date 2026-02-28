import 'package:flutter/material.dart';

class OnboardingStep4Salary extends StatelessWidget {
  final int salaryMin;
  final int salaryMax;
  final Function(int min, int max) onRangeChanged;

  const OnboardingStep4Salary({
    super.key,
    required this.salaryMin,
    required this.salaryMax,
    required this.onRangeChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Ensure values are within range 0-500000
    // If not, use defaults or clamp
    RangeValues currentRangeValues = RangeValues(
      salaryMin.toDouble().clamp(0, 500000),
      salaryMax.toDouble().clamp(0, 500000),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Expected salary range?',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Set your expected salary range to help match you with the right jobs.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey,
              ),
        ),
        const SizedBox(height: 48),

        // Display current values
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSalaryBox(context, 'Min', currentRangeValues.start.round()),
            _buildSalaryBox(context, 'Max', currentRangeValues.end.round()),
          ],
        ),
        const SizedBox(height: 32),

        // Slider
        RangeSlider(
          values: currentRangeValues,
          min: 0,
          max: 500000,
          divisions: 100, // 5000 steps
          labels: RangeLabels(
            '\$${currentRangeValues.start.round()}',
            '\$${currentRangeValues.end.round()}',
          ),
          onChanged: (RangeValues values) {
            onRangeChanged(values.start.round(), values.end.round());
          },
          activeColor: Theme.of(context).colorScheme.primary,
          inactiveColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('\$0', style: TextStyle(color: Colors.grey)),
              Text('\$500k+', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSalaryBox(BuildContext context, String label, int value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '\$${value.toString()}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
