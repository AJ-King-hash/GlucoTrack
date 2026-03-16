import 'package:flutter/material.dart';

class FilterChipWidget extends StatelessWidget {
  final List<String> options;
  final String? selectedOption;
  final ValueChanged<String?> onSelected;
  final String label;

  const FilterChipWidget({
    super.key,
    required this.options,
    required this.selectedOption,
    required this.onSelected,
    this.label = 'Filter',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(label, style: Theme.of(context).textTheme.titleSmall),
          ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            // All option
            FilterChip(
              label: const Text('All'),
              selected: selectedOption == null,
              onSelected: (selected) {
                if (selected) {
                  onSelected(null);
                }
              },
            ),
            // Filter options
            ...options.map(
              (option) => FilterChip(
                label: Text(option),
                selected: selectedOption == option,
                onSelected: (selected) {
                  onSelected(selected ? option : null);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class FilterBottomSheet extends StatelessWidget {
  final List<FilterOption> options;
  final Map<String, String?> currentFilters;
  final ValueChanged<Map<String, String?>> onApply;

  const FilterBottomSheet({
    super.key,
    required this.options,
    required this.currentFilters,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Filters', style: Theme.of(context).textTheme.titleLarge),
              TextButton(
                onPressed: () {
                  onApply({});
                  Navigator.pop(context);
                },
                child: const Text('Clear All'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...options.map((option) => _buildFilterSection(context, option)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                onApply(currentFilters);
                Navigator.pop(context);
              },
              child: const Text('Apply Filters'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(BuildContext context, FilterOption option) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(option.label, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                option.values.map((value) {
                  final isSelected = currentFilters[option.key] == value.value;
                  return FilterChip(
                    label: Text(value.label),
                    selected: isSelected,
                    onSelected: (selected) {
                      final newFilters = Map<String, String?>.from(
                        currentFilters,
                      );
                      if (selected) {
                        newFilters[option.key] = value.value;
                      } else {
                        newFilters.remove(option.key);
                      }
                      onApply(newFilters);
                    },
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }
}

class FilterOption {
  final String key;
  final String label;
  final List<FilterValue> values;

  const FilterOption({
    required this.key,
    required this.label,
    required this.values,
  });
}

class FilterValue {
  final String label;
  final String? value;

  const FilterValue({required this.label, this.value});
}
