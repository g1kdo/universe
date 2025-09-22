// lib/ui/components/search_bar_widget.dart
import 'package:flutter/material.dart';

/// Component for the search bar and filter icon.
class SearchBarWidget extends StatelessWidget {
  final VoidCallback onFilterPressed;
  final TextEditingController? controller;

  const SearchBarWidget({
    super.key,
    required this.onFilterPressed,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Search by name, type..',
                border: InputBorder.none,
                icon: Icon(Icons.search, color: Colors.grey),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector( // Using GestureDetector for the filter button
          onTap: onFilterPressed,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(12),
            child: const Icon(Icons.filter_list, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
