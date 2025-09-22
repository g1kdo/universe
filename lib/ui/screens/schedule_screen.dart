// lib/ui/screens/schedule_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:universe/ui/components/cards/schedule_card.dart';
import 'package:universe/services/firestore_service.dart';
import 'package:universe/models/user_schedule_model.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  DateTime _selectedDate = DateTime.now();
  final List<String> _daysOfWeek = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
  final FirestoreService _firestoreService = FirestoreService();

  Color _getEventColor(String category) {
    switch (category.toLowerCase()) {
      case 'academic':
        return const Color(0xFFD9F7D4); // Light Green
      case 'sports':
        return const Color(0xFFE8F5E8); // Light Green
      case 'cultural':
        return const Color(0xFFF3E5F5); // Light Purple
      case 'social':
        return const Color(0xFFFFF9C4); // Light Yellow
      case 'workshop':
        return const Color(0xFFE3F2FD); // Light Blue
      case 'conference':
        return const Color(0xFFD3E0EA); // Light Blue/Gray
      default:
        return const Color(0xFFF5F5F5); // Light Gray
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  const Text(
                    'Schedule',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_none, color: Colors.black87),
                    onPressed: () {
                      // TODO: Handle notifications
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
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
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
                              color: Colors.grey[700],
                            ),
                          ),
                          Text(
                            DateFormat('MMMM,yyyy').format(_selectedDate), // July, 2024
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[700],
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
                      color: const Color(0xFFF0F0F0), // Light grey background for the date row
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
                              color: isSelected ? const Color(0xFFC9A0DC) : Colors.transparent, // Purple if selected
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
                                    color: isSelected ? Colors.white : Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  DateFormat('dd').format(day), // Day number
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? Colors.white : Colors.black87,
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
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  
                  final scheduleItems = snapshot.data ?? [];
                  
                  if (scheduleItems.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_busy,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No events scheduled for this date',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
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
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    'Event',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
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
