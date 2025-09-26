// lib/ui/screens/schedule_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:universe/ui/components/cards/schedule_card.dart';
import 'package:universe/services/firestore_service.dart';
import 'package:universe/models/user_schedule_model.dart';
import 'package:universe/ui/screens/notifications_screen.dart';
import 'package:universe/services/notification_service.dart';

class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({super.key});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  DateTime _selectedDate = DateTime.now();
  final List<String> _daysOfWeek = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
  final FirestoreService _firestoreService = FirestoreService();

  Color _getEventColor(String category) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    switch (category.toLowerCase()) {
      case 'academic':
        return isDark ? const Color(0xFF2D4A2D) : const Color(0xFFD9F7D4); // Dark/Light Green
      case 'sports':
        return isDark ? const Color(0xFF2D4A2D) : const Color(0xFFE8F5E8); // Dark/Light Green
      case 'cultural':
        return isDark ? const Color(0xFF4A2D4A) : const Color(0xFFF3E5F5); // Dark/Light Purple
      case 'social':
        return isDark ? const Color(0xFF4A4A2D) : const Color(0xFFFFF9C4); // Dark/Light Yellow
      case 'workshop':
        return isDark ? const Color(0xFF2D3A4A) : const Color(0xFFE3F2FD); // Dark/Light Blue
      case 'conference':
        return isDark ? const Color(0xFF3A3A3A) : const Color(0xFFD3E0EA); // Dark/Light Blue/Gray
      default:
        return isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F5); // Dark/Light Gray
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // --- App Bar Section ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button (if needed, based on navigation flow)
                  // IconButton(
                  //   icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
                  //   onPressed: () {
                  //     Navigator.pop(context);
                  //   },
                  // ),
                  Text(
                    'Schedule',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  StreamBuilder<int>(
                    stream: NotificationService().getUnreadNotificationsCount(),
                    builder: (context, snapshot) {
                      final unreadCount = snapshot.data ?? 0;
                      return Stack(
                        children: [
                          IconButton(
                            icon: Icon(
                              unreadCount > 0 ? Icons.notifications : Icons.notifications_none,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const NotificationsScreen(),
                                ),
                              );
                            },
                          ),
                          if (unreadCount > 0)
                            Positioned(
                              right: 8,
                              top: 8,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                child: Text(
                                  unreadCount > 99 ? '99+' : unreadCount.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // --- Date Picker Section ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        DateFormat('dd').format(_selectedDate), // Day number
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('EEE').format(_selectedDate), // Mon, Tue, etc.
                            style: TextStyle(
                              fontSize: 18,
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                          Text(
                            DateFormat('MMMM,yyyy').format(_selectedDate), // July, 2024
                            style: TextStyle(
                              fontSize: 18,
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Weekday selection chips
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF0F0F0), // Dark/Light grey background for the date row
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(7, (index) {
                        DateTime day = _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1 - index));
                        bool isSelected = day.day == _selectedDate.day && day.month == _selectedDate.month;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedDate = day;
                              // TODO: Fetch schedule for the selected day
                            });
                          },
                          child: Container(
                            width: 45,
                            height: 60,
                            decoration: BoxDecoration(
                              color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent, // Primary color if selected
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _daysOfWeek[index], // S, M, T, W, T, F, S
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  DateFormat('dd').format(day), // Day number
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // --- Schedule List Section ---
            Expanded(
              child: StreamBuilder<List<UserSchedule>>(
                stream: _firestoreService.getUserScheduleForDate(_selectedDate),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary));
                  }
                  
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)));
                  }
                  
                  final scheduleItems = snapshot.data ?? [];
                  
                  if (scheduleItems.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_busy,
                            size: 64,
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No events scheduled for this date',
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  return Row(
                    children: [
                      // Time Column
                      Container(
                        width: 80,
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: scheduleItems.map((event) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16.0 + 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    event.time,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                                  ),
                                  Text(
                                    'Event',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      // Events Column
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.only(right: 16.0),
                          itemCount: scheduleItems.length,
                          itemBuilder: (context, index) {
                            final event = scheduleItems[index];
                            return ScheduleCard(
                              title: event.eventTitle,
                              subtitle: event.eventDescription,
                              room: event.location,
                              instructor: event.organizer,
                              cardColor: _getEventColor(event.category),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      // Bottom Navigation Bar (Assuming it's managed by the parent, e.g., main.dart or a wrapper)
      // If this screen is directly accessed, you might need to add AppBottomNavigationBar here.
    );
  }
}
