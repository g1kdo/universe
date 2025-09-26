// lib/ui/components/modals/event_details_modal.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:universe/models/event_model.dart';
import 'package:universe/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class EventDetailsModal extends ConsumerStatefulWidget {
  final Event event;
  final VoidCallback? onRegistrationChanged;

  const EventDetailsModal({
    super.key,
    required this.event,
    this.onRegistrationChanged,
  });

  @override
  ConsumerState<EventDetailsModal> createState() => _EventDetailsModalState();
}

class _EventDetailsModalState extends ConsumerState<EventDetailsModal> {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isRegistering = false;

  bool get isRegistered {
    return _auth.currentUser != null && 
           widget.event.registeredUsers.contains(_auth.currentUser!.uid);
  }

  bool get isEventFull {
    return widget.event.registeredUsers.length >= widget.event.maxParticipants;
  }

  bool get isEventPast {
    return widget.event.date.isBefore(DateTime.now());
  }

  Future<void> _toggleRegistration() async {
    if (_auth.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please sign in to register for events'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    if (isEventPast) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('This event has already passed'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    setState(() {
      _isRegistering = true;
    });

    try {
      if (isRegistered) {
        await _firestoreService.unregisterFromEvent(widget.event.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully unregistered from event'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      } else {
        if (isEventFull) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('This event is full'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
          return;
        }
        await _firestoreService.registerForEvent(widget.event.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully registered for event'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
      
      if (widget.onRegistrationChanged != null) {
        widget.onRegistrationChanged!();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      setState(() {
        _isRegistering = false;
      });
    }
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
        return Icons.build;
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
    final formattedDate = DateFormat('EEEE, MMM dd, yyyy').format(widget.event.date);
    final categoryIcon = _getCategoryIcon(widget.event.category);
    final categoryColor = _getCategoryColor(widget.event.category);
    final registrationCount = widget.event.registeredUsers.length;
    final spotsLeft = widget.event.maxParticipants - registrationCount;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: categoryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    categoryIcon,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Event Details',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      widget.event.title,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Event Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isEventPast 
                            ? Theme.of(context).colorScheme.error.withValues(alpha: 0.1)
                            : isEventFull 
                                ? Theme.of(context).colorScheme.error.withValues(alpha: 0.1)
                                : Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isEventPast 
                              ? Theme.of(context).colorScheme.error
                              : isEventFull 
                                  ? Theme.of(context).colorScheme.error
                                  : Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      child: Text(
                        isEventPast 
                            ? 'PAST EVENT'
                            : isEventFull 
                                ? 'FULL'
                                : 'UPCOMING',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isEventPast 
                              ? Theme.of(context).colorScheme.error
                              : isEventFull 
                                  ? Theme.of(context).colorScheme.error
                                  : Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Meta Information
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          _buildInfoRow(
                            Icons.calendar_today,
                            'Date',
                            formattedDate,
                          ),
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            Icons.access_time,
                            'Time',
                            widget.event.time,
                          ),
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            Icons.location_on,
                            'Location',
                            widget.event.location,
                          ),
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            Icons.person,
                            'Organizer',
                            widget.event.organizer,
                          ),
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            Icons.category,
                            'Category',
                            widget.event.category.toUpperCase(),
                          ),
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            Icons.people,
                            'Participants',
                            '$registrationCount/${widget.event.maxParticipants}',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Image (if available)
                    if (widget.event.imageUrl != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          widget.event.imageUrl!,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 200,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.image_not_supported,
                                  size: 48,
                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Description
                    Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.event.description,
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onSurface,
                        height: 1.5,
                      ),
                    ),

                    // Registration Status
                    if (_auth.currentUser != null) ...[
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isRegistered 
                              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                              : Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isRegistered 
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isEventPast 
                                  ? Icons.event_busy
                                  : isRegistered 
                                      ? Icons.check_circle 
                                      : Icons.event_available,
                              color: isEventPast
                                  ? Colors.grey
                                  : isRegistered 
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                isEventPast
                                    ? 'This event has passed'
                                    : isRegistered 
                                        ? 'You are registered for this event'
                                        : isEventFull 
                                            ? 'Event is full'
                                            : 'You are not registered for this event',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isEventPast
                                      ? Colors.grey
                                      : isRegistered 
                                          ? Theme.of(context).colorScheme.primary
                                          : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                                  fontWeight: isRegistered ? FontWeight.w500 : FontWeight.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Spots Left Info
                  if (!isEventPast && !isEventFull)
                    Text(
                      '$spotsLeft spots left',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    )
                  else
                    const SizedBox.shrink(),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (_auth.currentUser != null && !isEventPast)
                        ElevatedButton.icon(
                          onPressed: _isRegistering ? null : _toggleRegistration,
                          icon: _isRegistering 
                              ? SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Theme.of(context).colorScheme.onPrimary,
                                  ),
                                )
                              : Icon(
                                  isRegistered ? Icons.event_busy : Icons.event_available,
                                  size: 18,
                                ),
                          label: Text(
                            _isRegistering
                                ? 'Processing...'
                                : isRegistered 
                                    ? 'Unregister'
                                    : isEventFull 
                                        ? 'Full'
                                        : 'Register',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isRegistered 
                                ? Theme.of(context).colorScheme.error
                                : Theme.of(context).colorScheme.primary,
                            foregroundColor: isRegistered 
                                ? Theme.of(context).colorScheme.onError
                                : Theme.of(context).colorScheme.onPrimary,
                          ),
                        )
                      else if (isEventPast)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.event_busy,
                                size: 18,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Event Passed',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
