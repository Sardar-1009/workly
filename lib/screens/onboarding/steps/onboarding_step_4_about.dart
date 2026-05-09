import 'package:flutter/material.dart';

class OnboardingStep4About extends StatelessWidget {
  final String aboutText;
  final ValueChanged<String> onChanged;

  const OnboardingStep4About({
    super.key,
    required this.aboutText,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Расскажите о себе',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Краткое био поможет работодателям понять, кто вы и в чем ваши сильные стороны.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey,
              ),
        ),
        const SizedBox(height: 32),
        Expanded(
          child: SingleChildScrollView(
            child: TextField(
              controller: TextEditingController(text: aboutText)
                ..selection = TextSelection.collapsed(offset: aboutText.length), // Keep cursor at end
              onChanged: onChanged,
              maxLines: 8,
              maxLength: 500,
              decoration: InputDecoration(
                hintText: 'Я страстный разработчик с 5-летним опытом в...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
