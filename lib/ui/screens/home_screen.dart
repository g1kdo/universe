import 'package:flutter/material.dart';
import 'package:universe/ui/components/home_header.dart';
import 'package:universe/ui/components/bars/search_bar_widget.dart';
import 'package:universe/ui/components/sections/filter_chips_section.dart';
import 'package:universe/ui/components/sections/labs_section.dart';
import 'package:universe/ui/components/sections/news_events_tabs.dart';
import 'package:universe/ui/components/sections/news_events_list.dart';
import 'package:universe/ui/components/bars/app_bottom_navigation_bar.dart';
import 'package:universe/ui/screens/community_screen.dart';
import 'package:universe/ui/screens/schedule_screen.dart';
import 'package:universe/ui/screens/profile_screen.dart';
import 'package:universe/ui/screens/maps_screen.dart'; // Import MapsScreen
import 'package:universe/ui/screens/details_screen.dart'; // Import DetailsScreen

// --- Main HomeScreen Widget ---

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedFilter = 'Labs';
  String _selectedNewsEventsTab = 'News';
  int _bottomNavIndex = 0; // State for bottom navigation

  // Placeholder data for the sections
  final List<String> _filterChips = ['Labs', 'Canteen', 'Office', 'Gym', 'Library', 'Hostel'];
  final List<Map<String, String>> _labsData = [
    {'name': 'Chemistry Lab', 'floor': '1 floor', 'image': 'https://placehold.co/400x300/B0E0E6/000000?text=Chemistry', 'accommodation': '100-150 people', 'type': 'Labs', 'description': 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.'},
    {'name': 'Computer Lab', 'floor': '2 floor', 'image': 'https://placehold.co/400x300/ADD8E6/000000?text=Computer', 'accommodation': '80-120 people', 'type': 'Labs', 'description': 'The Computer Lab is equipped with the latest hardware and software, providing students with a cutting-edge environment for programming, research, and project development. It supports various operating systems and specialized applications for different academic needs.'},
    {'name': 'Physics Lab', 'floor': '3 floor', 'image': 'https://placehold.co/400x300/87CEEB/000000?text=Physics', 'accommodation': '70-100 people', 'type': 'Labs', 'description': 'Our Physics Lab offers state-of-the-art equipment for conducting experiments in mechanics, optics, electricity, and magnetism. Students can gain hands-on experience and develop a deeper understanding of physical principles through practical applications and observations.'},
    {'name': 'Research Lab', 'floor': '3 floor', 'image': 'https://placehold.co/400x300/6495ED/000000?text=Research', 'accommodation': '50-70 people', 'type': 'Labs', 'description': 'The Research Lab is dedicated to advanced scientific inquiry and discovery. It provides a collaborative space for faculty and students to work on innovative research projects, equipped with specialized instruments and resources to facilitate groundbreaking studies across various disciplines.'},
  ];
  final List<Map<String, String>> _newsData = [
    {
      'title': 'FBISE',
      'content': 'The Federal Board of Intermediate and Secondary Education (FBISE) has officially announced the date for the results...',
      'date': 'May 01',
    },
    {
      'title': 'Gaza',
      'content': 'The Pakistan Medical and Dental Council (PM&DC) has permitted medical/dental colleges from Gaza to complete their studies...',
      'date': 'June 07',
    },
    {
      'title': 'LUMS',
      'content': 'LUMS recently celebrated the graduation of its largest cohort to date, with over 1500 students receiving degrees...',
      'date': 'May 01',
    },
  ];
  final List<Map<String, String>> _eventsData = [
    {
      'title': 'IDP Study Abroad Expo',
      'location': 'Islamabad',
      'date': 'Wed, 28 Feb 2024',
      'image': 'https://placehold.co/100x80/E0BBE4/FFFFFF?text=Event1',
    },
    {
      'title': 'Pathways to Development Conference',
      'location': 'Lahore',
      'date': 'Fri, 19 Apr 2024',
      'image': 'https://placehold.co/100x80/957DAD/FFFFFF?text=Event2',
    },
    {
      'title': 'IELTS Information Session',
      'location': 'Online',
      'date': 'Mon, 10 Mar 2024',
      'image': 'https://placehold.co/100x80/D291BC/FFFFFF?text=Event3',
    },
  ];


  @override
  Widget build(BuildContext context) {
    // List of screens to navigate to based on bottom navigation bar index
    final List<Widget> screens = [
      _buildHomeScreenContent(), // Content for Home tab (index 0)
      const MapsScreen(), // Map Screen (index 1)
      const ScheduleScreen(), // Schedule Screen (index 2)
      const CommunityScreen(), // Placeholder for Community (index 3)
      const ProfileScreen(), // Profile Screen (index 4)
    ];

    return Scaffold(
      body: SafeArea(
        child: screens[_bottomNavIndex], // Display the selected screen content
      ),
      // Bottom Navigation Bar Component
      bottomNavigationBar: AppBottomNavigationBar(
        currentIndex: _bottomNavIndex,
        onItemSelected: (index) {
          setState(() {
            _bottomNavIndex = index;
          });
          print('Bottom nav item tapped: $index');
        },
      ),
    );
  }

  // Helper method to build the main content of the Home tab
  Widget _buildHomeScreenContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Home Header Component
            const HomeHeader(
              userName: 'Adonai Katy',
              userLocation: 'Second floor, Playroom',
              profileImageUrl: 'https://placehold.co/100x100/A0DCF0/FFFFFF?text=NP',
            ),
            const SizedBox(height: 20),

            // Search Bar Component
            SearchBarWidget(
              onFilterPressed: () {
                // TODO: Implement filter functionality
                print('Filter button pressed!');
              },
            ),
            const SizedBox(height: 20),

            // Filter Chips Section Component
            FilterChipsSection(
              selectedFilter: _selectedFilter,
              onFilterSelected: (filter) {
                setState(() {
                  _selectedFilter = filter;
                });
              },
              filters: _filterChips,
            ),
            const SizedBox(height: 20),

            // Labs Section Component
            LabsSection(
              labs: _labsData,
              onLabTap: (lab) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailsScreen(lab: lab),
                  ),
                );
              },
            ),
            const SizedBox(height: 30),

            // News / Events Section Tabs Component
            NewsEventsTabs(
              selectedTab: _selectedNewsEventsTab,
              onTabSelected: (tab) {
                setState(() {
                  _selectedNewsEventsTab = tab;
                });
              },
            ),
            const SizedBox(height: 20),

            // News or Events List Component
            NewsEventsList(
              selectedTab: _selectedNewsEventsTab,
              newsItems: _newsData,
              eventItems: _eventsData,
            ),
          ],
        ),
      ),
    );
  }
}