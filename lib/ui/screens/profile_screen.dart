// lib/ui/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:universe/ui/components/cards/profile_stat_card.dart';
import 'package:universe/ui/components/dashboard_option_tile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- App Bar Section ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button (if needed, based on navigation flow)
                  // IconButton(
                  //   icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
                  //   onPressed: () {
                  //     Navigator.pop(context);
                  //   },
                  // ),
                  const Text(
                    'Profile',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_none, color: Colors.black87),
                    onPressed: () {
                      // TODO: Handle notifications
                    },
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // --- User Info Section ---
              Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(
                      'https://placehold.co/100x100/A0DCF0/FFFFFF?text=AA', // Placeholder image for Ammar Ali
                    ),
                  ),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Adonai Great Katy', // Placeholder name
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Student ID: 25537', // Placeholder student ID
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // --- Campus/Event Statistics Section (Replaced Course Elements) ---
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F0), // Light grey background for this section
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        ProfileStatCard(
                          value: '15+',
                          label: 'Events Attended',
                          backgroundColor: Colors.white,
                        ),
                        const SizedBox(width: 16),
                        ProfileStatCard(
                          value: '8',
                          label: 'Clubs Joined',
                          backgroundColor: Colors.white,
                        ),
                        const SizedBox(width: 16),
                        ProfileStatCard(
                          value: '2',
                          label: 'Items Lost',
                          backgroundColor: Colors.white,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Campus Activity Summary
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Campus Activity Summary',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.orange[100],
                                child: Icon(Icons.event_note, size: 30, color: Colors.orange[700]),
                              ),
                              const SizedBox(height: 5),
                              Text('Event Check-ins', style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                              Text('90%', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.green[100],
                                child: Icon(Icons.group_add, size: 30, color: Colors.green[700]),
                              ),
                              const SizedBox(height: 5),
                              Text('Club Participation', style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                              Text('75%', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.blue[100],
                                child: Icon(Icons.location_on, size: 30, color: Colors.blue[700]),
                              ),
                              const SizedBox(height: 5),
                              Text('Campus Exploration', style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                              Text('85%', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // --- Dashboard Section ---
              const Text(
                'Dashboard',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 15),
              DashboardOptionTile(
                icon: Icons.settings,
                title: 'Settings',
                onTap: () {
                  print('Settings tapped');
                  // TODO: Navigate to Settings screen
                },
              ),
              DashboardOptionTile(
                icon: Icons.emoji_events, // Changed to trophy for achievements
                title: 'Achievements',
                onTap: () {
                  print('Achievements tapped');
                  // TODO: Navigate to Achievements screen
                },
              ),
              DashboardOptionTile(
                icon: Icons.lock, // Changed to lock for privacy
                title: 'Privacy',
                onTap: () {
                  print('Privacy tapped');
                  // TODO: Navigate to Privacy screen
                },
              ),
              DashboardOptionTile(
                icon: Icons.logout, // Added Logout
                title: 'Logout',
                onTap: () {
                  print('Logout tapped');
                  // TODO: Implement logout logic and navigate to Login/Welcome
                },
              ),
            ],
          ),
        ),
      ),
      // Bottom Navigation Bar (Assuming it's managed by the parent, e.g., main.dart or a wrapper)
      // If this screen is directly accessed, you might need to add AppBottomNavigationBar here.
    );
  }
}
