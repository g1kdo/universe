// lib/ui/components/news_events_list.dart
import 'package:flutter/material.dart';
import 'package:universe/ui/components/cards/news_card.dart'; // Import NewsCard
import 'package:universe/ui/components/cards/event_card.dart'; // Import EventCard

/// Component for the conditional display of News or Events list.
class NewsEventsList extends StatelessWidget {
  final String selectedTab;
  final List<Map<String, String>> newsItems;
  final List<Map<String, String>> eventItems;

  const NewsEventsList({
    super.key,
    required this.selectedTab,
    required this.newsItems,
    required this.eventItems,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedTab == 'News') {
      return Column(
        children: newsItems.map((news) => NewsCard(
          title: news['title']!,
          content: news['content']!,
          date: news['date']!,
        )).toList(),
      );
    } else {
      return Column(
        children: eventItems.map((event) => EventCard(
          title: event['title']!,
          location: event['location']!,
          date: event['date']!,
          imageUrl: event['image']!,
        )).toList(),
      );
    }
  }
}
