// lib/models/lab_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Lab {
  final String id;
  final String name;
  final String floor;
  final String accommodation;
  final String type;
  final String category; // New field: lab, canteen, office, gym, library, hostel
  final String description;
  final String? imageUrl;
  final bool isAvailable;
  final List<String> equipment;
  final String? contactPerson;
  final DateTime createdAt;

  Lab({
    required this.id,
    required this.name,
    required this.floor,
    required this.accommodation,
    required this.type,
    required this.category,
    required this.description,
    this.imageUrl,
    required this.isAvailable,
    required this.equipment,
    this.contactPerson,
    required this.createdAt,
  });

  factory Lab.fromMap(Map<String, dynamic> map, String id) {
    return Lab(
      id: id,
      name: map['name'] ?? '',
      floor: map['floor'] ?? '',
      accommodation: map['accommodation'] ?? '',
      type: map['type'] ?? '',
      category: map['category'] ?? 'lab', // Default to 'lab' if not specified
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'],
      isAvailable: map['isAvailable'] ?? true,
      equipment: List<String>.from(map['equipment'] ?? []),
      contactPerson: map['contactPerson'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'floor': floor,
      'accommodation': accommodation,
      'type': type,
      'category': category,
      'description': description,
      'imageUrl': imageUrl,
      'isAvailable': isAvailable,
      'equipment': equipment,
      'contactPerson': contactPerson,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  Lab copyWith({
    String? id,
    String? name,
    String? floor,
    String? accommodation,
    String? type,
    String? category,
    String? description,
    String? imageUrl,
    bool? isAvailable,
    List<String>? equipment,
    String? contactPerson,
    DateTime? createdAt,
  }) {
    return Lab(
      id: id ?? this.id,
      name: name ?? this.name,
      floor: floor ?? this.floor,
      accommodation: accommodation ?? this.accommodation,
      type: type ?? this.type,
      category: category ?? this.category,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      isAvailable: isAvailable ?? this.isAvailable,
      equipment: equipment ?? this.equipment,
      contactPerson: contactPerson ?? this.contactPerson,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
