// lib/ui/components/home_header.dart
import 'package:flutter/material.dart';

/// Component for the top header section: Welcome message, location, and profile picture.
class HomeHeader extends StatelessWidget {
  final String userName;
  final String userLocation;
  final String? profileImageUrl;
  final bool isAuthenticated;

  const HomeHeader({
    super.key,
    required this.userName,
    required this.userLocation,
    this.profileImageUrl,
    required this.isAuthenticated,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, $userName!',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  userLocation,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                if (isAuthenticated)
                  const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey),
              ],
            ),
            if (!isAuthenticated) ...[
              const SizedBox(height: 4),
              Text(
                'Sign in to access all features',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
        CircleAvatar(
          radius: 25,
          backgroundImage: profileImageUrl != null ? NetworkImage(profileImageUrl!) : null,
          child: profileImageUrl == null 
            ? const Icon(Icons.person, size: 25, color: Colors.grey)
            : null,
        ),
      ],
    );
  }
}
