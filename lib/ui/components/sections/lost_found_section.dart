// ui/components/sections/lost_found_section.dart
import 'package:flutter/material.dart';
import 'package:universe/ui/components/sections/news_events_tabs.dart'; // Reusing for Lost/Found tabs

/// A card displaying a lost or found item.
class LostFoundItemCard extends StatelessWidget {
  final Map<String, String> item;
  final VoidCallback onTap;

  const LostFoundItemCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  item['image'] ?? 'https://placehold.co/80x80/E0E0E0/000000?text=No+Image',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['title'] ?? 'N/A',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['description'] ?? 'No description.',
                      style: TextStyle(color: Colors.grey[700]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item['type']} • ${item['date']}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Section for Lost & Found items with tabs.
class LostFoundSection extends StatefulWidget {
  final List<Map<String, String>> lostItems;
  final List<Map<String, String>> foundItems;
  final Function(Map<String, String>) onItemTap;

  const LostFoundSection({
    super.key,
    required this.lostItems,
    required this.foundItems,
    required this.onItemTap,
  });

  @override
  State<LostFoundSection> createState() => _LostFoundSectionState();
}

class _LostFoundSectionState extends State<LostFoundSection> {
  String _selectedTab = 'Lost'; // Default selected tab

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> currentItems =
    _selectedTab == 'Lost' ? widget.lostItems : widget.foundItems;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Lost & Found 🕵️‍♂️',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        NewsEventsTabs( // Reusing NewsEventsTabs for tab functionality
          selectedTab: _selectedTab,
          onTabSelected: (tab) {
            setState(() {
              _selectedTab = tab;
            });
          },
          tabs: const ['Lost', 'Found'], // Custom tabs for Lost & Found
        ),
        const SizedBox(height: 15),
        if (currentItems.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                'No ${_selectedTab.toLowerCase()} items reported yet. Be the first!',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: currentItems.length,
            itemBuilder: (context, index) {
              final item = currentItems[index];
              return LostFoundItemCard(
                item: item,
                onTap: () => widget.onItemTap(item),
              );
            },
          ),
        const SizedBox(height: 10),
        Center(
          child: ElevatedButton.icon(
            onPressed: () {
              // TODO: Implement report item functionality
              print('Report Item button pressed!');
            },
            icon: const Icon(Icons.add_circle_outline),
            label: const Text('Report an Item'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}