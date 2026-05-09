import 'package:flutter/material.dart';

class OnboardingStep5Resume extends StatefulWidget {
  final String resumeLink;
  final ValueChanged<String> onChanged;
  final VoidCallback onSkip;

  const OnboardingStep5Resume({
    super.key,
    required this.resumeLink,
    required this.onChanged,
    required this.onSkip,
  });

  @override
  State<OnboardingStep5Resume> createState() => _OnboardingStep5ResumeState();
}

class _OnboardingStep5ResumeState extends State<OnboardingStep5Resume> {
  late final TextEditingController _controller;
  bool _showError = false;

  static const String _urlPattern =
      r'^(https?:\/\/)?([\w\-]+\.)+[\w\-]+(\/[\w\-./?%&=]*)?$';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.resumeLink);
    _controller.addListener(() {
      widget.onChanged(_controller.text.trim());
      if (_showError) setState(() => _showError = false);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isValidUrl {
    final text = _controller.text.trim();
    if (text.isEmpty) return false;
    return RegExp(_urlPattern).hasMatch(text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Text(
          'Добавьте резюме',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Работодатели смогут сразу ознакомиться с вашим опытом.',
          style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey),
        ),
        const SizedBox(height: 28),

        // Instruction Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withOpacity(0.35),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: colorScheme.primary.withOpacity(0.25),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      color: colorScheme.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Как добавить резюме?',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _InstructionStep(
                number: '1',
                text: 'Откройте ',
                linkText: 'Google Диск',
                afterText: ' и загрузите файл резюме (PDF или Word).',
              ),
              const SizedBox(height: 8),
              _InstructionStep(
                number: '2',
                text:
                    'Нажмите правой кнопкой мыши на файл → «Открыть доступ» → выберите «Все, у кого есть ссылка».',
              ),
              const SizedBox(height: 8),
              _InstructionStep(
                number: '3',
                text: 'Скопируйте ссылку и вставьте её в поле ниже.',
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lightbulb_outline_rounded,
                        size: 16,
                        color: Colors.amber.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Также можно использовать Яндекс.Диск, OneDrive или любой другой облачный сервис.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Input Field
        TextField(
          controller: _controller,
          keyboardType: TextInputType.url,
          autocorrect: false,
          decoration: InputDecoration(
            labelText: 'Ссылка на резюме',
            hintText: 'https://drive.google.com/file/d/...',
            prefixIcon: Icon(
              Icons.link_rounded,
              color: colorScheme.primary,
            ),
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded),
                    onPressed: () {
                      _controller.clear();
                      widget.onChanged('');
                    },
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: colorScheme.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
            errorText: _showError ? 'Введите корректную ссылку' : null,
            filled: true,
            fillColor: colorScheme.surface,
          ),
        ),

        const SizedBox(height: 12),

        // Valid URL badge
        if (_isValidUrl)
          Row(
            children: [
              Icon(Icons.check_circle_rounded,
                  size: 16, color: Colors.green.shade600),
              const SizedBox(width: 6),
              Text(
                'Ссылка выглядит корректно',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

        const Spacer(),

        // Skip button at bottom
        Center(
          child: TextButton.icon(
            onPressed: widget.onSkip,
            icon: Icon(Icons.skip_next_rounded,
                size: 18, color: Colors.grey.shade600),
            label: Text(
              'Пропустить',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

// ─── Helper widget ────────────────────────────────────────────────────────────

class _InstructionStep extends StatelessWidget {
  final String number;
  final String text;
  final String? linkText;
  final String? afterText;

  const _InstructionStep({
    required this.number,
    required this.text,
    this.linkText,
    this.afterText,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text.rich(
            TextSpan(
              text: text,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(height: 1.5),
              children: [
                if (linkText != null)
                  TextSpan(
                    text: linkText,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                if (afterText != null)
                  TextSpan(
                    text: afterText,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(height: 1.5),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
