import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:universe/models/lab_model.dart';
import 'package:universe/services/firestore_service.dart';

class MapsScreen extends ConsumerStatefulWidget {
  const MapsScreen({super.key});

  @override
  ConsumerState<MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends ConsumerState<MapsScreen> {
  GoogleMapController? _mapController;
  final FirestoreService _firestoreService = FirestoreService();
  
  // Map state
  LatLng _currentLocation = const LatLng(37.7749, -122.4194); // Default to San Francisco
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  bool _isLoading = true;
  String _selectedDestination = '';
  
  // Campus locations (you can customize these for your university)
  final Map<String, LatLng> _campusLocations = {
    'Main Campus': const LatLng(37.7749, -122.4194),
    'Chemistry Lab': const LatLng(37.7750, -122.4195),
    'Library': const LatLng(37.7748, -122.4193),
    'Cafeteria': const LatLng(37.7751, -122.4196),
    'Gym': const LatLng(37.7747, -122.4192),
    'Computer Lab': const LatLng(37.7752, -122.4197),
    'Administration': const LatLng(37.7746, -122.4191),
    'Parking Lot': const LatLng(37.7753, -122.4198),
  };

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    await _getCurrentLocation();
    await _loadCampusLocations();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Request location permission
      final permission = await Permission.location.request();
      if (permission != PermissionStatus.granted) {
        _showLocationPermissionDialog();
        return;
      }

      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showLocationServiceDialog();
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });

      // Add current location marker
      _addCurrentLocationMarker();
    } catch (e) {
      // Use default location if current location fails
      _addCurrentLocationMarker();
    }
  }

  Future<void> _loadCampusLocations() async {
    try {
      // Load labs from Firestore
      final labs = await _firestoreService.getLabs().first;
      
      Set<Marker> markers = {};
      
      // Add campus location markers
      _campusLocations.forEach((name, location) {
        markers.add(
          Marker(
            markerId: MarkerId(name),
            position: location,
            infoWindow: InfoWindow(
              title: name,
              snippet: 'Tap for directions',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              _getMarkerColor(name),
            ),
            onTap: () => _onMarkerTapped(name, location),
          ),
        );
      });

      // Add lab markers from Firestore
      for (var lab in labs) {
        // Generate a location for the lab (in real app, labs would have coordinates)
        final labLocation = _generateLabLocation(lab);
        markers.add(
          Marker(
            markerId: MarkerId(lab.id),
            position: labLocation,
            infoWindow: InfoWindow(
              title: lab.name,
              snippet: '${lab.type} - ${lab.floor}',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              _getLabMarkerColor(lab.category),
            ),
            onTap: () => _onLabMarkerTapped(lab, labLocation),
          ),
        );
      }

      setState(() {
        _markers = markers;
      });
    } catch (e) {
      // Handle error silently
    }
  }

  LatLng _generateLabLocation(Lab lab) {
    // Generate a location near the main campus for demo purposes
    // In a real app, labs would have actual coordinates
    final baseLocation = _campusLocations['Main Campus']!;
    final offset = (lab.hashCode % 100) / 10000.0; // Small random offset
    return LatLng(
      baseLocation.latitude + offset,
      baseLocation.longitude + offset,
    );
  }

  double _getMarkerColor(String locationName) {
    switch (locationName.toLowerCase()) {
      case 'main campus':
        return BitmapDescriptor.hueBlue;
      case 'chemistry lab':
        return BitmapDescriptor.hueRed;
      case 'library':
        return BitmapDescriptor.hueGreen;
      case 'cafeteria':
        return BitmapDescriptor.hueOrange;
      case 'gym':
        return BitmapDescriptor.hueViolet;
      default:
        return BitmapDescriptor.hueBlue;
    }
  }

  double _getLabMarkerColor(String category) {
    switch (category.toLowerCase()) {
      case 'lab':
        return BitmapDescriptor.hueRed;
      case 'canteen':
        return BitmapDescriptor.hueOrange;
      case 'office':
        return BitmapDescriptor.hueBlue;
      case 'gym':
        return BitmapDescriptor.hueViolet;
      case 'library':
        return BitmapDescriptor.hueGreen;
      case 'hostel':
        return BitmapDescriptor.hueYellow;
      default:
        return BitmapDescriptor.hueBlue;
    }
  }

  void _addCurrentLocationMarker() {
    setState(() {
      _markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: _currentLocation,
          infoWindow: const InfoWindow(
            title: 'Your Location',
            snippet: 'Current position',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
      );
    });
  }

  void _onMarkerTapped(String locationName, LatLng location) {
    setState(() {
      _selectedDestination = locationName;
    });
    _showDirectionsDialog(locationName, location);
  }

  void _onLabMarkerTapped(Lab lab, LatLng location) {
    setState(() {
      _selectedDestination = lab.name;
    });
    _showLabDirectionsDialog(lab, location);
  }

  void _showDirectionsDialog(String destination, LatLng destinationLocation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Navigate to $destination'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.directions_walk),
              title: const Text('Walking Directions'),
              onTap: () {
                Navigator.pop(context);
                _getDirections(destinationLocation, 'walking');
              },
            ),
            ListTile(
              leading: const Icon(Icons.directions_car),
              title: const Text('Driving Directions'),
              onTap: () {
                Navigator.pop(context);
                _getDirections(destinationLocation, 'driving');
              },
            ),
            ListTile(
              leading: const Icon(Icons.directions_transit),
              title: const Text('Public Transit'),
              onTap: () {
                Navigator.pop(context);
                _getDirections(destinationLocation, 'transit');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showLabDirectionsDialog(Lab lab, LatLng location) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(lab.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: ${lab.type}'),
            Text('Floor: ${lab.floor}'),
            Text('Building: ${lab.accommodation}'),
            if (lab.description.isNotEmpty)
              Text('Description: ${lab.description}'),
            const SizedBox(height: 16),
            const Text('Get Directions:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.directions_walk),
              title: const Text('Walking'),
              onTap: () {
                Navigator.pop(context);
                _getDirections(location, 'walking');
              },
            ),
            ListTile(
              leading: const Icon(Icons.directions_car),
              title: const Text('Driving'),
              onTap: () {
                Navigator.pop(context);
                _getDirections(location, 'driving');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _getDirections(LatLng destination, String mode) async {
    try {
      // Create a polyline from current location to destination
      // In a real app, you would use Google Directions API
      final polyline = Polyline(
        polylineId: const PolylineId('route'),
        points: [_currentLocation, destination],
        color: Colors.blue,
        width: 5,
      );

      setState(() {
        _polylines = {polyline};
      });

      // Move camera to show the route
      _mapController?.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(
              _currentLocation.latitude < destination.latitude 
                  ? _currentLocation.latitude 
                  : destination.latitude,
              _currentLocation.longitude < destination.longitude 
                  ? _currentLocation.longitude 
                  : destination.longitude,
            ),
            northeast: LatLng(
              _currentLocation.latitude > destination.latitude 
                  ? _currentLocation.latitude 
                  : destination.latitude,
              _currentLocation.longitude > destination.longitude 
                  ? _currentLocation.longitude 
                  : destination.longitude,
            ),
          ),
          100.0,
        ),
      );

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Directions to $_selectedDestination loaded'),
          action: SnackBarAction(
            label: 'Clear',
            onPressed: () {
              setState(() {
                _polylines.clear();
              });
            },
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting directions: $e')),
      );
    }
  }

  void _showLocationPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Permission Required'),
        content: const Text(
          'This app needs location permission to show your current location and provide directions.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  void _showLocationServiceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Services Disabled'),
        content: const Text(
          'Please enable location services to use the map features.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Geolocator.openLocationSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: Stack(
        children: [
          // Google Map
          if (_isLoading)
            Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary))
          else
            GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
              },
              initialCameraPosition: CameraPosition(
                target: _currentLocation,
                zoom: 16.0,
              ),
              markers: _markers,
              polylines: _polylines,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              mapType: isDark ? MapType.normal : MapType.normal, // You can use MapType.satellite for dark mode if preferred
            ),
          
          // Search Bar
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.shadow.withValues(alpha:0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.6)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                      decoration: InputDecoration(
                        hintText: 'Search campus locations...',
                        hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.6)),
                        border: InputBorder.none,
                      ),
                      onChanged: (value) {
                        // Implement search functionality
                        _searchLocations(value);
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.my_location),
                    onPressed: () {
                      _mapController?.animateCamera(
                        CameraUpdate.newLatLng(_currentLocation),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          
          // Location List
          Positioned(
            bottom: 120,
            left: 16,
            right: 16,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Campus Locations',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _campusLocations.length,
                      itemBuilder: (context, index) {
                        final location = _campusLocations.entries.elementAt(index);
                        return ListTile(
                          leading: Icon(
                            _getLocationIcon(location.key),
                            color: _getLocationColor(location.key),
                          ),
                          title: Text(
                            location.key,
                            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                          ),
                          onTap: () {
                            _mapController?.animateCamera(
                              CameraUpdate.newLatLng(location.value),
                            );
                            _onMarkerTapped(location.key, location.value);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Clear Route Button
          if (_polylines.isNotEmpty)
            Positioned(
              top: MediaQuery.of(context).padding.top + 70,
              right: 16,
              child: FloatingActionButton.small(
                onPressed: () {
                  setState(() {
                    _polylines.clear();
                  });
                },
                backgroundColor: Theme.of(context).colorScheme.surface,
                child: Icon(Icons.clear, color: Theme.of(context).colorScheme.error),
              ),
            ),
        ],
      ),
    );
  }

  IconData _getLocationIcon(String locationName) {
    switch (locationName.toLowerCase()) {
      case 'main campus':
        return Icons.school;
      case 'chemistry lab':
        return Icons.science;
      case 'library':
        return Icons.library_books;
      case 'cafeteria':
        return Icons.restaurant;
      case 'gym':
        return Icons.fitness_center;
      case 'computer lab':
        return Icons.computer;
      case 'administration':
        return Icons.admin_panel_settings;
      case 'parking lot':
        return Icons.local_parking;
      default:
        return Icons.location_on;
    }
  }

  Color _getLocationColor(String locationName) {
    switch (locationName.toLowerCase()) {
      case 'main campus':
        return Colors.blue;
      case 'chemistry lab':
        return Colors.red;
      case 'library':
        return Colors.green;
      case 'cafeteria':
        return Colors.orange;
      case 'gym':
        return Colors.purple;
      case 'computer lab':
        return Colors.teal;
      case 'administration':
        return Colors.indigo;
      case 'parking lot':
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }

  void _searchLocations(String query) {
    // Implement search functionality
    // This would filter the campus locations based on the query
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}