// lib/ui/components/sections/labs_section.dart
import 'package:flutter/material.dart';
import 'package:universe/ui/components/cards/lab_card.dart';
import 'package:universe/models/lab_model.dart';

/// Component for the Labs section title and grid.
class LabsSection extends StatelessWidget {
  final List<Lab> labs;
  final Function(Lab) onLabTap;
  final String title;

  const LabsSection({
    super.key,
    required this.labs,
    required this.onLabTap,
    this.title = 'LABS',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
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
              lab: lab,
              onTap: () => onLabTap(lab),
            );
          },
        ),
      ],
    );
  }
}