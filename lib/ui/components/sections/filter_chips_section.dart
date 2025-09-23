// lib/ui/components/filter_chips_section.dart
import 'package:flutter/material.dart';

/// Component for the horizontal list of filter chips.
class FilterChipsSection extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onFilterSelected;
  final List<String> filters;

  const FilterChipsSection({
    super.key,
    required this.selectedFilter,
    required this.onFilterSelected,
    required this.filters,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40, // Fixed height for the row of chips
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final label = filters[index];
          bool isSelected = selectedFilter == label;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  onFilterSelected(label);
                }
              },
              selectedColor: Theme.of(context).colorScheme.primary,
              labelStyle: TextStyle(
                color: isSelected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              backgroundColor: Theme.of(context).colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: Theme.of(context).colorScheme.outline.withValues(alpha:0.3)),
              ),
            ),
          );
        },
      ),
    );
  }
}
