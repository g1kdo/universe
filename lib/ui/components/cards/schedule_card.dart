// lib/ui/components/schedule_card.dart
import 'package:flutter/material.dart';

// Component for a single schedule event/class card
class ScheduleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String room;
  final String instructor;
  final Color cardColor;
  final bool showNotification;

  const ScheduleCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.room,
    required this.instructor,
    required this.cardColor,
    this.showNotification = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black87,
                    ),
                  ),
                ),
                if (showNotification)
                  Icon(Icons.more_vert, color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.6)), // More options icon
              ],
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.6)),
                const SizedBox(width: 4),
                Expanded(
                  flex: 1,
                  child: Text(
                    room,
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.person, size: 16, color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.6)),
                const SizedBox(width: 4),
                Expanded(
                  flex: 1,
                  child: Text(
                    instructor,
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
            if (showNotification) // Optional: Add a notification bell if needed
              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Icon(Icons.notifications_active, size: 20, color: Colors.black54),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
