// lib/models/notification_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationItem {
  final String id;
  final String userId; // User who should receive the notification
  final String title;
  final String message;
  final String type; // 'item_found', 'item_resolved', 'event_reminder', etc.
  final String? relatedItemId; // ID of the related item (lost item, event, etc.)
  final String? relatedItemType; // 'lost_found', 'event', 'club', etc.
  final DateTime createdAt;
  final bool isRead;
  final Map<String, dynamic>? metadata; // Additional data like finder info, etc.

  NotificationItem({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    this.relatedItemId,
    this.relatedItemType,
    required this.createdAt,
    this.isRead = false,
    this.metadata,
  });

  factory NotificationItem.fromMap(Map<String, dynamic> map, String id) {
    return NotificationItem(
      id: id,
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      type: map['type'] ?? '',
      relatedItemId: map['relatedItemId'],
      relatedItemType: map['relatedItemType'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      isRead: map['isRead'] ?? false,
      metadata: map['metadata'] != null ? Map<String, dynamic>.from(map['metadata']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'message': message,
      'type': type,
      'relatedItemId': relatedItemId,
      'relatedItemType': relatedItemType,
      'createdAt': Timestamp.fromDate(createdAt),
      'isRead': isRead,
      'metadata': metadata,
    };
  }

  NotificationItem copyWith({
    String? id,
    String? userId,
    String? title,
    String? message,
    String? type,
    String? relatedItemId,
    String? relatedItemType,
    DateTime? createdAt,
    bool? isRead,
    Map<String, dynamic>? metadata,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      relatedItemId: relatedItemId ?? this.relatedItemId,
      relatedItemType: relatedItemType ?? this.relatedItemType,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      metadata: metadata ?? this.metadata,
    );
  }

  // Helper methods for different notification types
  static NotificationItem itemFound({
    required String id,
    required String reporterId,
    required String itemTitle,
    required String finderName,
    required String foundNotes,
    required String itemId,
  }) {
    return NotificationItem(
      id: id,
      userId: reporterId,
      title: 'Item Found!',
      message: '$finderName found your lost item "$itemTitle". Check the details and confirm if it\'s yours.',
      type: 'item_found',
      relatedItemId: itemId,
      relatedItemType: 'lost_found',
      createdAt: DateTime.now(),
      metadata: {
        'finderName': finderName,
        'foundNotes': foundNotes,
        'itemTitle': itemTitle,
      },
    );
  }

  static NotificationItem itemResolved({
    required String id,
    required String reporterId,
    required String itemTitle,
    required String itemId,
  }) {
    return NotificationItem(
      id: id,
      userId: reporterId,
      title: 'Item Resolved',
      message: 'Your lost item "$itemTitle" has been successfully resolved.',
      type: 'item_resolved',
      relatedItemId: itemId,
      relatedItemType: 'lost_found',
      createdAt: DateTime.now(),
    );
  }

  static NotificationItem eventReminder({
    required String id,
    required String userId,
    required String eventTitle,
    required String eventId,
    required DateTime eventDate,
  }) {
    return NotificationItem(
      id: id,
      userId: userId,
      title: 'Event Reminder',
      message: 'Don\'t forget! "$eventTitle" is coming up soon.',
      type: 'event_reminder',
      relatedItemId: eventId,
      relatedItemType: 'event',
      createdAt: DateTime.now(),
      metadata: {
        'eventDate': Timestamp.fromDate(eventDate),
      },
    );
  }
}
