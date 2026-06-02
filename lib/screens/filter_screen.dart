import 'package:flutter/material.dart';

class FilterResult {
  final RangeValues salaryRange;
  final String? workType;
  final String? experience;
  final String? city;

  FilterResult({
    required this.salaryRange,
    this.workType,
    this.experience,
    this.city,
  });
}

class FilterScreen extends StatefulWidget {
  final FilterResult? initialFilters;

  const FilterScreen({super.key, this.initialFilters});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  RangeValues _salaryRange = const RangeValues(0, 200); // k$
  String? _workType; // full-time, part-time, etc.
  String? _experience; // 0-1, 1-3, 3-5, 5+
  String? _city; // City filter

  final Map<String, String> _workTypeLabels = {
    'full-time': 'Полная занятость',
    'part-time': 'Частичная занятость',
    'contract': 'Контракт',
    'freelance': 'Фриланс',
    'internship': 'Стажировка',
  };

  final List<String> _cities = [
    'Бишкек',
    'Ош',
    'Джалал-Абад',
    'Каракол',
    'Алматы',
    'Астана',
    'Ташкент',
    'Москва',
    'Санкт-Петербург',
    'Казань',
    'Удаленно'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialFilters != null) {
      _salaryRange = widget.initialFilters!.salaryRange;
      _workType = widget.initialFilters!.workType;
      _experience = widget.initialFilters!.experience;
      _city = widget.initialFilters!.city;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      height: MediaQuery.of(context).size.height * 0.85,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Фильтры',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Salary
          const Text('Диапазон зарплаты (\$)',
              style: TextStyle(fontWeight: FontWeight.bold)),
          RangeSlider(
            values: _salaryRange,
            min: 0,
            max: 300,
            divisions: 30,
            labels: RangeLabels(
              '\$${_salaryRange.start.round()}',
              '\$${_salaryRange.end.round()}',
            ),
            onChanged: (values) {
              setState(() {
                _salaryRange = values;
              });
            },
          ),

          const SizedBox(height: 24),

          // City
          const Text('Город', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _city,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            hint: const Text('Выберите город...'),
            items: [
              const DropdownMenuItem(value: null, child: Text('Все города')),
              ..._cities.map((city) => DropdownMenuItem(
                    value: city,
                    child: Text(city),
                  ))
            ],
            onChanged: (val) {
              setState(() {
                _city = val;
              });
            },
          ),

          const SizedBox(height: 24),

          // Format
          const Text('Тип занятости',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _workTypeLabels.entries.map((entry) {
              final isSelected = _workType == entry.key;
              return ChoiceChip(
                label: Text(entry.value),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() => _workType = selected ? entry.key : null);
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // Experience
          const Text('Опыт работы',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                ['Без опыта', '1-3 года', '3-5 лет', '5+ лет'].map((exp) {
              final isSelected = _experience == exp;
              return ChoiceChip(
                label: Text(exp),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() => _experience = selected ? exp : null);
                },
              );
            }).toList(),
          ),

          const Spacer(),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () =>
                      Navigator.pop(context), // Clear? Or just Cancel
                  child: const Text('Отмена'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(
                          context,
                          FilterResult(
                              salaryRange: _salaryRange,
                              workType: _workType,
                              experience: _experience,
                              city: _city));
                    },
                    child: const Text('Применить')),
              ),
            ],
          )
        ],
      ),
    );
  }
}
