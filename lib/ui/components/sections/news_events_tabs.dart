// lib/ui/components/sections/news_events_tabs.dart
import 'package:flutter/material.dart';

/// Component for tab selection, now generalized for any list of tabs.
class NewsEventsTabs extends StatelessWidget {
  final String selectedTab;
  final ValueChanged<String> onTabSelected;
  final List<String> tabs; // New parameter for custom tabs

  const NewsEventsTabs({
    super.key,
    required this.selectedTab,
    required this.onTabSelected,
    this.tabs = const ['News', 'Events'], // Default to News and Events for existing uses
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: tabs.map((tabName) {
        return GestureDetector(
          onTap: () => onTabSelected(tabName),
          child: Padding(
            padding: const EdgeInsets.only(right: 20.0), // Spacing between tabs
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tabName,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: selectedTab == tabName ? Colors.black : Colors.grey,
                  ),
                ),
                if (selectedTab == tabName)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    height: 3,
                    // Dynamic width based on text length or a fixed minimum
                    width: tabName.length * 10.0 + 10, // A simple way to approximate width
                    color: Colors.deepPurple, // Using a consistent accent color
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}