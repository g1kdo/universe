// lib/ui/components/event_card.dart
import 'package:flutter/material.dart';
import 'package:universe/models/event_model.dart';
import 'package:universe/services/firestore_service.dart';
import 'package:universe/ui/components/modals/event_details_modal.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

/// Component for a single Event card.
class EventCard extends StatefulWidget {
  final Event event;
  final VoidCallback? onRegistrationChanged;

  const EventCard({
    super.key,
    required this.event,
    this.onRegistrationChanged,
  });

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = false;
  bool _isRegistered = false;

  @override
  void initState() {
    super.initState();
    _checkRegistrationStatus();
  }

  Future<void> _checkRegistrationStatus() async {
    try {
      final isRegistered = await _firestoreService.isUserRegisteredForEvent(widget.event.id);
      if (mounted) {
        setState(() {
          _isRegistered = isRegistered;
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _toggleRegistration() async {
    if (_isLoading) return;

    // Check if user is authenticated
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showLoginPrompt();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isRegistered) {
        await _firestoreService.unregisterFromEvent(widget.event.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Unregistered from event')),
          );
        }
      } else {
        await _firestoreService.registerForEvent(widget.event.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registered for event!')),
          );
        }
      }

      setState(() {
        _isRegistered = !_isRegistered;
      });

      widget.onRegistrationChanged?.call();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showLoginPrompt() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sign In Required'),
          content: const Text(
            'Please sign in or create an account to register for events and access all features.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate to login screen
                Navigator.pushNamed(context, '/login');
              },
              child: const Text('Sign In'),
            ),
          ],
        );
      },
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'academic':
        return Icons.school;
      case 'sports':
        return Icons.sports;
      case 'cultural':
        return Icons.palette;
      case 'social':
        return Icons.people;
      case 'workshop':
        return Icons.work;
      case 'conference':
        return Icons.business;
      default:
        return Icons.event;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'academic':
        return Colors.blue;
      case 'sports':
        return Colors.green;
      case 'cultural':
        return Colors.purple;
      case 'social':
        return Colors.orange;
      case 'workshop':
        return Colors.teal;
      case 'conference':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryIcon = _getCategoryIcon(widget.event.category);
    final categoryColor = _getCategoryColor(widget.event.category);
    final formattedDate = DateFormat('MMM dd, yyyy').format(widget.event.date);
    final now = DateTime.now();
    final eventDate = widget.event.date;
    final isEventPassed = eventDate.isBefore(now);

    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => EventDetailsModal(
            event: widget.event,
            onRegistrationChanged: widget.onRegistrationChanged,
          ),
        );
      },
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.only(bottom: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: categoryColor.withValues(alpha:0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    categoryIcon,
                    color: categoryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                // Event Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                        widget.event.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 14, color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.6)),
                      const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              widget.event.location,
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.7),
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 14, color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.6)),
                      const SizedBox(width: 4),
                      Text(
                            formattedDate,
                            style: TextStyle(
                              fontSize: 13,
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.7),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.access_time, size: 14, color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.6)),
                          const SizedBox(width: 4),
                          Text(
                            widget.event.time,
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.7),
                        ),
                      ),
                    ],
                  ),
                      if (widget.event.description.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          widget.event.description,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.6),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Registration Info and Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${widget.event.registeredUsers.length}/${widget.event.maxParticipants} registered',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.6),
                  ),
                ),
                // Show different button based on event status
                if (isEventPassed)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Passed',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                else
                  ElevatedButton(
                    onPressed: _isLoading ? null : _toggleRegistration,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isRegistered ? Colors.red : Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.onPrimary),
                            ),
                          )
                        : Text(
                            _isRegistered ? 'Unregister' : 'Register',
                            style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onPrimary),
                          ),
                  ),
              ],
            ),
          ],
        ),
        ),
      ),
    );
  }
}