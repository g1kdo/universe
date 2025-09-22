// lib/models/event_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String id;
  final String title;
  final String description;
  final String location;
  final DateTime date;
  final String time;
  final String category;
  final String organizer;
  final int maxParticipants;
  final List<String> registeredUsers;
  final String? imageUrl;
  final DateTime createdAt;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.date,
    required this.time,
    required this.category,
    required this.organizer,
    required this.maxParticipants,
    required this.registeredUsers,
    this.imageUrl,
    required this.createdAt,
  });

  factory Event.fromMap(Map<String, dynamic> map, String id) {
    return Event(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      location: map['location'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      time: map['time'] ?? '',
      category: map['category'] ?? '',
      organizer: map['organizer'] ?? '',
      maxParticipants: map['maxParticipants'] ?? 0,
      registeredUsers: List<String>.from(map['registeredUsers'] ?? []),
      imageUrl: map['imageUrl'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'location': location,
      'date': Timestamp.fromDate(date),
      'time': time,
      'category': category,
      'organizer': organizer,
      'maxParticipants': maxParticipants,
      'registeredUsers': registeredUsers,
      'imageUrl': imageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  Event copyWith({
    String? id,
    String? title,
    String? description,
    String? location,
    DateTime? date,
    String? time,
    String? category,
    String? organizer,
    int? maxParticipants,
    List<String>? registeredUsers,
    String? imageUrl,
    DateTime? createdAt,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      date: date ?? this.date,
      time: time ?? this.time,
      category: category ?? this.category,
      organizer: organizer ?? this.organizer,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      registeredUsers: registeredUsers ?? this.registeredUsers,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

