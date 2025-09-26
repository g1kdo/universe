// lib/ui/components/cards/notification_card.dart
import 'package:flutter/material.dart';
import 'package:universe/models/notification_model.dart';
import 'package:universe/services/notification_service.dart';

class NotificationCard extends StatelessWidget {
  final NotificationItem notification;
  final VoidCallback? onTap;
  final VoidCallback? onMarkAsRead;
  final VoidCallback? onDelete;

  const NotificationCard({
    super.key,
    required this.notification,
    this.onTap,
    this.onMarkAsRead,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final icon = NotificationService.getNotificationIcon(notification.type);
    final colorName = NotificationService.getNotificationColor(notification.type);
    final color = _getColorFromName(colorName);
    final timeAgo = _getTimeAgo(notification.createdAt);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: notification.isRead ? 1 : 3,
      color: notification.isRead 
          ? Theme.of(context).colorScheme.surface
          : Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.1),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Notification icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    icon,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // Notification content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and time
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                        Text(
                          timeAgo,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    
                    // Message
                    Text(
                      notification.message,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    // Metadata for item found notifications
                    if (notification.type == 'item_found' && notification.metadata != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Found by: ${notification.metadata!['finderName'] ?? 'Unknown'}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.orange[700],
                              ),
                            ),
                            if (notification.metadata!['foundNotes'] != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Details: ${notification.metadata!['foundNotes']}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.orange[600],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              // Action buttons
              Column(
                children: [
                  if (!notification.isRead && onMarkAsRead != null)
                    IconButton(
                      icon: Icon(
                        Icons.mark_email_read,
                        size: 20,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      onPressed: onMarkAsRead,
                      tooltip: 'Mark as read',
                    ),
                  if (onDelete != null)
                    IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        size: 20,
                        color: Colors.red[400],
                      ),
                      onPressed: onDelete,
                      tooltip: 'Delete',
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getColorFromName(String colorName) {
    switch (colorName) {
      case 'orange':
        return Colors.orange;
      case 'green':
        return Colors.green;
      case 'blue':
        return Colors.blue;
      case 'purple':
        return Colors.purple;
      case 'red':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
