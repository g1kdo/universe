// lib/ui/components/club_form.dart
import 'dart:io';
import 'package:flutter/material.dart';
import '../../../models/club_model.dart';
import '../../../services/firestore_service.dart';
import '../../../services/storage_service.dart';
import '../image_picker_widget.dart';

class ClubForm extends StatefulWidget {
  final Club? club;
  final String userId;
  final String userName;
  final String? userEmail;
  final VoidCallback? onSuccess;

  const ClubForm({
    Key? key,
    this.club,
    required this.userId,
    required this.userName,
    this.userEmail,
    this.onSuccess,
  }) : super(key: key);

  @override
  State<ClubForm> createState() => _ClubFormState();
}

class _ClubFormState extends State<ClubForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _meetingScheduleController = TextEditingController();
  final _meetingLocationController = TextEditingController();
  final _websiteController = TextEditingController();
  final _socialMediaController = TextEditingController();
  final _contactInfoController = TextEditingController();
  final _maxMembersController = TextEditingController();
  final _tagsController = TextEditingController();
  final _firestoreService = FirestoreService();

  String _category = 'other';
  File? _selectedImage;
  bool _isLoading = false;

  final List<String> _categories = [
    'academic',
    'sports',
    'cultural',
    'social',
    'professional',
    'other',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.club != null) {
      _nameController.text = widget.club!.name;
      _descriptionController.text = widget.club!.description;
      _meetingScheduleController.text = widget.club!.meetingSchedule;
      _meetingLocationController.text = widget.club!.meetingLocation;
      _websiteController.text = widget.club!.website ?? '';
      _socialMediaController.text = widget.club!.socialMedia ?? '';
      _contactInfoController.text = widget.club!.contactInfo ?? '';
      _maxMembersController.text = widget.club!.maxMembers.toString();
      _tagsController.text = widget.club!.tags.join(', ');
      _category = widget.club!.category;
    } else {
      _maxMembersController.text = '50'; // Default value
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _meetingScheduleController.dispose();
    _meetingLocationController.dispose();
    _websiteController.dispose();
    _socialMediaController.dispose();
    _contactInfoController.dispose();
    _maxMembersController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      String? logoUrl;

      // Upload logo if selected
      if (_selectedImage != null) {
        logoUrl = await StorageService.uploadClubLogo(_selectedImage!);
        if (logoUrl == null) {
          _showErrorSnackBar('Failed to upload logo. Please try again.');
          setState(() {
            _isLoading = false;
          });
          return;
        }
      } else if (widget.club?.logoUrl != null) {
        // Keep existing logo URL if no new image selected
        logoUrl = widget.club!.logoUrl;
      }

      // Parse tags
      final tags = _tagsController.text
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();

      // Parse max members
      final maxMembers = int.tryParse(_maxMembersController.text) ?? 50;

      final club = Club(
        id: widget.club?.id ?? '',
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _category,
        logoUrl: logoUrl,
        presidentId: widget.userId,
        presidentName: widget.userName,
        presidentEmail: widget.userEmail,
        memberIds: widget.club?.memberIds ?? [widget.userId],
        adminIds: widget.club?.adminIds ?? [widget.userId],
        maxMembers: maxMembers,
        meetingSchedule: _meetingScheduleController.text.trim(),
        meetingLocation: _meetingLocationController.text.trim(),
        tags: tags,
        createdAt: widget.club?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: widget.club?.isActive ?? true,
        website: _websiteController.text.trim().isEmpty ? null : _websiteController.text.trim(),
        socialMedia: _socialMediaController.text.trim().isEmpty ? null : _socialMediaController.text.trim(),
        contactInfo: _contactInfoController.text.trim().isEmpty ? null : _contactInfoController.text.trim(),
      );

      if (widget.club != null) {
        // Update existing club
        await _firestoreService.updateClub(club);
        _showSuccessSnackBar('Club updated successfully!');
      } else {
        // Create new club
        await _firestoreService.addClub(club);
        _showSuccessSnackBar('Club created successfully!');
      }

      if (widget.onSuccess != null) {
        widget.onSuccess!();
      }
      Navigator.pop(context);
    } catch (e) {
      _showErrorSnackBar('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.club != null ? 'Edit Club' : 'Create Club'),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo Picker
              ImagePickerWidget(
                initialImageUrl: widget.club?.logoUrl,
                label: 'Club Logo',
                hint: 'Upload a logo for your club',
                onImageChanged: (url) {
                  // This will be called when image is selected
                },
                width: 150,
                height: 150,
              ),
              const SizedBox(height: 24),

              // Club Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Club Name *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a club name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description *',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Category
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(
                  labelText: 'Category *',
                  border: OutlineInputBorder(),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category.toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _category = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Meeting Schedule
              TextFormField(
                controller: _meetingScheduleController,
                decoration: const InputDecoration(
                  labelText: 'Meeting Schedule *',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., Every Tuesday 6:00 PM',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter meeting schedule';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Meeting Location
              TextFormField(
                controller: _meetingLocationController,
                decoration: const InputDecoration(
                  labelText: 'Meeting Location *',
                  border: OutlineInputBorder(),
                  hintText: 'Where do you meet?',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter meeting location';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Max Members
              TextFormField(
                controller: _maxMembersController,
                decoration: const InputDecoration(
                  labelText: 'Maximum Members *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter maximum members';
                  }
                  final number = int.tryParse(value);
                  if (number == null || number < 1) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Tags
              TextFormField(
                controller: _tagsController,
                decoration: const InputDecoration(
                  labelText: 'Tags',
                  border: OutlineInputBorder(),
                  hintText: 'Separate tags with commas (e.g., programming, tech, coding)',
                ),
              ),
              const SizedBox(height: 16),

              // Website
              TextFormField(
                controller: _websiteController,
                decoration: const InputDecoration(
                  labelText: 'Website',
                  border: OutlineInputBorder(),
                  hintText: 'https://example.com',
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 16),

              // Social Media
              TextFormField(
                controller: _socialMediaController,
                decoration: const InputDecoration(
                  labelText: 'Social Media',
                  border: OutlineInputBorder(),
                  hintText: 'Instagram, Facebook, Twitter handles',
                ),
              ),
              const SizedBox(height: 16),

              // Contact Info
              TextFormField(
                controller: _contactInfoController,
                decoration: const InputDecoration(
                  labelText: 'Additional Contact Info',
                  border: OutlineInputBorder(),
                  hintText: 'Any additional contact information',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(widget.club != null ? 'Update Club' : 'Create Club'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}