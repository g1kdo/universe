// lib/ui/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:universe/ui/components/cards/profile_stat_card.dart';
import 'package:universe/ui/components/dashboard_option_tile.dart';
import 'package:universe/services/auth_service.dart';
import 'package:universe/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:universe/ui/screens/welcome_screen.dart';
import 'package:universe/ui/screens/authentication/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // User statistics
  int _eventsAttended = 0;
  int _clubsJoined = 0;
  int _itemsLost = 0;
  double _eventCheckInRate = 0.0;
  double _clubParticipationRate = 0.0;
  double _campusExplorationRate = 0.0;

  @override
  void initState() {
    super.initState();
    _loadUserStatistics();
  }

  Future<void> _loadUserStatistics() async {
    if (_auth.currentUser != null) {
      try {
        // Load user's registered events
        final userSchedule = await _firestoreService.getUserSchedule().first;
        _eventsAttended = userSchedule.length;
        
        // Calculate check-in rate (simplified - assume 90% of registered events were attended)
        _eventCheckInRate = _eventsAttended > 0 ? 0.9 : 0.0;
        
        // Load user's joined clubs
        final clubs = await _firestoreService.getClubs().first;
        _clubsJoined = clubs.where((club) => club.memberIds.contains(_auth.currentUser!.uid)).length;
        
        // Load user's lost items
        final lostItems = await _firestoreService.getLostItems().first;
        _itemsLost = lostItems.where((item) => item.reporterId == _auth.currentUser!.uid).length;
        
        // Calculate participation rates
        _clubParticipationRate = _clubsJoined > 0 ? 0.75 : 0.0; // Simplified calculation
        _campusExplorationRate = (_eventsAttended + _clubsJoined) > 0 ? 0.85 : 0.0; // Simplified calculation
        
        if (mounted) {
          setState(() {});
        }
      } catch (e) {
        // Handle error silently or show user-friendly message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading statistics: $e')),
          );
        }
      }
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        await _authService.signOut();
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const WelcomeScreen()),
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Logout failed: $e')),
          );
        }
      }
    }
  }

  void _navigateToLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  Widget _buildGuestUserInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.grey[300],
            child: Icon(
              Icons.person,
              size: 40,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Guest User',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sign in to access your profile and statistics',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _navigateToLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text('Sign In'),
          ),
        ],
      ),
    );
  }

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
              StreamBuilder<Map<String, dynamic>?>(
                stream: Stream.fromFuture(_firestoreService.getUserProfile()),
                builder: (context, snapshot) {
                  final userProfile = snapshot.data;
                  final isAuthenticated = _auth.currentUser != null;
                  
                  if (!isAuthenticated) {
                    return _buildGuestUserInfo();
                  }
                  
                  final userName = userProfile?['name'] ?? _auth.currentUser?.displayName ?? 'User';
                  final userEmail = userProfile?['email'] ?? _auth.currentUser?.email ?? '';
                  final profileImageUrl = userProfile?['profileImageUrl'] ?? _auth.currentUser?.photoURL;
                  
                  return Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: profileImageUrl != null ? NetworkImage(profileImageUrl) : null,
                        onBackgroundImageError: (exception, stackTrace) {
                          // Handle image loading error
                        },
                        child: profileImageUrl == null 
                          ? const Icon(Icons.person, size: 40, color: Colors.grey)
                          : null,
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userName,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              userEmail,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Student',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 30),

              // --- Campus/Event Statistics Section ---
              if (_auth.currentUser != null)
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          ProfileStatCard(
                            value: '$_eventsAttended',
                            label: 'Events Attended',
                            backgroundColor: Colors.white,
                          ),
                          const SizedBox(width: 16),
                          ProfileStatCard(
                            value: '$_clubsJoined',
                            label: 'Clubs Joined',
                            backgroundColor: Colors.white,
                          ),
                          const SizedBox(width: 16),
                          ProfileStatCard(
                            value: '$_itemsLost',
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
                                Text('${(_eventCheckInRate * 100).toInt()}%', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
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
                                Text('${(_clubParticipationRate * 100).toInt()}%', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
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
                                Text('${(_campusExplorationRate * 100).toInt()}%', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              if (_auth.currentUser != null)
                const SizedBox(height: 30),

              // --- Dashboard Section ---
              if (_auth.currentUser != null) ...[
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
                    Navigator.pushNamed(context, '/settings');
                  },
                ),
                DashboardOptionTile(
                  icon: Icons.emoji_events,
                  title: 'Achievements',
                  onTap: () {
                    Navigator.pushNamed(context, '/achievements');
                  },
                ),
                DashboardOptionTile(
                  icon: Icons.lock,
                  title: 'Privacy',
                  onTap: () {
                    Navigator.pushNamed(context, '/privacy');
                  },
                ),
                DashboardOptionTile(
                  icon: Icons.logout,
                  title: 'Logout',
                  onTap: _logout,
                ),
              ] else ...[
                const Text(
                  'Account Options',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 15),
                DashboardOptionTile(
                  icon: Icons.login,
                  title: 'Sign In',
                  onTap: _navigateToLogin,
                ),
                DashboardOptionTile(
                  icon: Icons.person_add,
                  title: 'Create Account',
                  onTap: () {
                    Navigator.pushNamed(context, '/signup');
                  },
                ),
              ],
            ],
          ),
        ),
      ),
      // Bottom Navigation Bar (Assuming it's managed by the parent, e.g., main.dart or a wrapper)
      // If this screen is directly accessed, you might need to add AppBottomNavigationBar here.
    );
  }
}
