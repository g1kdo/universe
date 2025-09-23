import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:universe/ui/screens/authentication/login_screen.dart';
import 'package:universe/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'home_screen.dart';

class UniVerseUClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    // Start from top-left
    path.moveTo(0, size.height * 0.2);
    // Line to bottom-left
    path.lineTo(0, size.height * 0.8);
    // Arc to bottom-right
    path.quadraticBezierTo(size.width / 2, size.height, size.width, size.height * 0.8);
    // Line to top-right
    path.lineTo(size.width, size.height * 0.2);
    // Line to create the inner cut-out for the 'U'
    path.lineTo(size.width * 0.8, size.height * 0.2);
    path.lineTo(size.width * 0.8, size.height * 0.75);
    path.quadraticBezierTo(size.width / 2, size.height * 0.65, size.width * 0.2, size.height * 0.75);
    path.lineTo(size.width * 0.2, size.height * 0.2);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// Custom Clipper for the 'V' shape of the UniVerse logo (now upside down)
class UniVerseVClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    // Start at top-left
    path.moveTo(0, 0);
    // Line to top-right
    path.lineTo(size.width, 0);
    // Line to bottom-center (making it an upside-down V)
    path.lineTo(size.width / 2, size.height);
    // Close the path to form a triangle
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}


class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> with TickerProviderStateMixin {
  // Controller for the UV logo falling animation
  late AnimationController _logoAnimationController;
  // Animation for the 'U' shape's position (slide from top-left)
  late Animation<Offset> _uSlideAnimation;
  // Animation for the 'V' shape's position (slide from top-right)
  late Animation<Offset> _vSlideAnimation;

  // Controller for the text and buttons fade-in animation
  late AnimationController _textButtonsAnimationController;
  // Animation for the opacity of the text and buttons
  late Animation<double> _textButtonsOpacityAnimation;

  // Add a boolean flag to indicate if animations are initialized
  bool _animationsInitialized = false;
  
  // Firebase authentication
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();

    // Initialize the logo animation controller
    _logoAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5), // Duration for the UV shapes to fall
    );

    // Define the animation for the 'U' shape
    // It starts off-screen at the top-left and lands slightly to the left
    _uSlideAnimation = Tween<Offset>(
      begin: const Offset(-0.8, -2.0), // Start from further top-left
      end: const Offset(-0.2, 0.0),    // End slightly to the left for balance
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: Curves.easeOutBack, // Provides a slight bounce effect at the end
    ));

    // Define the animation for the 'V' shape
    // It starts off-screen at the top-right and lands slightly to the right and down,
    // creating the "falling on" effect.
    _vSlideAnimation = Tween<Offset>(
      begin: const Offset(0.8, -2.0), // Start from further top-right
      end: const Offset(0.2, 0.1),    // End slightly to the right and down to overlap 'U'
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: Curves.easeOutBack, // Same curve for consistent landing
    ));

    // Initialize the text and buttons animation controller
    _textButtonsAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000), // Duration for the fade-in
    );

    // Define the animation for the opacity of the text and buttons
    _textButtonsOpacityAnimation = Tween<double>(
      begin: 0.0, // Start fully transparent
      end: 1.0,   // End fully opaque
    ).animate(CurvedAnimation(
      parent: _textButtonsAnimationController,
      curve: Curves.easeIn, // Smooth fade-in curve
    ));

    // Add a listener to the logo animation controller
    // When the logo animation completes, start the text/buttons fade-in animation
    _logoAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _textButtonsAnimationController.forward(); // Start the fade-in
      }
    });

    // Start the logo animation
    _logoAnimationController.forward();

    // Check authentication state
    _checkAuthState();

    // Ensure _animationsInitialized is set to true after the first frame
    // This guarantees that all 'late' variables are initialized before
    // the build method attempts to use them in subsequent renders.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) { // Check if the widget is still in the tree
        setState(() {
          _animationsInitialized = true;
        });
      }
    });
  }

  void _checkAuthState() {
    _authService.authStateChanges.listen((User? user) {
      if (user != null && mounted) {
        // User is already logged in, navigate to home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    // Dispose of the animation controllers to prevent memory leaks
    _logoAnimationController.dispose();
    _textButtonsAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Show a blank container or loading indicator until animations are initialized.
    // This prevents accessing uninitialized 'late' variables during the very first build.
    if (!_animationsInitialized) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark ? [
              const Color(0xFF1a1a2e), // Dark Blue
              const Color(0xFF16213e), // Darker Blue
              const Color(0xFF0f3460), // Darkest Blue
            ] : [
              const Color(0xFF89CFF0), // Light Blue
              const Color(0xFFC9A0DC), // Light Purple
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark ? [
              const Color(0xFF1a1a2e), // Dark Blue
              const Color(0xFF16213e), // Darker Blue
              const Color(0xFF0f3460), // Darkest Blue
            ] : [
              const Color(0xFF89CFF0), // Light Blue
              const Color(0xFFC9A0DC), // Light Purple
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // --- Animated UniVerse Logo Section ---
              // SizedBox provides a fixed area for the logo to animate within.
              SizedBox(
                width: 200, // Width for the logo area
                height: 150, // Height for the logo area
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // The 'U' shape, animated to slide into place
                    SlideTransition(
                      position: _uSlideAnimation,
                      child: ClipPath(
                        clipper: UniVerseUClipper(),
                        child: Container(
                          width: 100, // Size of the 'U' shape
                          height: 100,
                          color: isDark ? Colors.white : Colors.white, // Color of the 'U' shape
                        ),
                      ),
                    ),
                    // The 'V' shape, animated to slide into place
                    SlideTransition(
                      position: _vSlideAnimation,
                      child: ClipPath(
                        clipper: UniVerseVClipper(),
                        child: Container(
                          width: 90, // Slightly larger V for better visual balance when upside down
                          height: 90,
                          color: isDark ? Colors.black : Colors.black, // Color of the 'V' shape
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50), // Spacing between logo and welcome text

              // --- Animated Welcome Text ---
              // FadeTransition makes the text appear smoothly after the logo animation
              FadeTransition(
                opacity: _textButtonsOpacityAnimation,
                child: Text(
                  'Welcome to UniVerse',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 30), // Spacing between welcome text and buttons

              // --- Animated Explore Button ---
              FadeTransition(
                opacity: _textButtonsOpacityAnimation,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Implement navigation to the main app screen
                    //print('Explore button pressed!');
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const HomeScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? Colors.white.withValues(alpha:0.9) : Colors.white, // White background for the button
                    foregroundColor: isDark ? Colors.black : Colors.black, // Black text/icon color
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30), // More rounded button
                    ),
                    elevation: 5, // Add a subtle shadow
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min, // Make row fit its children
                    children: [
                      Text(
                        'Explore',
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(width: 10),
                      Icon(Icons.arrow_forward), // Right arrow icon
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 15), // Spacing between buttons

              // --- Animated Register/Login Button ---
              FadeTransition(
                opacity: _textButtonsOpacityAnimation,
                child: OutlinedButton(
                  onPressed: () {
                    // TODO: Implement navigation to the registration/login screen
                    //print('Register or Login button pressed!');
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isDark ? Colors.white : Colors.black, // Black text/icon color
                    side: BorderSide(color: isDark ? Colors.white.withValues(alpha:0.8) : Colors.white, width: 2), // White border
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0, // No shadow for outlined button
                  ),
                  child: const Text(
                    'Register or Login',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
