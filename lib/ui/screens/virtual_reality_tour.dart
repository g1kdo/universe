import 'package:flutter/material.dart';
import 'package:universe/ui/components/vr_tour_components/vr_navigation_overlay.dart';

class VirtualRealityTourScreen extends StatelessWidget {
  const VirtualRealityTourScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image simulating the VR environment (e.g., stairs)
          Positioned.fill(
            child: Image.asset(
              'assets/vr_background.jpg', // Add this image to your assets
              fit: BoxFit.cover,
            ),
          ),
          // Back button
          Positioned(
            top: 50,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          // VR Navigation Overlay
          Positioned(
            top: MediaQuery.of(context).size.height * 0.15, // Adjust vertical position
            left: 16,
            right: 16,
            child: const VrNavigationOverlay(
              instruction: 'Go right',
              details: 'Climb down the staircase until floor 1',
              distance: '1 km',
            ),
          ),
          // Simulated blue path overlay
          // This part is complex to replicate perfectly with simple widgets.
          // For a more realistic path, you might use custom painters or more advanced rendering.
          // Here's a simplified visual representation:
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.4, // Adjust height
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Image.asset(
                'assets/blue_path_overlay.png', // Add this image to your assets (a semi-transparent blue arrow/path)
                fit: BoxFit.contain,
                width: MediaQuery.of(context).size.width * 0.8, // Adjust width
              ),
            ),
          ),
        ],
      ),
    );
  }
}