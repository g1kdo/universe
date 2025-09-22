import 'package:flutter/material.dart';
import 'package:universe/models/lab_model.dart';
import 'package:universe/services/firestore_service.dart';

class VirtualRealityTourScreen extends StatefulWidget {
  const VirtualRealityTourScreen({super.key});

  @override
  State<VirtualRealityTourScreen> createState() => _VirtualRealityTourScreenState();
}

class _VirtualRealityTourScreenState extends State<VirtualRealityTourScreen>
    with TickerProviderStateMixin {
  final FirestoreService _firestoreService = FirestoreService();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  List<Lab> _tourLocations = [];
  int _currentTourIndex = 0;
  bool _isLoading = true;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadTourLocations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
  }

  Future<void> _loadTourLocations() async {
    try {
      final labs = await _firestoreService.getLabs().first;
      setState(() {
        _tourLocations = labs.take(6).toList(); // Take first 6 locations for tour
        _isLoading = false;
      });
      _animationController.forward();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _startTour() {
    setState(() {
      _isPlaying = true;
      _currentTourIndex = 0;
    });
    _playNextLocation();
  }

  void _playNextLocation() {
    if (_currentTourIndex < _tourLocations.length) {
      _animationController.reset();
      _animationController.forward();
      
      // Auto-advance to next location after 5 seconds
      Future.delayed(const Duration(seconds: 5), () {
        if (_isPlaying && _currentTourIndex < _tourLocations.length - 1) {
          setState(() {
            _currentTourIndex++;
          });
          _playNextLocation();
        } else {
          _endTour();
        }
      });
    }
  }

  void _endTour() {
    setState(() {
      _isPlaying = false;
      _currentTourIndex = 0;
    });
  }

  void _pauseTour() {
    setState(() {
      _isPlaying = false;
    });
  }

  // void _resumeTour() {
  //   setState(() {
  //     _isPlaying = true;
  //   });
  //   _playNextLocation();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1a1a2e),
              Color(0xFF16213e),
              Color(0xFF0f3460),
            ],
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : _buildTourContent(),
        ),
      ),
    );
  }

  Widget _buildTourContent() {
    if (_tourLocations.isEmpty) {
      return const Center(
        child: Text(
          'No tour locations available',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      );
    }

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Virtual Campus Tour',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_isPlaying)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green),
                  ),
                  child: const Text(
                    'LIVE',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),

        // VR View Area
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha:0.3)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  // 360° View Background
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.blue.withValues(alpha:0.3),
                          Colors.purple.withValues(alpha:0.3),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.view_in_ar,
                            size: 80,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            '360° Virtual View',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Location Info Overlay
                  if (_tourLocations.isNotEmpty)
                    Positioned(
                      bottom: 20,
                      left: 20,
                      right: 20,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha:0.7),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      _getLocationIcon(_tourLocations[_currentTourIndex].category),
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        _tourLocations[_currentTourIndex].name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  _tourLocations[_currentTourIndex].description,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontSize: 14,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      color: Colors.white.withValues(alpha: 0.7),
                                      size: 16,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      '${_tourLocations[_currentTourIndex].floor} - ${_tourLocations[_currentTourIndex].accommodation}',
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.7),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Tour Progress
                  if (_isPlaying)
                    Positioned(
                      top: 20,
                      left: 20,
                      right: 20,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Location ${_currentTourIndex + 1} of ${_tourLocations.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                '${((_currentTourIndex + 1) / _tourLocations.length * 100).round()}%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: (_currentTourIndex + 1) / _tourLocations.length,
                            backgroundColor: Colors.white.withValues(alpha:0.3),
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),

        // Control Panel
        Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Tour Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (!_isPlaying)
                    ElevatedButton.icon(
                      onPressed: _startTour,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Start Tour'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    )
                  else ...[
                    ElevatedButton.icon(
                      onPressed: _pauseTour,
                      icon: const Icon(Icons.pause),
                      label: const Text('Pause'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _endTour,
                      icon: const Icon(Icons.stop),
                      label: const Text('End Tour'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 20),

              // Tour Locations List
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _tourLocations.length,
                  itemBuilder: (context, index) {
                    final location = _tourLocations[index];
                    final isActive = index == _currentTourIndex;
                    final isCompleted = index < _currentTourIndex;

                    return Container(
                      width: 100,
                      margin: const EdgeInsets.only(right: 10),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _currentTourIndex = index;
                          });
                          if (_isPlaying) {
                            _playNextLocation();
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isActive
                                ? Colors.blue.withValues(alpha:0.3)
                                : isCompleted
                                    ? Colors.green.withValues(alpha:0.3)
                                    : Colors.white.withValues(alpha:0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isActive
                                  ? Colors.blue
                                  : isCompleted
                                      ? Colors.green
                                      : Colors.white.withValues(alpha:0.3),
                              width: 2,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _getLocationIcon(location.category),
                                color: isActive
                                    ? Colors.blue
                                    : isCompleted
                                        ? Colors.green
                                        : Colors.white.withValues(alpha:0.7),
                                size: 24,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                location.name,
                                style: TextStyle(
                                  color: isActive
                                      ? Colors.blue
                                      : isCompleted
                                          ? Colors.green
                                          : Colors.white.withValues(alpha:0.7),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _getLocationIcon(String category) {
    switch (category.toLowerCase()) {
      case 'lab':
        return Icons.science;
      case 'canteen':
        return Icons.restaurant;
      case 'office':
        return Icons.business;
      case 'gym':
        return Icons.fitness_center;
      case 'library':
        return Icons.library_books;
      case 'hostel':
        return Icons.home;
      default:
        return Icons.location_on;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
