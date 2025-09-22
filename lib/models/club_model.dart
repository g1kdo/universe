// lib/models/club_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Club {
  final String id;
  final String name;
  final String description;
  final String category; // 'academic', 'sports', 'cultural', 'social', 'professional', 'other'
  final String? logoUrl;
  final String presidentId; // User ID of the club president
  final String presidentName;
  final String? presidentEmail;
  final List<String> memberIds; // List of member user IDs
  final List<String> adminIds; // List of admin user IDs (president + other admins)
  final int maxMembers; // Maximum number of members allowed
  final String meetingSchedule; // e.g., "Every Tuesday 6:00 PM"
  final String meetingLocation; // Where meetings are held
  final List<String> tags; // Tags for search/filtering
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive; // Whether the club is currently active
  final String? website;
  final String? socialMedia; // Social media links
  final String? contactInfo; // Additional contact information

  Club({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    this.logoUrl,
    required this.presidentId,
    required this.presidentName,
    this.presidentEmail,
    required this.memberIds,
    required this.adminIds,
    required this.maxMembers,
    required this.meetingSchedule,
    required this.meetingLocation,
    required this.tags,
    required this.createdAt,
    this.updatedAt,
    required this.isActive,
    this.website,
    this.socialMedia,
    this.contactInfo,
  });

  factory Club.fromMap(Map<String, dynamic> map, String id) {
    return Club(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? 'other',
      logoUrl: map['logoUrl'],
      presidentId: map['presidentId'] ?? '',
      presidentName: map['presidentName'] ?? '',
      presidentEmail: map['presidentEmail'],
      memberIds: List<String>.from(map['memberIds'] ?? []),
      adminIds: List<String>.from(map['adminIds'] ?? []),
      maxMembers: map['maxMembers'] ?? 50,
      meetingSchedule: map['meetingSchedule'] ?? '',
      meetingLocation: map['meetingLocation'] ?? '',
      tags: List<String>.from(map['tags'] ?? []),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: map['updatedAt'] != null 
          ? (map['updatedAt'] as Timestamp).toDate() 
          : null,
      isActive: map['isActive'] ?? true,
      website: map['website'],
      socialMedia: map['socialMedia'],
      contactInfo: map['contactInfo'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'logoUrl': logoUrl,
      'presidentId': presidentId,
      'presidentName': presidentName,
      'presidentEmail': presidentEmail,
      'memberIds': memberIds,
      'adminIds': adminIds,
      'maxMembers': maxMembers,
      'meetingSchedule': meetingSchedule,
      'meetingLocation': meetingLocation,
      'tags': tags,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'isActive': isActive,
      'website': website,
      'socialMedia': socialMedia,
      'contactInfo': contactInfo,
    };
  }

  Club copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    String? logoUrl,
    String? presidentId,
    String? presidentName,
    String? presidentEmail,
    List<String>? memberIds,
    List<String>? adminIds,
    int? maxMembers,
    String? meetingSchedule,
    String? meetingLocation,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    String? website,
    String? socialMedia,
    String? contactInfo,
  }) {
    return Club(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      logoUrl: logoUrl ?? this.logoUrl,
      presidentId: presidentId ?? this.presidentId,
      presidentName: presidentName ?? this.presidentName,
      presidentEmail: presidentEmail ?? this.presidentEmail,
      memberIds: memberIds ?? this.memberIds,
      adminIds: adminIds ?? this.adminIds,
      maxMembers: maxMembers ?? this.maxMembers,
      meetingSchedule: meetingSchedule ?? this.meetingSchedule,
      meetingLocation: meetingLocation ?? this.meetingLocation,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      website: website ?? this.website,
      socialMedia: socialMedia ?? this.socialMedia,
      contactInfo: contactInfo ?? this.contactInfo,
    );
  }

  // Helper methods
  int get memberCount => memberIds.length;
  bool get isFull => memberIds.length >= maxMembers;
  bool isMember(String userId) => memberIds.contains(userId);
  bool isAdmin(String userId) => adminIds.contains(userId);
  bool isPresident(String userId) => presidentId == userId;
}
