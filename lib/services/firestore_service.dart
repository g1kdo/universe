// lib/services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/event_model.dart';
import '../models/lab_model.dart';
import '../models/news_model.dart';
import '../models/user_schedule_model.dart';
import '../models/lost_found_model.dart';
import '../models/club_model.dart';
import 'notification_service.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Events
  Stream<List<Event>> getEvents() {
    return _firestore
        .collection('events')
        .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Event.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> registerForEvent(String eventId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Please log in or sign up to register for events');

    final eventRef = _firestore.collection('events').doc(eventId);
    final userScheduleRef = _firestore.collection('user_schedules').doc();

    // Use batch to ensure atomicity
    final batch = _firestore.batch();

    // Get event data first
    final eventDoc = await eventRef.get();
    if (!eventDoc.exists) throw Exception('Event not found');

    final eventData = eventDoc.data()!;
    final registeredUsers = List<String>.from(eventData['registeredUsers'] ?? []);

    // Check if user is already registered
    if (registeredUsers.contains(user.uid)) {
      throw Exception('User already registered for this event');
    }

    // Check if event is full
    if (registeredUsers.length >= (eventData['maxParticipants'] ?? 0)) {
      throw Exception('Event is full');
    }

    // Add user to event's registered users
    registeredUsers.add(user.uid);
    batch.update(eventRef, {'registeredUsers': registeredUsers});

    // Create user schedule entry
    final userSchedule = UserSchedule(
      id: userScheduleRef.id,
      userId: user.uid,
      eventId: eventId,
      eventTitle: eventData['title'] ?? '',
      eventDescription: eventData['description'] ?? '',
      location: eventData['location'] ?? '',
      eventDate: (eventData['date'] as Timestamp).toDate(),
      time: eventData['time'] ?? '',
      category: eventData['category'] ?? '',
      organizer: eventData['organizer'] ?? '',
      registeredAt: DateTime.now(),
      isReminderSet: false,
    );

    batch.set(userScheduleRef, userSchedule.toMap());

    await batch.commit();
  }

  Future<void> unregisterFromEvent(String eventId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Please log in to manage your event registrations');

    final eventRef = _firestore.collection('events').doc(eventId);

    // Get event data first
    final eventDoc = await eventRef.get();
    if (!eventDoc.exists) throw Exception('Event not found');

    final eventData = eventDoc.data()!;
    final registeredUsers = List<String>.from(eventData['registeredUsers'] ?? []);

    // Remove user from registered users
    registeredUsers.remove(user.uid);
    await eventRef.update({'registeredUsers': registeredUsers});

    // Remove from user schedules
    final userScheduleQuery = await _firestore
        .collection('user_schedules')
        .where('userId', isEqualTo: user.uid)
        .where('eventId', isEqualTo: eventId)
        .get();

    for (final doc in userScheduleQuery.docs) {
      await doc.reference.delete();
    }
  }

  // Labs
  Stream<List<Lab>> getLabs() {
    return _firestore
        .collection('labs')
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Lab.fromMap(doc.data(), doc.id))
            .toList());
  }

  // News
  Stream<List<News>> getNews() {
    return _firestore
        .collection('news')
        .where('isPublished', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          final news = snapshot.docs
              .map((doc) => News.fromMap(doc.data(), doc.id))
              .toList();
          // Sort by publishedAt in descending order
          news.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
          return news;
        });
  }

  // User Schedule
  Stream<List<UserSchedule>> getUserSchedule() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('user_schedules')
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) {
          final schedules = snapshot.docs
              .map((doc) => UserSchedule.fromMap(doc.data(), doc.id))
              .toList();
          // Sort by eventDate
          schedules.sort((a, b) => a.eventDate.compareTo(b.eventDate));
          return schedules;
        });
  }

  Stream<List<UserSchedule>> getUserScheduleForDate(DateTime date) {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    return _firestore
        .collection('user_schedules')
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) {
          final schedules = snapshot.docs
              .map((doc) => UserSchedule.fromMap(doc.data(), doc.id))
              .where((schedule) {
                // Filter by date range
                return schedule.eventDate.isAfter(startOfDay.subtract(const Duration(days: 1))) &&
                       schedule.eventDate.isBefore(endOfDay.add(const Duration(days: 1)));
              })
              .toList();
          // Sort by date and time
          schedules.sort((a, b) {
            final dateCompare = a.eventDate.compareTo(b.eventDate);
            if (dateCompare != 0) return dateCompare;
            return a.time.compareTo(b.time);
          });
          return schedules;
        });
  }

  // User Profile
  Future<Map<String, dynamic>?> getUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    return doc.data();
  }

  Future<void> updateUserProfile(Map<String, dynamic> profileData) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Please log in to update your profile');

    await _firestore.collection('users').doc(user.uid).set(profileData, SetOptions(merge: true));
  }

  // Check if user is registered for an event
  Future<bool> isUserRegisteredForEvent(String eventId) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final eventDoc = await _firestore.collection('events').doc(eventId).get();
    if (!eventDoc.exists) return false;

    final eventData = eventDoc.data()!;
    final registeredUsers = List<String>.from(eventData['registeredUsers'] ?? []);
    return registeredUsers.contains(user.uid);
  }

  // Lost & Found Items
  Stream<List<LostFoundItem>> getLostFoundItems() {
    return _firestore
        .collection('lostFoundItems')
        .snapshots()
        .map((snapshot) {
      final items = snapshot.docs
          .map((doc) => LostFoundItem.fromMap(doc.data(), doc.id))
          .toList();
      // Sort by reported date (newest first)
      items.sort((a, b) => b.reportedAt.compareTo(a.reportedAt));
      return items;
    });
  }

  Stream<List<LostFoundItem>> getLostItems() {
    return _firestore
        .collection('lostFoundItems')
        .where('type', isEqualTo: 'lost')
        .where('isResolved', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
      final items = snapshot.docs
          .map((doc) => LostFoundItem.fromMap(doc.data(), doc.id))
          .toList();
      items.sort((a, b) => b.reportedAt.compareTo(a.reportedAt));
      return items;
    });
  }

  Stream<List<LostFoundItem>> getFoundItems() {
    return _firestore
        .collection('lostFoundItems')
        .where('type', isEqualTo: 'found')
        .where('isResolved', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
      final items = snapshot.docs
          .map((doc) => LostFoundItem.fromMap(doc.data(), doc.id))
          .toList();
      items.sort((a, b) => b.reportedAt.compareTo(a.reportedAt));
      return items;
    });
  }

  Future<LostFoundItem?> getLostFoundItemById(String itemId) async {
    try {
      final doc = await _firestore.collection('lostFoundItems').doc(itemId).get();
      if (doc.exists) {
        return LostFoundItem.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<String> addLostFoundItem(LostFoundItem item) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Please log in to report an item');

    final docRef = await _firestore.collection('lostFoundItems').add(item.toMap());
    return docRef.id;
  }

  Future<void> updateLostFoundItem(LostFoundItem item) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Please log in to update an item');

    // Check if user is the reporter or an admin
    final itemDoc = await _firestore.collection('lostFoundItems').doc(item.id).get();
    if (!itemDoc.exists) throw Exception('Item not found');
    
    final itemData = itemDoc.data()!;
    if (itemData['reporterId'] != user.uid) {
      // Check if user is admin (you can implement admin check here)
      throw Exception('You can only update items you reported');
    }

    await _firestore.collection('lostFoundItems').doc(item.id).update(item.toMap());
  }

  // Mark item as found by someone else (for non-reporters)
  Future<void> markItemAsFound(String itemId, String foundNotes) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Please log in to mark an item as found');

    // Get item data to check if user is the reporter
    final itemDoc = await _firestore.collection('lostFoundItems').doc(itemId).get();
    if (!itemDoc.exists) throw Exception('Item not found');
    
    final itemData = itemDoc.data()!;
    if (itemData['reporterId'] == user.uid) {
      throw Exception('You cannot mark your own item as found. Use the edit function instead.');
    }

    // Get user profile for the finder's name
    final userProfile = await getUserProfile();
    final finderName = userProfile?['name'] ?? 'Unknown User';
    final itemTitle = itemData['title'] ?? 'Unknown Item';
    final reporterId = itemData['reporterId'] as String;

    // Update the item
    await _firestore.collection('lostFoundItems').doc(itemId).update({
      'isFoundByOther': true,
      'foundBy': user.uid,
      'foundAt': Timestamp.now(),
      'foundNotes': foundNotes,
    });

    // Send notification to the reporter
    final notificationService = NotificationService();
    await notificationService.notifyItemFound(
      reporterId: reporterId,
      itemTitle: itemTitle,
      finderName: finderName,
      foundNotes: foundNotes,
      itemId: itemId,
    );
  }

  // Confirm item as resolved (for the original reporter)
  Future<void> confirmItemAsResolved(String itemId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Please log in to confirm an item as resolved');

    // Get item data to check if user is the reporter
    final itemDoc = await _firestore.collection('lostFoundItems').doc(itemId).get();
    if (!itemDoc.exists) throw Exception('Item not found');
    
    final itemData = itemDoc.data()!;
    if (itemData['reporterId'] != user.uid) {
      throw Exception('Only the original reporter can confirm the item as resolved');
    }

    if (!(itemData['isFoundByOther'] ?? false)) {
      throw Exception('Item must be found by someone else before it can be confirmed as resolved');
    }

    final itemTitle = itemData['title'] ?? 'Unknown Item';
    final reporterId = itemData['reporterId'] as String;

    // Update the item
    await _firestore.collection('lostFoundItems').doc(itemId).update({
      'isResolved': true,
      'resolvedBy': user.uid,
      'resolvedAt': Timestamp.now(),
    });

    // Send notification to the reporter
    final notificationService = NotificationService();
    await notificationService.notifyItemResolved(
      reporterId: reporterId,
      itemTitle: itemTitle,
      itemId: itemId,
    );
  }

  // Legacy method for backward compatibility (direct resolution)
  Future<void> resolveLostFoundItem(String itemId, String notes) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Please log in to resolve an item');

    await _firestore.collection('lostFoundItems').doc(itemId).update({
      'isResolved': true,
      'resolvedBy': user.uid,
      'resolvedAt': Timestamp.now(),
      'notes': notes,
    });
  }

  Future<void> deleteLostFoundItem(String itemId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Please log in to delete an item');

    // Check if user is the reporter
    final itemDoc = await _firestore.collection('lostFoundItems').doc(itemId).get();
    if (!itemDoc.exists) throw Exception('Item not found');
    
    final itemData = itemDoc.data()!;
    if (itemData['reporterId'] != user.uid) {
      throw Exception('You can only delete items you reported');
    }

    await _firestore.collection('lostFoundItems').doc(itemId).delete();
  }

  // Clubs
  Stream<List<Club>> getClubs() {
    return _firestore
        .collection('clubs')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      final clubs = snapshot.docs
          .map((doc) => Club.fromMap(doc.data(), doc.id))
          .toList();
      clubs.sort((a, b) => a.name.compareTo(b.name));
      return clubs;
    });
  }

  Stream<List<Club>> getClubsByCategory(String category) {
    return _firestore
        .collection('clubs')
        .where('category', isEqualTo: category)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      final clubs = snapshot.docs
          .map((doc) => Club.fromMap(doc.data(), doc.id))
          .toList();
      clubs.sort((a, b) => a.name.compareTo(b.name));
      return clubs;
    });
  }

  Future<String> addClub(Club club) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Please log in to create a club');

    final docRef = await _firestore.collection('clubs').add(club.toMap());
    return docRef.id;
  }

  Future<void> updateClub(Club club) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Please log in to update a club');

    // Check if user is admin of the club
    final clubDoc = await _firestore.collection('clubs').doc(club.id).get();
    if (!clubDoc.exists) throw Exception('Club not found');
    
    final clubData = clubDoc.data()!;
    final adminIds = List<String>.from(clubData['adminIds'] ?? []);
    if (!adminIds.contains(user.uid)) {
      throw Exception('You can only update clubs you admin');
    }

    await _firestore.collection('clubs').doc(club.id).update(club.toMap());
  }

  Future<void> joinClub(String clubId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Please log in to join a club');

    final clubDoc = await _firestore.collection('clubs').doc(clubId).get();
    if (!clubDoc.exists) throw Exception('Club not found');
    
    final clubData = clubDoc.data()!;
    final memberIds = List<String>.from(clubData['memberIds'] ?? []);
    final maxMembers = clubData['maxMembers'] ?? 50;

    if (memberIds.contains(user.uid)) {
      throw Exception('You are already a member of this club');
    }

    if (memberIds.length >= maxMembers) {
      throw Exception('This club is full');
    }

    await _firestore.collection('clubs').doc(clubId).update({
      'memberIds': FieldValue.arrayUnion([user.uid]),
      'updatedAt': Timestamp.now(),
    });
  }

  Future<void> leaveClub(String clubId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Please log in to leave a club');

    final clubDoc = await _firestore.collection('clubs').doc(clubId).get();
    if (!clubDoc.exists) throw Exception('Club not found');
    
    final clubData = clubDoc.data()!;
    final memberIds = List<String>.from(clubData['memberIds'] ?? []);

    if (!memberIds.contains(user.uid)) {
      throw Exception('You are not a member of this club');
    }

    // Remove from members and admins
    await _firestore.collection('clubs').doc(clubId).update({
      'memberIds': FieldValue.arrayRemove([user.uid]),
      'adminIds': FieldValue.arrayRemove([user.uid]),
      'updatedAt': Timestamp.now(),
    });
  }

  Future<bool> isUserMemberOfClub(String clubId) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final clubDoc = await _firestore.collection('clubs').doc(clubId).get();
    if (!clubDoc.exists) return false;
    
    final clubData = clubDoc.data()!;
    final memberIds = List<String>.from(clubData['memberIds'] ?? []);
    return memberIds.contains(user.uid);
  }

  Future<void> deleteClub(String clubId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Please log in to delete a club');

    // Check if user is president of the club
    final clubDoc = await _firestore.collection('clubs').doc(clubId).get();
    if (!clubDoc.exists) throw Exception('Club not found');
    
    final clubData = clubDoc.data()!;
    if (clubData['presidentId'] != user.uid) {
      throw Exception('You can only delete clubs you created');
    }

    await _firestore.collection('clubs').doc(clubId).update({
      'isActive': false,
      'updatedAt': Timestamp.now(),
    });
  }
}
