// lib/models/lost_found_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class LostFoundItem {
  final String id;
  final String title;
  final String description;
  final String type; // 'lost' or 'found'
  final String category; // 'electronics', 'clothing', 'books', 'accessories', 'other'
  final String location; // Where it was lost/found
  final String? imageUrl;
  final String reporterId; // User who reported the item
  final String reporterName;
  final String? reporterEmail;
  final String? reporterPhone;
  final DateTime reportedAt;
  final bool isResolved; // Whether the item has been claimed/returned
  final String? resolvedBy; // User ID who resolved it
  final DateTime? resolvedAt;
  final String? notes; // Additional notes

  LostFoundItem({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.category,
    required this.location,
    this.imageUrl,
    required this.reporterId,
    required this.reporterName,
    this.reporterEmail,
    this.reporterPhone,
    required this.reportedAt,
    this.isResolved = false,
    this.resolvedBy,
    this.resolvedAt,
    this.notes,
  });

  factory LostFoundItem.fromMap(Map<String, dynamic> map, String id) {
    return LostFoundItem(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      type: map['type'] ?? 'lost',
      category: map['category'] ?? 'other',
      location: map['location'] ?? '',
      imageUrl: map['imageUrl'],
      reporterId: map['reporterId'] ?? '',
      reporterName: map['reporterName'] ?? '',
      reporterEmail: map['reporterEmail'],
      reporterPhone: map['reporterPhone'],
      reportedAt: (map['reportedAt'] as Timestamp).toDate(),
      isResolved: map['isResolved'] ?? false,
      resolvedBy: map['resolvedBy'],
      resolvedAt: map['resolvedAt'] != null 
          ? (map['resolvedAt'] as Timestamp).toDate() 
          : null,
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'type': type,
      'category': category,
      'location': location,
      'imageUrl': imageUrl,
      'reporterId': reporterId,
      'reporterName': reporterName,
      'reporterEmail': reporterEmail,
      'reporterPhone': reporterPhone,
      'reportedAt': Timestamp.fromDate(reportedAt),
      'isResolved': isResolved,
      'resolvedBy': resolvedBy,
      'resolvedAt': resolvedAt != null ? Timestamp.fromDate(resolvedAt!) : null,
      'notes': notes,
    };
  }

  LostFoundItem copyWith({
    String? id,
    String? title,
    String? description,
    String? type,
    String? category,
    String? location,
    String? imageUrl,
    String? reporterId,
    String? reporterName,
    String? reporterEmail,
    String? reporterPhone,
    DateTime? reportedAt,
    bool? isResolved,
    String? resolvedBy,
    DateTime? resolvedAt,
    String? notes,
  }) {
    return LostFoundItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      category: category ?? this.category,
      location: location ?? this.location,
      imageUrl: imageUrl ?? this.imageUrl,
      reporterId: reporterId ?? this.reporterId,
      reporterName: reporterName ?? this.reporterName,
      reporterEmail: reporterEmail ?? this.reporterEmail,
      reporterPhone: reporterPhone ?? this.reporterPhone,
      reportedAt: reportedAt ?? this.reportedAt,
      isResolved: isResolved ?? this.isResolved,
      resolvedBy: resolvedBy ?? this.resolvedBy,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      notes: notes ?? this.notes,
    );
  }
}
