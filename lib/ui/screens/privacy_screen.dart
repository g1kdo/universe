// lib/ui/screens/privacy_screen.dart
import 'package:flutter/material.dart';
import 'package:universe/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Privacy settings
  bool _profileVisibility = true;
  bool _activitySharing = true;
  bool _locationTracking = true;
  bool _dataAnalytics = true;
  bool _marketingEmails = false;
  bool _pushNotifications = true;
  bool _eventRecommendations = true;

  @override
  void initState() {
    super.initState();
    _loadPrivacySettings();
  }

  Future<void> _loadPrivacySettings() async {
    if (_auth.currentUser == null) return;

    try {
      final userProfile = await _firestoreService.getUserProfile();
      if (userProfile != null) {
        setState(() {
          _profileVisibility = userProfile['profileVisibility'] ?? true;
          _activitySharing = userProfile['activitySharing'] ?? true;
          _locationTracking = userProfile['locationTracking'] ?? true;
          _dataAnalytics = userProfile['dataAnalytics'] ?? true;
          _marketingEmails = userProfile['marketingEmails'] ?? false;
          _pushNotifications = userProfile['pushNotifications'] ?? true;
          _eventRecommendations = userProfile['eventRecommendations'] ?? true;
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _savePrivacySettings() async {
    try {
      await _firestoreService.updateUserProfile({
        'profileVisibility': _profileVisibility,
        'activitySharing': _activitySharing,
        'locationTracking': _locationTracking,
        'dataAnalytics': _dataAnalytics,
        'marketingEmails': _marketingEmails,
        'pushNotifications': _pushNotifications,
        'eventRecommendations': _eventRecommendations,
        'privacyLastUpdated': DateTime.now().toIso8601String(),
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Privacy settings saved successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving privacy settings: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_auth.currentUser == null) {
      return _buildGuestView();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy'),
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
            // Privacy Overview
            _buildPrivacyOverview(),
            const SizedBox(height: 24),

            // Profile Privacy
            _buildSectionHeader('Profile Privacy'),
            _buildPrivacyCard([
              _buildSwitchTile(
                icon: Icons.visibility,
                title: 'Profile Visibility',
                subtitle: 'Allow other users to see your profile information',
                value: _profileVisibility,
                onChanged: (value) {
                  setState(() {
                    _profileVisibility = value;
                  });
                },
              ),
              _buildSwitchTile(
                icon: Icons.share,
                title: 'Activity Sharing',
                subtitle: 'Share your event participation with friends',
                value: _activitySharing,
                onChanged: (value) {
                  setState(() {
                    _activitySharing = value;
                  });
                },
              ),
            ]),

            const SizedBox(height: 24),

            // Location & Tracking
            _buildSectionHeader('Location & Tracking'),
            _buildPrivacyCard([
              _buildSwitchTile(
                icon: Icons.location_on,
                title: 'Location Tracking',
                subtitle: 'Allow app to track your location for nearby features',
                value: _locationTracking,
                onChanged: (value) {
                  setState(() {
                    _locationTracking = value;
                  });
                },
              ),
              _buildSwitchTile(
                icon: Icons.analytics,
                title: 'Data Analytics',
                subtitle: 'Help improve the app by sharing anonymous usage data',
                value: _dataAnalytics,
                onChanged: (value) {
                  setState(() {
                    _dataAnalytics = value;
                  });
                },
              ),
            ]),

            const SizedBox(height: 24),

            // Communications
            _buildSectionHeader('Communications'),
            _buildPrivacyCard([
              _buildSwitchTile(
                icon: Icons.email,
                title: 'Marketing Emails',
                subtitle: 'Receive promotional emails and updates',
                value: _marketingEmails,
                onChanged: (value) {
                  setState(() {
                    _marketingEmails = value;
                  });
                },
              ),
              _buildSwitchTile(
                icon: Icons.notifications,
                title: 'Push Notifications',
                subtitle: 'Receive notifications about events and updates',
                value: _pushNotifications,
                onChanged: (value) {
                  setState(() {
                    _pushNotifications = value;
                  });
                },
              ),
              _buildSwitchTile(
                icon: Icons.recommend,
                title: 'Event Recommendations',
                subtitle: 'Get personalized event recommendations',
                value: _eventRecommendations,
                onChanged: (value) {
                  setState(() {
                    _eventRecommendations = value;
                  });
                },
              ),
            ]),

            const SizedBox(height: 24),

            // Data Management
            _buildSectionHeader('Data Management'),
            _buildPrivacyCard([
              _buildListTile(
                icon: Icons.download,
                title: 'Download My Data',
                subtitle: 'Get a copy of all your data',
                onTap: () {
                  _showDownloadDataDialog();
                },
              ),
              _buildListTile(
                icon: Icons.delete_forever,
                title: 'Delete Account',
                subtitle: 'Permanently delete your account and all data',
                onTap: () {
                  _showDeleteAccountDialog();
                },
              ),
            ]),

            const SizedBox(height: 24),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _savePrivacySettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Save Privacy Settings',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Privacy Policy
            _buildSectionHeader('Legal'),
            _buildPrivacyCard([
              _buildListTile(
                icon: Icons.privacy_tip,
                title: 'Privacy Policy',
                subtitle: 'Read our complete privacy policy',
                onTap: () {
                  _showPrivacyPolicyDialog();
                },
              ),
              _buildListTile(
                icon: Icons.description,
                title: 'Terms of Service',
                subtitle: 'Read our terms and conditions',
                onTap: () {
                  _showTermsOfServiceDialog();
                },
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestView() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy'),
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
                Icons.lock,
                size: 80,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 24),
              const Text(
                'Sign in to manage your privacy settings',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Control your data, privacy, and communication preferences when you sign in to your account.',
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

  Widget _buildPrivacyOverview() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade400, Colors.purple.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.security, color: Colors.white, size: 24),
              SizedBox(width: 8),
              Text(
                'Your Privacy Matters',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Take control of your data and privacy. Customize your settings to match your preferences.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildPrivacyStat('Data Control', Icons.settings),
              const SizedBox(width: 24),
              _buildPrivacyStat('Secure Storage', Icons.lock),
              const SizedBox(width: 24),
              _buildPrivacyStat('Your Choice', Icons.check_circle),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyStat(String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildPrivacyCard(List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(children: children),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF957DAD)),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[600],
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF957DAD)),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[600],
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF957DAD),
      ),
    );
  }

  void _showDownloadDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Download My Data'),
        content: const Text(
          'We will prepare a copy of all your data and send it to your email address within 24 hours.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Data download request submitted')),
              );
            },
            child: const Text('Request Download'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'This action cannot be undone. All your data will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showDeleteConfirmationDialog();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Final Confirmation'),
        content: const Text(
          'Type "DELETE" to confirm account deletion. This action is irreversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Account deletion feature coming soon')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'This is a placeholder for the privacy policy. In a real app, this would contain detailed information about:\n\n'
            '• What data we collect\n'
            '• How we use your data\n'
            '• How we protect your data\n'
            '• Your rights and choices\n'
            '• Contact information\n\n'
            'The complete privacy policy would be available at our website.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showTermsOfServiceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms of Service'),
        content: const SingleChildScrollView(
          child: Text(
            'This is a placeholder for the terms of service. In a real app, this would contain detailed information about:\n\n'
            '• User responsibilities\n'
            '• App usage guidelines\n'
            '• Intellectual property rights\n'
            '• Limitation of liability\n'
            '• Dispute resolution\n\n'
            'The complete terms of service would be available at our website.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
