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
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.6)),
                const SizedBox(width: 4),
                Text(
                  userLocation,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.7),
                  ),
                ),
                if (isAuthenticated)
                  Icon(Icons.keyboard_arrow_down, size: 16, color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.6)),
              ],
            ),
            if (!isAuthenticated) ...[
              const SizedBox(height: 4),
              Text(
                'Sign in to access all features',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.primary,
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
            ? Icon(Icons.person, size: 25, color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.6))
            : null,
        ),
      ],
    );
  }
}
