// lib/services/notification_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/notification_model.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get all notifications for the current user
  Stream<List<NotificationItem>> getUserNotifications() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationItem.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Get unread notifications count
  Stream<int> getUnreadNotificationsCount() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(0);

    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: user.uid)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).update({
      'isRead': true,
    });
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final batch = _firestore.batch();
    final notifications = await _firestore
        .collection('notifications')
        .where('userId', isEqualTo: user.uid)
        .where('isRead', isEqualTo: false)
        .get();

    for (final doc in notifications.docs) {
      batch.update(doc.reference, {'isRead': true});
    }

    await batch.commit();
  }

  // Create a new notification
  Future<String> createNotification(NotificationItem notification) async {
    final docRef = await _firestore.collection('notifications').add(notification.toMap());
    return docRef.id;
  }

  // Send notification when item is found
  Future<void> notifyItemFound({
    required String reporterId,
    required String itemTitle,
    required String finderName,
    required String foundNotes,
    required String itemId,
  }) async {
    final notification = NotificationItem.itemFound(
      id: '', // Will be set by Firestore
      reporterId: reporterId,
      itemTitle: itemTitle,
      finderName: finderName,
      foundNotes: foundNotes,
      itemId: itemId,
    );

    await createNotification(notification);
  }

  // Send notification when item is resolved
  Future<void> notifyItemResolved({
    required String reporterId,
    required String itemTitle,
    required String itemId,
  }) async {
    final notification = NotificationItem.itemResolved(
      id: '', // Will be set by Firestore
      reporterId: reporterId,
      itemTitle: itemTitle,
      itemId: itemId,
    );

    await createNotification(notification);
  }

  // Send event reminder notification
  Future<void> notifyEventReminder({
    required String userId,
    required String eventTitle,
    required String eventId,
    required DateTime eventDate,
  }) async {
    final notification = NotificationItem.eventReminder(
      id: '', // Will be set by Firestore
      userId: userId,
      eventTitle: eventTitle,
      eventId: eventId,
      eventDate: eventDate,
    );

    await createNotification(notification);
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).delete();
  }

  // Delete all notifications for current user
  Future<void> deleteAllNotifications() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final batch = _firestore.batch();
    final notifications = await _firestore
        .collection('notifications')
        .where('userId', isEqualTo: user.uid)
        .get();

    for (final doc in notifications.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  // Get notification icon based on type
  static String getNotificationIcon(String type) {
    switch (type) {
      case 'item_found':
        return '🔍';
      case 'item_resolved':
        return '✅';
      case 'event_reminder':
        return '📅';
      case 'club_update':
        return '👥';
      case 'news_update':
        return '📰';
      default:
        return '🔔';
    }
  }

  // Get notification color based on type
  static String getNotificationColor(String type) {
    switch (type) {
      case 'item_found':
        return 'orange';
      case 'item_resolved':
        return 'green';
      case 'event_reminder':
        return 'blue';
      case 'club_update':
        return 'purple';
      case 'news_update':
        return 'red';
      default:
        return 'grey';
    }
  }
}
