// lib/ui/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:universe/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Settings state
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  String _selectedLanguage = 'English';
  bool _locationSharing = true;
  bool _dataUsageOptimization = false;

  @override
  void initState() {
    super.initState();
    _loadUserSettings();
  }

  Future<void> _loadUserSettings() async {
    try {
      final userProfile = await _firestoreService.getUserProfile();
      if (userProfile != null) {
        setState(() {
          _notificationsEnabled = userProfile['notificationsEnabled'] ?? true;
          _darkModeEnabled = userProfile['darkModeEnabled'] ?? false;
          _selectedLanguage = userProfile['language'] ?? 'English';
          _locationSharing = userProfile['locationSharing'] ?? true;
          _dataUsageOptimization = userProfile['dataUsageOptimization'] ?? false;
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _saveSettings() async {
    try {
      await _firestoreService.updateUserProfile({
        'notificationsEnabled': _notificationsEnabled,
        'darkModeEnabled': _darkModeEnabled,
        'language': _selectedLanguage,
        'locationSharing': _locationSharing,
        'dataUsageOptimization': _dataUsageOptimization,
        'lastUpdated': DateTime.now().toIso8601String(),
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings saved successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving settings: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
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
            // Account Settings Section
            _buildSectionHeader('Account Settings'),
            _buildSettingsCard([
              _buildListTile(
                icon: Icons.person,
                title: 'Profile Information',
                subtitle: 'Update your personal details',
                onTap: () {
                  _showProfileEditDialog();
                },
              ),
              _buildListTile(
                icon: Icons.email,
                title: 'Email Settings',
                subtitle: _auth.currentUser?.email ?? 'No email',
                onTap: () {
                  _showEmailSettingsDialog();
                },
              ),
              _buildListTile(
                icon: Icons.security,
                title: 'Change Password',
                subtitle: 'Update your account password',
                onTap: () {
                  _showChangePasswordDialog();
                },
              ),
            ]),

            const SizedBox(height: 24),

            // App Settings Section
            _buildSectionHeader('App Settings'),
            _buildSettingsCard([
              _buildSwitchTile(
                icon: Icons.notifications,
                title: 'Push Notifications',
                subtitle: 'Receive notifications about events and updates',
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                },
              ),
              _buildSwitchTile(
                icon: Icons.dark_mode,
                title: 'Dark Mode',
                subtitle: 'Switch between light and dark themes',
                value: _darkModeEnabled,
                onChanged: (value) {
                  setState(() {
                    _darkModeEnabled = value;
                  });
                },
              ),
              _buildListTile(
                icon: Icons.language,
                title: 'Language',
                subtitle: _selectedLanguage,
                onTap: () {
                  _showLanguageSelectionDialog();
                },
              ),
            ]),

            const SizedBox(height: 24),

            // Privacy & Security Section
            _buildSectionHeader('Privacy & Security'),
            _buildSettingsCard([
              _buildSwitchTile(
                icon: Icons.location_on,
                title: 'Location Sharing',
                subtitle: 'Allow app to access your location for nearby features',
                value: _locationSharing,
                onChanged: (value) {
                  setState(() {
                    _locationSharing = value;
                  });
                },
              ),
              _buildSwitchTile(
                icon: Icons.data_usage,
                title: 'Data Usage Optimization',
                subtitle: 'Reduce data usage for better performance',
                value: _dataUsageOptimization,
                onChanged: (value) {
                  setState(() {
                    _dataUsageOptimization = value;
                  });
                },
              ),
              _buildListTile(
                icon: Icons.privacy_tip,
                title: 'Privacy Policy',
                subtitle: 'Read our privacy policy',
                onTap: () {
                  _showPrivacyPolicyDialog();
                },
              ),
            ]),

            const SizedBox(height: 24),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Save Settings',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // App Info Section
            _buildSectionHeader('App Information'),
            _buildSettingsCard([
              _buildListTile(
                icon: Icons.info,
                title: 'App Version',
                subtitle: '1.0.0',
                onTap: null,
              ),
              _buildListTile(
                icon: Icons.help,
                title: 'Help & Support',
                subtitle: 'Get help and contact support',
                onTap: () {
                  _showHelpDialog();
                },
              ),
              _buildListTile(
                icon: Icons.star,
                title: 'Rate App',
                subtitle: 'Rate us on the app store',
                onTap: () {
                  _showRateAppDialog();
                },
              ),
            ]),
          ],
        ),
      ),
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

  Widget _buildSettingsCard(List<Widget> children) {
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
    required VoidCallback? onTap,
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
      trailing: onTap != null ? const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey) : null,
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

  void _showProfileEditDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: const Text('Profile editing feature will be available soon.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showEmailSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Email Settings'),
        content: const Text('Email settings feature will be available soon.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: const Text('Password change feature will be available soon.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showLanguageSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('English'),
              value: 'English',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value!;
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Spanish'),
              value: 'Spanish',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value!;
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('French'),
              value: 'French',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value!;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
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
            'This is a placeholder for the privacy policy. In a real app, this would contain detailed information about how user data is collected, used, and protected.',
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

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: const Text('For help and support, please contact us at support@universe.app'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showRateAppDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rate App'),
        content: const Text('Thank you for using UniVerse! Please rate us on the app store.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Maybe Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // In a real app, this would open the app store
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Thank you for rating!')),
              );
            },
            child: const Text('Rate Now'),
          ),
        ],
      ),
    );
  }
}
