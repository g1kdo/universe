// lib/ui/components/sections/labs_section.dart (Updated path: now in 'sections' directory)
import 'package:flutter/material.dart';
import 'package:universe/ui/components/cards/lab_card.dart'; // Import the LabCard component

/// Component for the Labs section title and grid.
class LabsSection extends StatelessWidget {
  final List<Map<String, String>> labs;
  final Function(Map<String, String>) onLabTap; // Add this line

  const LabsSection({
    super.key,
    required this.labs,
    required this.onLabTap, // Add this line
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'LABS',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 15),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
            childAspectRatio: 0.8,
          ),
          itemCount: labs.length,
          itemBuilder: (context, index) {
            final lab = labs[index];
            return LabCard(
              name: lab['name']!,
              floor: lab['floor']!,
              imageUrl: lab['image']!,
              onTap: () => onLabTap(lab), // Pass the callback to LabCard
            );
          },
        ),
      ],
    );
  }
}