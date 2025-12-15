// lib/ui/screens/settings_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:universe/services/firestore_service.dart';
import 'package:universe/services/auth_service.dart';
import 'package:universe/services/storage_service.dart';
import 'package:universe/providers/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Settings state
  bool _notificationsEnabled = true;
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

  Widget _buildThemeSwitchTile() {
    final themeMode = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    
    String getThemeSubtitle() {
      switch (themeMode) {
        case ThemeMode.light:
          return 'Light theme';
        case ThemeMode.dark:
          return 'Dark theme';
        case ThemeMode.system:
          return 'Follow system theme';
      }
    }

    return ListTile(
      leading: Icon(
        themeMode == ThemeMode.dark ? Icons.dark_mode : 
        themeMode == ThemeMode.light ? Icons.light_mode : Icons.brightness_auto,
        color: Theme.of(context).colorScheme.primary,
      ),
      title: Text(
        'Theme',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        getThemeSubtitle(),
        style: TextStyle(
          fontSize: 14,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.7),
        ),
      ),
      trailing: Switch(
        value: themeMode == ThemeMode.dark,
        onChanged: (value) {
          themeNotifier.toggleTheme();
        },
        activeColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Theme.of(context).colorScheme.onSurface),
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
              if (_authService.isEmailPasswordUser())
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
              _buildThemeSwitchTile(),
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
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface,
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
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.7),
        ),
      ),
      trailing: onTap != null ? Icon(Icons.arrow_forward_ios, size: 16, color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.5)) : null,
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
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.7),
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  void _showProfileEditDialog() async {
    final userProfile = await _firestoreService.getUserProfile();
    final currentUser = _auth.currentUser;
    
    final nameController = TextEditingController(
      text: userProfile?['name'] ?? currentUser?.displayName ?? '',
    );
    final locationController = TextEditingController(
      text: userProfile?['location'] ?? 'Campus',
    );
    
    // Get current profile image URL
    String? currentImageUrl = userProfile?['profileImageUrl'] ?? currentUser?.photoURL;
    
    final formKey = GlobalKey<FormState>();
    bool isLoading = false;
    File? selectedImageFile;
    String? imageUrl = currentImageUrl;
    bool isUploadingImage = false;
    
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Profile'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Profile Picture Section
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                          backgroundImage: selectedImageFile != null
                              ? FileImage(selectedImageFile!)
                              : imageUrl != null
                                  ? NetworkImage(imageUrl!)
                                  : null,
                          child: (selectedImageFile == null && imageUrl == null)
                              ? Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                )
                              : null,
                        ),
                        if (isUploadingImage)
                          const Positioned.fill(
                            child: CircularProgressIndicator(),
                          ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            child: IconButton(
                              icon: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
                              onPressed: isLoading || isUploadingImage
                                  ? null
                                  : () async {
                                      // Show image source selection
                                      final ImageSource? source = await showModalBottomSheet<ImageSource>(
                                        context: context,
                                        builder: (BuildContext bottomSheetContext) {
                                          return SafeArea(
                                            child: Wrap(
                                              children: [
                                                ListTile(
                                                  leading: const Icon(Icons.camera_alt),
                                                  title: const Text('Camera'),
                                                  onTap: () => Navigator.pop(bottomSheetContext, ImageSource.camera),
                                                ),
                                                ListTile(
                                                  leading: const Icon(Icons.photo_library),
                                                  title: const Text('Gallery'),
                                                  onTap: () => Navigator.pop(bottomSheetContext, ImageSource.gallery),
                                                ),
                                                if (imageUrl != null || selectedImageFile != null)
                                                  ListTile(
                                                    leading: const Icon(Icons.delete, color: Colors.red),
                                                    title: const Text('Remove Photo', style: TextStyle(color: Colors.red)),
                                                    onTap: () {
                                                      Navigator.pop(bottomSheetContext);
                                                      setDialogState(() {
                                                        selectedImageFile = null;
                                                        imageUrl = null;
                                                      });
                                                    },
                                                  ),
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                      
                                      if (source != null) {
                                        setDialogState(() {
                                          isUploadingImage = true;
                                        });
                                        
                                        final File? pickedImage = await StorageService.pickImage(source: source);
                                        
                                        if (pickedImage != null) {
                                          setDialogState(() {
                                            selectedImageFile = pickedImage;
                                            isUploadingImage = false;
                                          });
                                        } else {
                                          setDialogState(() {
                                            isUploadingImage = false;
                                          });
                                        }
                                      }
                                    },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: locationController,
                    decoration: const InputDecoration(
                      labelText: 'Location',
                      border: OutlineInputBorder(),
                      hintText: 'e.g., Campus, Building A',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your location';
                      }
                      return null;
                    },
                  ),
                  if (isLoading)
                    const Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: CircularProgressIndicator(),
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isLoading || isUploadingImage ? null : () async {
                if (formKey.currentState!.validate()) {
                  setDialogState(() {
                    isLoading = true;
                  });
                  
                  try {
                    String? newImageUrl = imageUrl;
                    
                    // Upload new profile picture if selected
                    if (selectedImageFile != null && currentUser != null) {
                      // Delete old image from storage if it exists and is not from Google
                      if (currentImageUrl != null && 
                          !currentImageUrl.contains('googleusercontent.com') &&
                          !currentImageUrl.contains('googleapis.com')) {
                        try {
                          await StorageService.deleteImage(currentImageUrl!);
                        } catch (e) {
                          // Ignore deletion errors
                          debugPrint('Error deleting old profile image: $e');
                        }
                      }
                      
                      // Upload new image
                      newImageUrl = await StorageService.uploadProfilePicture(
                        selectedImageFile!,
                        currentUser.uid,
                      );
                      
                      if (newImageUrl == null) {
                        throw Exception('Failed to upload profile picture');
                      }
                      
                      // Update Firebase Auth photoURL
                      await currentUser.updatePhotoURL(newImageUrl);
                    } else if (imageUrl == null && currentImageUrl != null && currentUser != null) {
                      // User removed the profile picture
                      // Delete old image from storage if it exists and is not from Google
                      if (!currentImageUrl.contains('googleusercontent.com') &&
                          !currentImageUrl.contains('googleapis.com')) {
                        try {
                          await StorageService.deleteImage(currentImageUrl!);
                        } catch (e) {
                          // Ignore deletion errors
                          debugPrint('Error deleting old profile image: $e');
                        }
                      }
                      
                      // Note: Firebase Auth doesn't allow setting photoURL to null
                      // We'll just update Firestore, and the app will use Firestore profileImageUrl
                      // which will be null, effectively removing the profile picture
                    }
                    
                    // Update Firebase Auth display name
                    await currentUser?.updateDisplayName(nameController.text.trim());
                    await currentUser?.reload();
                    
                    // Update Firestore profile
                    final profileUpdate = <String, dynamic>{
                      'name': nameController.text.trim(),
                      'location': locationController.text.trim(),
                      'updatedAt': DateTime.now().toIso8601String(),
                    };
                    
                    // Update profileImageUrl - use FieldValue.delete() to remove, or set new URL if updated
                    if (imageUrl == null && currentImageUrl != null) {
                      // User removed the profile picture - delete the field
                      profileUpdate['profileImageUrl'] = FieldValue.delete();
                    } else if (newImageUrl != null) {
                      // User uploaded a new profile picture
                      profileUpdate['profileImageUrl'] = newImageUrl;
                    }
                    
                    await _firestoreService.updateUserProfile(profileUpdate);
                    
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Profile updated successfully')),
                      );
                      setState(() {}); // Refresh UI
                    }
                  } catch (e) {
                    setDialogState(() {
                      isLoading = false;
                    });
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error updating profile: $e')),
                      );
                    }
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEmailSettingsDialog() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null || !_authService.isEmailPasswordUser()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email can only be changed for email/password accounts')),
      );
      return;
    }
    
    final emailController = TextEditingController(
      text: currentUser.email ?? '',
    );
    final passwordController = TextEditingController();
    
    final formKey = GlobalKey<FormState>();
    bool isLoading = false;
    bool obscurePassword = true;
    
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Update Email'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Enter your current password and new email address',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: 'Current Password',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(obscurePassword ? Icons.visibility : Icons.visibility_off),
                        onPressed: () {
                          setDialogState(() {
                            obscurePassword = !obscurePassword;
                          });
                        },
                      ),
                    ),
                    obscureText: obscurePassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your current password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'New Email',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a new email address';
                      }
                      if (value == currentUser.email) {
                        return 'New email must be different from current email';
                      }
                      if (!value.contains('@') || !value.contains('.')) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  if (isLoading)
                    const Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: CircularProgressIndicator(),
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isLoading ? null : () async {
                if (formKey.currentState!.validate()) {
                  setDialogState(() {
                    isLoading = true;
                  });
                  
                  try {
                    await _authService.updateEmail(
                      emailController.text.trim(),
                      passwordController.text,
                    );
                    
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Email updated successfully')),
                      );
                      setState(() {}); // Refresh UI
                    }
                  } catch (e) {
                    setDialogState(() {
                      isLoading = false;
                    });
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error updating email: $e')),
                      );
                    }
                  }
                }
              },
              child: const Text('Update Email'),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog() async {
    if (!_authService.isEmailPasswordUser()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password change is only available for email/password accounts')),
      );
      return;
    }
    
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    
    final formKey = GlobalKey<FormState>();
    bool isLoading = false;
    bool obscureCurrentPassword = true;
    bool obscureNewPassword = true;
    bool obscureConfirmPassword = true;
    
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Change Password'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: currentPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Current Password',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(obscureCurrentPassword ? Icons.visibility : Icons.visibility_off),
                        onPressed: () {
                          setDialogState(() {
                            obscureCurrentPassword = !obscureCurrentPassword;
                          });
                        },
                      ),
                    ),
                    obscureText: obscureCurrentPassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your current password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: newPasswordController,
                    decoration: InputDecoration(
                      labelText: 'New Password',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(obscureNewPassword ? Icons.visibility : Icons.visibility_off),
                        onPressed: () {
                          setDialogState(() {
                            obscureNewPassword = !obscureNewPassword;
                          });
                        },
                      ),
                    ),
                    obscureText: obscureNewPassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a new password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      if (value == currentPasswordController.text) {
                        return 'New password must be different from current password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Confirm New Password',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                        onPressed: () {
                          setDialogState(() {
                            obscureConfirmPassword = !obscureConfirmPassword;
                          });
                        },
                      ),
                    ),
                    obscureText: obscureConfirmPassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your new password';
                      }
                      if (value != newPasswordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  if (isLoading)
                    const Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: CircularProgressIndicator(),
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isLoading ? null : () async {
                if (formKey.currentState!.validate()) {
                  setDialogState(() {
                    isLoading = true;
                  });
                  
                  try {
                    await _authService.updatePassword(
                      currentPasswordController.text,
                      newPasswordController.text,
                    );
                    
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Password updated successfully')),
                      );
                    }
                  } catch (e) {
                    setDialogState(() {
                      isLoading = false;
                    });
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error updating password: $e')),
                      );
                    }
                  }
                }
              },
              child: const Text('Change Password'),
            ),
          ],
        ),
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
