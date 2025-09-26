// lib/ui/screens/notifications_screen.dart
import 'package:flutter/material.dart';
import 'package:universe/models/notification_model.dart';
import 'package:universe/services/notification_service.dart';
import 'package:universe/ui/components/cards/notification_card.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _notificationService = NotificationService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
        actions: [
          StreamBuilder<int>(
            stream: _notificationService.getUnreadNotificationsCount(),
            builder: (context, snapshot) {
              final unreadCount = snapshot.data ?? 0;
              if (unreadCount > 0) {
                return TextButton(
                  onPressed: _markAllAsRead,
                  child: Text(
                    'Mark all read',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: StreamBuilder<List<NotificationItem>>(
        stream: _notificationService.getUserNotifications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading notifications',
                    style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final notifications = snapshot.data ?? [];

          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No notifications yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You\'ll receive notifications when someone finds your lost items or when there are updates.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              // Refresh is handled by the stream
            },
            child: ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return NotificationCard(
                  notification: notification,
                  onTap: () => _handleNotificationTap(notification),
                  onMarkAsRead: notification.isRead 
                      ? null 
                      : () => _markAsRead(notification.id),
                  onDelete: () => _deleteNotification(notification.id),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _handleNotificationTap(NotificationItem notification) {
    // Mark as read if not already read
    if (!notification.isRead) {
      _markAsRead(notification.id);
    }

    // Handle navigation based on notification type
    switch (notification.type) {
      case 'item_found':
      case 'item_resolved':
        if (notification.relatedItemId != null) {
          // Navigate to lost & found details or community screen
          Navigator.pop(context); // Go back to community screen
          // You could add more specific navigation here
        }
        break;
      case 'event_reminder':
        if (notification.relatedItemId != null) {
          // Navigate to event details
          Navigator.pop(context); // Go back to home screen
          // You could add more specific navigation here
        }
        break;
      default:
        // Generic handling
        break;
    }
  }

  void _markAsRead(String notificationId) {
    _notificationService.markAsRead(notificationId);
  }

  void _markAllAsRead() {
    _notificationService.markAllAsRead();
  }

  void _deleteNotification(String notificationId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Notification'),
        content: const Text('Are you sure you want to delete this notification?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _notificationService.deleteNotification(notificationId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
