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
import 'package:universe/ui/screens/maps_screen.dart';
import 'package:universe/ui/screens/details_screen.dart';
import 'package:universe/services/firestore_service.dart';
import 'package:universe/models/event_model.dart';
import 'package:universe/models/lab_model.dart';
import 'package:universe/models/news_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  String _searchQuery = ''; // Global search query
  bool _showFilters = true; // State to control filter chips visibility

  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _searchController = TextEditingController();
  
  // Data streams - initialize immediately to avoid late initialization errors
  late final Stream<List<Lab>> _labsStream = _firestoreService.getLabs();
  late final Stream<List<Event>> _eventsStream = _firestoreService.getEvents();
  late final Stream<List<News>> _newsStream = _firestoreService.getNews();
  
  // User profile data - using FutureBuilder instead of StreamBuilder
  Map<String, dynamic>? _userProfile;
  bool _isLoadingProfile = true;

  // Placeholder data for filter chips
  final List<String> _filterChips = ['Labs', 'Canteen', 'Office', 'Gym', 'Library', 'Hostel'];

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  // Helper method to filter labs based on selected filter and search query
  List<Lab> _filterLabs(List<Lab> labs) {
    List<Lab> filteredLabs = labs;

    // Only apply category filtering if filters are visible
    if (_showFilters) {
      // Filter by category
      if (_selectedFilter == 'Labs') {
        // When "Labs" is selected, show only labs with "lab" category
        filteredLabs = labs.where((lab) => 
          lab.category.toLowerCase() == 'lab'
        ).toList();
      } else {
        // For other filters, match the selected filter with the category
        filteredLabs = labs.where((lab) => 
          lab.category.toLowerCase() == _selectedFilter.toLowerCase()
        ).toList();
      }
    }
    // If filters are hidden, show all labs (no category filtering)

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filteredLabs = filteredLabs.where((lab) =>
        lab.name.toLowerCase().contains(_searchQuery) ||
        lab.type.toLowerCase().contains(_searchQuery) ||
        lab.description.toLowerCase().contains(_searchQuery) ||
        lab.accommodation.toLowerCase().contains(_searchQuery) ||
        lab.floor.toLowerCase().contains(_searchQuery) ||
        lab.category.toLowerCase().contains(_searchQuery)
      ).toList();
    }

    return filteredLabs;
  }

  // Helper method to filter events based on search query
  List<Event> _filterEvents(List<Event> events) {
    if (_searchQuery.isEmpty) return events;
    
    return events.where((event) =>
      event.title.toLowerCase().contains(_searchQuery) ||
      event.description.toLowerCase().contains(_searchQuery) ||
      event.location.toLowerCase().contains(_searchQuery) ||
      event.category.toLowerCase().contains(_searchQuery) ||
      event.organizer.toLowerCase().contains(_searchQuery)
    ).toList();
  }

  // Helper method to filter news based on search query
  List<News> _filterNews(List<News> news) {
    if (_searchQuery.isEmpty) return news;
    
    return news.where((newsItem) =>
      newsItem.title.toLowerCase().contains(_searchQuery) ||
      newsItem.content.toLowerCase().contains(_searchQuery) ||
      newsItem.author.toLowerCase().contains(_searchQuery) ||
      newsItem.category.toLowerCase().contains(_searchQuery)
    ).toList();
  }

  // Helper method to get dynamic section title
  String _getSectionTitle() {
    if (_searchQuery.isNotEmpty) {
      return 'SEARCH RESULTS';
    }
    if (!_showFilters) {
      return 'ALL FACILITIES';
    }
    return _selectedFilter.toUpperCase();
  }

  Future<void> _loadUserProfile() async {
    try {
      final profile = await _firestoreService.getUserProfile();
      if (mounted) {
        setState(() {
          _userProfile = profile;
          _isLoadingProfile = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingProfile = false;
        });
      }
    }
  }

  Widget _buildHomeHeader() {
    final isAuthenticated = _auth.currentUser != null;
    
    String userName;
    String userLocation;
    String? profileImageUrl;
    
    if (isAuthenticated) {
      userName = _userProfile?['name'] ?? _auth.currentUser?.displayName ?? 'User';
      userLocation = _userProfile?['location'] ?? 'Campus';
      profileImageUrl = _userProfile?['profileImageUrl'] ?? _auth.currentUser?.photoURL;
    } else {
      userName = 'Visitor';
      userLocation = 'Campus';
      profileImageUrl = null;
    }
    
    return HomeHeader(
      userName: userName,
      userLocation: userLocation,
      profileImageUrl: profileImageUrl,
      isAuthenticated: isAuthenticated,
    );
  }


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
          // Bottom nav item tapped: $index
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
            // Home Header Component with dynamic user data
            _isLoadingProfile
                ? Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary))
                : _buildHomeHeader(),
            const SizedBox(height: 20),

            // Search Bar Component
            SearchBarWidget(
              controller: _searchController,
              showFilters: _showFilters,
              onFilterPressed: () {
                setState(() {
                  _showFilters = !_showFilters;
                });
              },
            ),
            const SizedBox(height: 20),

            // Filter Chips Section Component (only show when filters are visible)
            if (_showFilters) ...[
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
            ],

            // Labs Section Component with Firestore data
            StreamBuilder<List<Lab>>(
              stream: _labsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary));
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final labs = snapshot.data ?? [];
                final filteredLabs = _filterLabs(labs);
                
                return LabsSection(
                  title: _getSectionTitle(),
                  labs: filteredLabs,
                  onLabTap: (lab) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailsScreen(lab: lab),
                      ),
                    );
                  },
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

            // News or Events List Component with Firestore data
            StreamBuilder<List<News>>(
              stream: _newsStream,
              builder: (context, newsSnapshot) {
                return StreamBuilder<List<Event>>(
                  stream: _eventsStream,
                  builder: (context, eventsSnapshot) {
                    if (newsSnapshot.connectionState == ConnectionState.waiting || 
                        eventsSnapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary));
                    }
                    
                    final news = newsSnapshot.data ?? [];
                    final events = eventsSnapshot.data ?? [];
                    final filteredNews = _filterNews(news);
                    final filteredEvents = _filterEvents(events);
                    
                    return NewsEventsList(
                      selectedTab: _selectedNewsEventsTab,
                      newsItems: filteredNews,
                      eventItems: filteredEvents,
                      onEventRegistrationChanged: () {
                        // Refresh the events stream when registration changes
                        setState(() {
                          // Trigger rebuild to refresh data
                        });
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}