// ui/components/sections/club_organization_directory.dart
import 'package:flutter/material.dart';

/// A card displaying a club or organization.
class ClubCard extends StatelessWidget {
  final Map<String, String> club;
  final VoidCallback onTap;

  const ClubCard({
    super.key,
    required this.club,
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
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  club['logo'] ?? 'https://placehold.co/60x60/BADA55/FFFFFF?text=Club',
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      club['name'] ?? 'N/A',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      club['description'] ?? 'No description available.',
                      style: TextStyle(color: Colors.grey[700]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

/// Section for displaying a directory of clubs and organizations.
class ClubOrganizationDirectory extends StatelessWidget {
  final List<Map<String, String>> clubs;
  final Function(Map<String, String>) onClubTap;

  const ClubOrganizationDirectory({
    super.key,
    required this.clubs,
    required this.onClubTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Campus Crew Hub 🎓',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        if (clubs.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                'No clubs found. Time to start one?',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: clubs.length,
            itemBuilder: (context, index) {
              final club = clubs[index];
              return ClubCard(
                club: club,
                onTap: () => onClubTap(club),
              );
            },
          ),
        const SizedBox(height: 10),
        Center(
          child: OutlinedButton.icon(
            onPressed: () {
              // TODO: Implement register club functionality
              print('Register Your Club button pressed!');
            },
            icon: const Icon(Icons.group_add),
            label: const Text('Register Your Club'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.deepPurple,
              side: const BorderSide(color: Colors.deepPurple),
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