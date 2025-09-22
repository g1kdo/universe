// lib/models/news_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class News {
  final String id;
  final String title;
  final String content;
  final String category;
  final String author;
  final DateTime publishedAt;
  final String? imageUrl;
  final List<String> tags;
  final bool isPublished;

  News({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.author,
    required this.publishedAt,
    this.imageUrl,
    required this.tags,
    required this.isPublished,
  });

  factory News.fromMap(Map<String, dynamic> map, String id) {
    return News(
      id: id,
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      category: map['category'] ?? '',
      author: map['author'] ?? '',
      publishedAt: (map['publishedAt'] as Timestamp).toDate(),
      imageUrl: map['imageUrl'],
      tags: List<String>.from(map['tags'] ?? []),
      isPublished: map['isPublished'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'category': category,
      'author': author,
      'publishedAt': Timestamp.fromDate(publishedAt),
      'imageUrl': imageUrl,
      'tags': tags,
      'isPublished': isPublished,
    };
  }

  News copyWith({
    String? id,
    String? title,
    String? content,
    String? category,
    String? author,
    DateTime? publishedAt,
    String? imageUrl,
    List<String>? tags,
    bool? isPublished,
  }) {
    return News(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      author: author ?? this.author,
      publishedAt: publishedAt ?? this.publishedAt,
      imageUrl: imageUrl ?? this.imageUrl,
      tags: tags ?? this.tags,
      isPublished: isPublished ?? this.isPublished,
    );
  }
}
