import 'package:flutter/material.dart';

class FilterResult {
  final RangeValues salaryRange;
  final String? workFormat;
  final String? experience;

  FilterResult({required this.salaryRange, this.workFormat, this.experience});
}

class FilterScreen extends StatefulWidget {
  final FilterResult? initialFilters;

  const FilterScreen({super.key, this.initialFilters});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  RangeValues _salaryRange = const RangeValues(0, 200); // k$
  String? _workFormat; // Remote, Office, Hybrid
  String? _experience; // 0-1, 1-3, 3-5, 5+

  @override
  void initState() {
    super.initState();
    if (widget.initialFilters != null) {
      _salaryRange = widget.initialFilters!.salaryRange;
      _workFormat = widget.initialFilters!.workFormat;
      _experience = widget.initialFilters!.experience;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      height: MediaQuery.of(context).size.height * 0.6,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Filters',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Salary
          const Text('Salary Range (k\$)',
              style: TextStyle(fontWeight: FontWeight.bold)),
          RangeSlider(
            values: _salaryRange,
            min: 0,
            max: 300,
            divisions: 30,
            labels: RangeLabels(
              '\$${_salaryRange.start.round()}k',
              '\$${_salaryRange.end.round()}k',
            ),
            onChanged: (values) {
              setState(() {
                _salaryRange = values;
              });
            },
          ),

          const SizedBox(height: 24),

          // Format
          const Text('Work Format',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ['Remote', 'Office', 'Hybrid'].map((format) {
              final isSelected = _workFormat == format;
              return ChoiceChip(
                label: Text(format),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() => _workFormat = selected ? format : null);
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // Experience
          const Text('Experience',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children:
                ['0-1 year', '1-3 years', '3-5 years', '5+ years'].map((exp) {
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
                  child: const Text('Cancel'),
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
                              workFormat: _workFormat,
                              experience: _experience));
                    },
                    child: const Text('Apply')),
              ),
            ],
          )
        ],
      ),
    );
  }
}
