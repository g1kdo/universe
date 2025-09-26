// lib/ui/components/cards/lab_card.dart
import 'package:flutter/material.dart';
import 'package:universe/models/lab_model.dart';

/// Component for a single Lab card in the grid.
class LabCard extends StatelessWidget {
  final Lab lab;
  final VoidCallback onTap;

  const LabCard({
    super.key,
    required this.lab,
    required this.onTap,
  });

  IconData _getLabIcon(String category) {
    switch (category.toLowerCase()) {
      case 'lab':
        return Icons.science;
      case 'canteen':
        return Icons.restaurant;
      case 'office':
        return Icons.business;
      case 'gym':
        return Icons.fitness_center;
      case 'library':
        return Icons.library_books;
      case 'hostel':
        return Icons.home;
      default:
        return Icons.location_on;
    }
  }

  Color _getLabColor(String category) {
    switch (category.toLowerCase()) {
      case 'lab':
        return Colors.blue;
      case 'canteen':
        return Colors.orange;
      case 'office':
        return Colors.green;
      case 'gym':
        return Colors.red;
      case 'library':
        return Colors.purple;
      case 'hostel':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final labIcon = _getLabIcon(lab.category);
    final labColor = _getLabColor(lab.category);

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon Header
            Container(
              height: 90, // Reduced from 100 to give more space for content
              width: double.infinity,
              decoration: BoxDecoration(
                color: labColor.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    labIcon,
                    size: 35, // Reduced from 40
                    color: labColor,
                  ),
                  const SizedBox(height: 6), // Reduced from 8
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3), // Reduced padding
                    decoration: BoxDecoration(
                      color: labColor,
                      borderRadius: BorderRadius.circular(10), // Reduced from 12
                    ),
                    child: Text(
                      lab.category.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9, // Reduced from 10
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded( // Make content area flexible
              child: Padding(
                padding: const EdgeInsets.all(10.0), // Reduced padding
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distribute space evenly
                  children: [
                    // Lab name with better text handling
                    Flexible(
                      child: Text(
                        lab.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15, // Slightly reduced
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        maxLines: 3, // Increased from 2 to 3
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Location info
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 12, // Reduced size
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.6),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            lab.floor,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.7),
                              fontSize: 12, // Reduced from 14
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Accommodation info
                    Row(
                      children: [
                        Icon(
                          Icons.people,
                          size: 12, // Reduced size
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.6),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            lab.accommodation,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.7),
                              fontSize: 11, // Reduced from 12
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Availability status
                    Row(
                      children: [
                        Icon(
                          lab.isAvailable ? Icons.check_circle : Icons.cancel,
                          size: 12, // Reduced size
                          color: lab.isAvailable ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            lab.isAvailable ? 'Available' : 'Unavailable',
                            style: TextStyle(
                              color: lab.isAvailable ? Colors.green : Colors.red,
                              fontSize: 11, // Reduced from 12
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}