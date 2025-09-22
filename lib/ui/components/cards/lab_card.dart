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
              height: 100,
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
                    size: 40,
                    color: labColor,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: labColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      lab.category.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lab.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          lab.floor,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.people,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          lab.accommodation,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        lab.isAvailable ? Icons.check_circle : Icons.cancel,
                        size: 14,
                        color: lab.isAvailable ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        lab.isAvailable ? 'Available' : 'Unavailable',
                        style: TextStyle(
                          color: lab.isAvailable ? Colors.green : Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}