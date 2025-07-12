// lib/ui/screens/schedule_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:universe/ui/components/cards/schedule_card.dart'; // Import ScheduleCard

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  DateTime _selectedDate = DateTime.now(); // Current selected date
  final List<String> _daysOfWeek = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  // Example schedule data for the selected date
  final List<Map<String, dynamic>> _scheduleData = [
    {
      'time_start': '11:35',
      'time_end': '13:05',
      'title': 'Computer Science',
      'subtitle': 'Lecture 2: Data management',
      'room': 'Room 2 - 134',
      'instructor': 'Mom Laila Khalid',
      'color': const Color(0xFFD9F7D4), // Light Green
    },
    {
      'time_start': '13:15',
      'time_end': '14:45',
      'title': 'Digital Marketing',
      'subtitle': 'Lecture 3: Shopify Creation',
      'room': 'Room 3A - 04',
      'instructor': 'Mom Hira',
      'color': const Color(0xFFFFF9C4), // Light Yellow
    },
    {
      'time_start': '15:10',
      'time_end': '16:40',
      'title': 'Digital Marketing',
      'subtitle': 'Lecture 3: Shopify Creation',
      'room': 'Room 7B - 81',
      'instructor': 'Mom Hira',
      'color': const Color(0xFFD3E0EA), // Light Blue/Gray
    },
  ];

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
              child: Row(
                children: [
                  // Time Column
                  Container(
                    width: 80, // Fixed width for time column
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: _scheduleData.map((event) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0 + 8.0), // Match card margin + some extra
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                event['time_start'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                event['time_end'],
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
                  // Courses/Events Column
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.only(right: 16.0), // Padding on the right
                      itemCount: _scheduleData.length,
                      itemBuilder: (context, index) {
                        final event = _scheduleData[index];
                        return ScheduleCard(
                          title: event['title'],
                          subtitle: event['subtitle'],
                          room: event['room'],
                          instructor: event['instructor'],
                          cardColor: event['color'],
                        );
                      },
                    ),
                  ),
                ],
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
