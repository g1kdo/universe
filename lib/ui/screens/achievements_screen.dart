// lib/ui/screens/achievements_screen.dart
import 'package:flutter/material.dart';
import 'package:universe/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final int points;
  final String category;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.isUnlocked,
    this.unlockedAt,
    required this.points,
    required this.category,
  });
}

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Achievement> _achievements = [];
  int _totalPoints = 0;
  int _unlockedCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAchievements();
  }

  Future<void> _loadAchievements() async {
    if (_auth.currentUser == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      // Load user's registered events to calculate achievements
      final userSchedule = await _firestoreService.getUserSchedule().first;
      final eventsAttended = userSchedule.length;

      // Generate achievements based on user activity
      _achievements = _generateAchievements(eventsAttended);
      
      _totalPoints = _achievements.where((a) => a.isUnlocked).fold(0, (sum, a) => sum + a.points);
      _unlockedCount = _achievements.where((a) => a.isUnlocked).length;

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      // Handle error silently
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Achievement> _generateAchievements(int eventsAttended) {
    return [
      // Event Achievements
      Achievement(
        id: 'first_event',
        title: 'First Steps',
        description: 'Attend your first campus event',
        icon: '🎉',
        isUnlocked: eventsAttended >= 1,
        unlockedAt: eventsAttended >= 1 ? DateTime.now().subtract(const Duration(days: 30)) : null,
        points: 10,
        category: 'Events',
      ),
      Achievement(
        id: 'event_enthusiast',
        title: 'Event Enthusiast',
        description: 'Attend 5 campus events',
        icon: '🎪',
        isUnlocked: eventsAttended >= 5,
        unlockedAt: eventsAttended >= 5 ? DateTime.now().subtract(const Duration(days: 15)) : null,
        points: 25,
        category: 'Events',
      ),
      Achievement(
        id: 'social_butterfly',
        title: 'Social Butterfly',
        description: 'Attend 10 campus events',
        icon: '🦋',
        isUnlocked: eventsAttended >= 10,
        unlockedAt: eventsAttended >= 10 ? DateTime.now().subtract(const Duration(days: 5)) : null,
        points: 50,
        category: 'Events',
      ),
      Achievement(
        id: 'campus_legend',
        title: 'Campus Legend',
        description: 'Attend 20 campus events',
        icon: '👑',
        isUnlocked: eventsAttended >= 20,
        points: 100,
        category: 'Events',
      ),

      // Exploration Achievements
      Achievement(
        id: 'lab_explorer',
        title: 'Lab Explorer',
        description: 'Visit 3 different labs on campus',
        icon: '🔬',
        isUnlocked: true, // Mock data
        unlockedAt: DateTime.now().subtract(const Duration(days: 20)),
        points: 15,
        category: 'Exploration',
      ),
      Achievement(
        id: 'campus_navigator',
        title: 'Campus Navigator',
        description: 'Explore all major campus locations',
        icon: '🗺️',
        isUnlocked: false,
        points: 30,
        category: 'Exploration',
      ),

      // Social Achievements
      Achievement(
        id: 'early_bird',
        title: 'Early Bird',
        description: 'Register for an event within the first hour',
        icon: '🐦',
        isUnlocked: true, // Mock data
        unlockedAt: DateTime.now().subtract(const Duration(days: 10)),
        points: 20,
        category: 'Social',
      ),
      Achievement(
        id: 'team_player',
        title: 'Team Player',
        description: 'Join a campus club or organization',
        icon: '🤝',
        isUnlocked: true, // Mock data
        unlockedAt: DateTime.now().subtract(const Duration(days: 25)),
        points: 35,
        category: 'Social',
      ),

      // Special Achievements
      Achievement(
        id: 'perfect_attendance',
        title: 'Perfect Attendance',
        description: 'Attend all events you registered for in a month',
        icon: '⭐',
        isUnlocked: false,
        points: 75,
        category: 'Special',
      ),
      Achievement(
        id: 'helpful_hand',
        title: 'Helpful Hand',
        description: 'Help organize or volunteer at an event',
        icon: '🙋‍♂️',
        isUnlocked: false,
        points: 60,
        category: 'Special',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (_auth.currentUser == null) {
      return _buildGuestView();
    }

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats Overview
            _buildStatsOverview(),
            const SizedBox(height: 24),

            // Achievement Categories
            ..._buildAchievementCategories(),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestView() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.emoji_events,
                size: 80,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 24),
              const Text(
                'Sign in to view your achievements',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Track your campus activities and unlock achievements as you participate in events and explore the campus.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: const Text('Sign In'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsOverview() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade400, Colors.blue.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('$_unlockedCount', 'Unlocked', Icons.emoji_events),
              _buildStatItem('${_achievements.length}', 'Total', Icons.assessment),
              _buildStatItem('$_totalPoints', 'Points', Icons.stars),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: _achievements.isNotEmpty ? _unlockedCount / _achievements.length : 0,
            backgroundColor: Colors.white.withValues(alpha: 0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            minHeight: 8,
          ),
          const SizedBox(height: 8),
          Text(
            '${((_unlockedCount / _achievements.length) * 100).toInt()}% Complete',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildAchievementCategories() {
    final categories = _achievements.map((a) => a.category).toSet().toList();
    
    return categories.map((category) {
      final categoryAchievements = _achievements.where((a) => a.category == category).toList();
      
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            category,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          ...categoryAchievements.map((achievement) => _buildAchievementCard(achievement)),
          const SizedBox(height: 24),
        ],
      );
    }).toList();
  }

  Widget _buildAchievementCard(Achievement achievement) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: achievement.isUnlocked ? 4 : 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: achievement.isUnlocked
              ? LinearGradient(
                  colors: [Colors.amber.shade100, Colors.orange.shade100],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
        ),
        child: ListTile(
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: achievement.isUnlocked ? Colors.amber.shade200 : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Center(
              child: Text(
                achievement.icon,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          title: Text(
            achievement.title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: achievement.isUnlocked ? Colors.black87 : Colors.grey[600],
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                achievement.description,
                style: TextStyle(
                  color: achievement.isUnlocked ? Colors.black54 : Colors.grey[500],
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.stars,
                    size: 16,
                    color: achievement.isUnlocked ? Colors.amber[700] : Colors.grey[400],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${achievement.points} points',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: achievement.isUnlocked ? Colors.amber[700] : Colors.grey[400],
                    ),
                  ),
                  if (achievement.isUnlocked && achievement.unlockedAt != null) ...[
                    const Spacer(),
                    Text(
                      'Unlocked ${_formatDate(achievement.unlockedAt!)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          trailing: achievement.isUnlocked
              ? Icon(Icons.check_circle, color: Colors.green[600])
              : Icon(Icons.lock, color: Colors.grey[400]),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) {
      return 'today';
    } else if (difference == 1) {
      return 'yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else if (difference < 30) {
      return '${(difference / 7).floor()} weeks ago';
    } else {
      return '${(difference / 30).floor()} months ago';
    }
  }
}
