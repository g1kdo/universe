import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:universe/models/lab_model.dart';

class DetailImageHeader extends ConsumerWidget {
  final Lab lab;

  const DetailImageHeader({super.key, required this.lab});

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
  Widget build(BuildContext context, WidgetRef ref) {
    final labIcon = _getLabIcon(lab.category);
    final labColor = _getLabColor(lab.category);

    return SliverAppBar(
      expandedHeight: 250.0,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                labColor.withValues(alpha: 0.8),
                labColor.withValues(alpha: 0.6),
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  labIcon,
                  size: 80,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    lab.category.toUpperCase(),
                    style: TextStyle(
                      color: labColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  lab.name,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onPrimary),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.share, color: Theme.of(context).colorScheme.onPrimary),
          onPressed: () {
            // TODO: Implement share functionality
            // Share button pressed!
          },
        ),
      ],
    );
  }
}