// lib/ui/components/forms/club_form.dart
import 'package:flutter/material.dart';
import 'package:universe/models/club_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ClubForm extends StatefulWidget {
  final Club? club; // null for create, club for edit
  final Function(Club) onSubmit;

  const ClubForm({
    super.key,
    this.club,
    required this.onSubmit,
  });

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
  final _tagsController = TextEditingController();
  
  String _selectedCategory = 'other';
  int _maxMembers = 50;
  String? _logoUrl;

  final List<String> _categories = [
    'academic',
    'sports',
    'cultural',
    'social',
    'professional',
    'other'
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
      _tagsController.text = widget.club!.tags.join(', ');
      _selectedCategory = widget.club!.category;
      _maxMembers = widget.club!.maxMembers;
      _logoUrl = widget.club!.logoUrl;
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
    _tagsController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in to submit')),
        );
        return;
      }

      final tags = _tagsController.text
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();

      final club = Club(
        id: widget.club?.id ?? '',
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        logoUrl: _logoUrl,
        presidentId: widget.club?.presidentId ?? currentUser.uid,
        presidentName: widget.club?.presidentName ?? (currentUser.displayName ?? 'Anonymous'),
        presidentEmail: widget.club?.presidentEmail ?? currentUser.email,
        memberIds: widget.club?.memberIds ?? [currentUser.uid],
        adminIds: widget.club?.adminIds ?? [currentUser.uid],
        maxMembers: _maxMembers,
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

      widget.onSubmit(club);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Club Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Club Name *',
                hintText: 'Enter club name',
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
                hintText: 'Describe your club',
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
              value: _selectedCategory,
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
                  _selectedCategory = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            // Max Members
            TextFormField(
              initialValue: _maxMembers.toString(),
              decoration: const InputDecoration(
                labelText: 'Maximum Members *',
                hintText: '50',
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
              onChanged: (value) {
                final number = int.tryParse(value);
                if (number != null && number > 0) {
                  _maxMembers = number;
                }
              },
            ),
            const SizedBox(height: 16),

            // Meeting Schedule
            TextFormField(
              controller: _meetingScheduleController,
              decoration: const InputDecoration(
                labelText: 'Meeting Schedule *',
                hintText: 'e.g., Every Tuesday 6:00 PM',
                border: OutlineInputBorder(),
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
                hintText: 'e.g., Room 201, Main Building',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter meeting location';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Tags
            TextFormField(
              controller: _tagsController,
              decoration: const InputDecoration(
                labelText: 'Tags (optional)',
                hintText: 'coding, programming, tech (comma separated)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Logo URL (optional)
            TextFormField(
              initialValue: _logoUrl,
              decoration: const InputDecoration(
                labelText: 'Logo URL (optional)',
                hintText: 'https://example.com/logo.png',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                _logoUrl = value.trim().isEmpty ? null : value.trim();
              },
            ),
            const SizedBox(height: 16),

            // Website (optional)
            TextFormField(
              controller: _websiteController,
              decoration: const InputDecoration(
                labelText: 'Website (optional)',
                hintText: 'https://example.com',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Social Media (optional)
            TextFormField(
              controller: _socialMediaController,
              decoration: const InputDecoration(
                labelText: 'Social Media (optional)',
                hintText: 'Instagram: @clubname',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Contact Info (optional)
            TextFormField(
              controller: _contactInfoController,
              decoration: const InputDecoration(
                labelText: 'Contact Info (optional)',
                hintText: 'Additional contact information',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  widget.club == null ? 'Create Club' : 'Update Club',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
