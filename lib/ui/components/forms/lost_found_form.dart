// lib/ui/components/forms/lost_found_form.dart
import 'package:flutter/material.dart';
import 'package:universe/models/lost_found_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LostFoundForm extends StatefulWidget {
  final LostFoundItem? item; // null for create, item for edit
  final Function(LostFoundItem) onSubmit;

  const LostFoundForm({
    super.key,
    this.item,
    required this.onSubmit,
  });

  @override
  State<LostFoundForm> createState() => _LostFoundFormState();
}

class _LostFoundFormState extends State<LostFoundForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();
  
  String _selectedType = 'lost';
  String _selectedCategory = 'other';
  String? _imageUrl;

  final List<String> _types = ['lost', 'found'];
  final List<String> _categories = [
    'electronics',
    'clothing', 
    'books',
    'accessories',
    'other'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _titleController.text = widget.item!.title;
      _descriptionController.text = widget.item!.description;
      _locationController.text = widget.item!.location;
      _notesController.text = widget.item!.notes ?? '';
      _selectedType = widget.item!.type;
      _selectedCategory = widget.item!.category;
      _imageUrl = widget.item!.imageUrl;
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

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in to submit')),
        );
        return;
      }

      final item = LostFoundItem(
        id: widget.item?.id ?? '',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        type: _selectedType,
        category: _selectedCategory,
        location: _locationController.text.trim(),
        imageUrl: _imageUrl,
        reporterId: currentUser.uid,
        reporterName: currentUser.displayName ?? 'Anonymous',
        reporterEmail: currentUser.email,
        reporterPhone: null, // You can add phone field if needed
        reportedAt: widget.item?.reportedAt ?? DateTime.now(),
        isResolved: widget.item?.isResolved ?? false,
        resolvedBy: widget.item?.resolvedBy,
        resolvedAt: widget.item?.resolvedAt,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );

      widget.onSubmit(item);
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
            // Type Selection
            Text(
              'Type',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: _types.map((type) {
                return Expanded(
                  child: RadioListTile<String>(
                    title: Text(type.toUpperCase()),
                    value: type,
                    groupValue: _selectedType,
                    onChanged: (value) {
                      setState(() {
                        _selectedType = value!;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title *',
                hintText: 'Brief description of the item',
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
                hintText: 'Detailed description of the item',
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

            // Location
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location *',
                hintText: 'Where was it lost/found?',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter the location';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Image URL (optional)
            TextFormField(
              initialValue: _imageUrl,
              decoration: const InputDecoration(
                labelText: 'Image URL (optional)',
                hintText: 'https://example.com/image.jpg',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                _imageUrl = value.trim().isEmpty ? null : value.trim();
              },
            ),
            const SizedBox(height: 16),

            // Notes (optional)
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Additional Notes (optional)',
                hintText: 'Any additional information',
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
                  widget.item == null ? 'Report Item' : 'Update Item',
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
