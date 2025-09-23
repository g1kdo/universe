// lib/ui/components/lost_found_form.dart
import 'dart:io';
import 'package:flutter/material.dart';
import '../../../models/lost_found_model.dart';
import '../../../services/firestore_service.dart';
import '../../../services/storage_service.dart';
import '../image_picker_widget.dart';

class LostFoundForm extends StatefulWidget {
  final LostFoundItem? item;
  final String userId;
  final String userName;
  final String? userEmail;
  final String? userPhone;
  final VoidCallback? onSuccess;

  const LostFoundForm({
    Key? key,
    this.item,
    required this.userId,
    required this.userName,
    this.userEmail,
    this.userPhone,
    this.onSuccess,
  }) : super(key: key);

  @override
  State<LostFoundForm> createState() => _LostFoundFormState();
}

class _LostFoundFormState extends State<LostFoundForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();
  final _firestoreService = FirestoreService();

  String _type = 'lost'; // Always default to 'lost' for new items
  String _category = 'other';
  File? _selectedImage;
  bool _isLoading = false;

  final List<String> _categories = [
    'electronics',
    'clothing',
    'books',
    'accessories',
    'other',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _titleController.text = widget.item!.title;
      _descriptionController.text = widget.item!.description;
      _locationController.text = widget.item!.location;
      _notesController.text = widget.item!.notes ?? '';
      _type = widget.item!.type;
      _category = widget.item!.category;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      String? imageUrl;

      // Upload image if selected
      if (_selectedImage != null) {
        imageUrl = await StorageService.uploadLostFoundImage(_selectedImage!);
        if (imageUrl == null) {
          _showErrorSnackBar('Failed to upload image. Please try again.');
          setState(() {
            _isLoading = false;
          });
          return;
        }
      } else if (widget.item?.imageUrl != null) {
        // Keep existing image URL if no new image selected
        imageUrl = widget.item!.imageUrl;
      }

      final item = LostFoundItem(
        id: widget.item?.id ?? '',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        type: _type,
        category: _category,
        location: _locationController.text.trim(),
        imageUrl: imageUrl,
        reporterId: widget.userId,
        reporterName: widget.userName,
        reporterEmail: widget.userEmail,
        reporterPhone: widget.userPhone,
        reportedAt: widget.item?.reportedAt ?? DateTime.now(),
        isResolved: widget.item?.isResolved ?? false,
        resolvedBy: widget.item?.resolvedBy,
        resolvedAt: widget.item?.resolvedAt,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );

      if (widget.item != null) {
        // Update existing item
        await _firestoreService.updateLostFoundItem(item);
        _showSuccessSnackBar('Lost item updated successfully!');
      } else {
        // Create new item
        await _firestoreService.addLostFoundItem(item);
        _showSuccessSnackBar('Lost item reported successfully!');
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
        title: Text(widget.item != null ? 'Edit Lost Item' : 'Report Lost Item'),
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
              // Image Picker
              ImagePickerWidget(
                initialImageUrl: widget.item?.imageUrl,
                label: 'Item Photo',
                hint: 'Take a photo or select from gallery',
                onImageChanged: (url) {
                  // This will be called when image is selected
                },
                width: 200,
                height: 150,
              ),
              const SizedBox(height: 24),

              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
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

              // Location
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location *',
                  border: OutlineInputBorder(),
                  hintText: 'Where was it lost/found?',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the location';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Notes
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Additional Notes',
                  border: OutlineInputBorder(),
                  hintText: 'Any additional information...',
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
                      : Text(widget.item != null ? 'Update Lost Item' : 'Report Lost Item'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}