// lib/ui/components/search_bar_widget.dart
import 'package:flutter/material.dart';

/// Component for the search bar and filter icon.
class SearchBarWidget extends StatelessWidget {
  final VoidCallback onFilterPressed;
  final TextEditingController? controller;
  final bool showFilters;

  const SearchBarWidget({
    super.key,
    required this.onFilterPressed,
    this.controller,
    this.showFilters = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha:0.3)),
            ),
            child: TextField(
              controller: controller,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: 'Search by name, type..',
                hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.6)),
                border: InputBorder.none,
                icon: Icon(Icons.search, color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.6)),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector( // Using GestureDetector for the filter button
          onTap: onFilterPressed,
          child: Container(
            decoration: BoxDecoration(
              color: showFilters 
                  ? Theme.of(context).colorScheme.primary 
                  : Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(12),
            child: Icon(
              showFilters ? Icons.filter_list : Icons.filter_list_off,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
