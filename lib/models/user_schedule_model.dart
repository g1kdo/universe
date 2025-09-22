// lib/models/user_schedule_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class UserSchedule {
  final String id;
  final String userId;
  final String eventId;
  final String eventTitle;
  final String eventDescription;
  final String location;
  final DateTime eventDate;
  final String time;
  final String category;
  final String organizer;
  final DateTime registeredAt;
  final bool isReminderSet;
  final DateTime? reminderTime;

  UserSchedule({
    required this.id,
    required this.userId,
    required this.eventId,
    required this.eventTitle,
    required this.eventDescription,
    required this.location,
    required this.eventDate,
    required this.time,
    required this.category,
    required this.organizer,
    required this.registeredAt,
    required this.isReminderSet,
    this.reminderTime,
  });

  factory UserSchedule.fromMap(Map<String, dynamic> map, String id) {
    return UserSchedule(
      id: id,
      userId: map['userId'] ?? '',
      eventId: map['eventId'] ?? '',
      eventTitle: map['eventTitle'] ?? '',
      eventDescription: map['eventDescription'] ?? '',
      location: map['location'] ?? '',
      eventDate: (map['eventDate'] as Timestamp).toDate(),
      time: map['time'] ?? '',
      category: map['category'] ?? '',
      organizer: map['organizer'] ?? '',
      registeredAt: (map['registeredAt'] as Timestamp).toDate(),
      isReminderSet: map['isReminderSet'] ?? false,
      reminderTime: map['reminderTime'] != null 
          ? (map['reminderTime'] as Timestamp).toDate() 
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'eventId': eventId,
      'eventTitle': eventTitle,
      'eventDescription': eventDescription,
      'location': location,
      'eventDate': Timestamp.fromDate(eventDate),
      'time': time,
      'category': category,
      'organizer': organizer,
      'registeredAt': Timestamp.fromDate(registeredAt),
      'isReminderSet': isReminderSet,
      'reminderTime': reminderTime != null 
          ? Timestamp.fromDate(reminderTime!) 
          : null,
    };
  }

  UserSchedule copyWith({
    String? id,
    String? userId,
    String? eventId,
    String? eventTitle,
    String? eventDescription,
    String? location,
    DateTime? eventDate,
    String? time,
    String? category,
    String? organizer,
    DateTime? registeredAt,
    bool? isReminderSet,
    DateTime? reminderTime,
  }) {
    return UserSchedule(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      eventId: eventId ?? this.eventId,
      eventTitle: eventTitle ?? this.eventTitle,
      eventDescription: eventDescription ?? this.eventDescription,
      location: location ?? this.location,
      eventDate: eventDate ?? this.eventDate,
      time: time ?? this.time,
      category: category ?? this.category,
      organizer: organizer ?? this.organizer,
      registeredAt: registeredAt ?? this.registeredAt,
      isReminderSet: isReminderSet ?? this.isReminderSet,
      reminderTime: reminderTime ?? this.reminderTime,
    );
  }
}
