// lib/ui/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:universe/ui/components/bars/custom_text_field.dart';
import 'package:universe/ui/components/custom_elevated_button.dart';
import 'package:universe/ui/screens/authentication/signup_screen.dart'; // For navigation to signup
import 'package:universe/ui/screens/home_screen.dart'; // For navigation to home

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implement actual login logic (e.g., API call)
      print('Logging in with:');
      print('Username: ${_usernameController.text}');
      print('Password: ${_passwordController.text}');

      // Simulate successful login and navigate to home screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Background gradient from welcome/home screen
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF89CFF0), // Light Blue
              Color(0xFFC9A0DC), // Light Purple
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start, // Align content to the top
                crossAxisAlignment: CrossAxisAlignment.center, // Center horizontally
                children: [
                  const SizedBox(height: 50), // Space from the very top

                  // Welcome Back Text
                  const Text(
                    'Welcome Back!',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Sign in to continue!',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Social Login Buttons
                  SizedBox( // Wrap in SizedBox to control width
                    width: double.infinity, // Make it take full available width
                    child: CustomElevatedButton(
                      text: 'Log in with Google',
                      // Use imageIcon instead of icon for Google logo
                      imageIcon: const AssetImage('assets/images/google.png'),
                      backgroundColor: Colors.white,
                      textColor: Colors.black87,
                      // For image assets, iconColor might tint the image.
                      // If your Google logo is already colored, you might remove iconColor.
                      // iconColor: Colors.red[700],
                      iconSize: 35.0, // Increased icon size for the image
                      onPressed: () {
                        // TODO: Implement Google login
                        print('Login with Google');
                      },
                    ),
                  ),
                  const SizedBox(height: 15),
                  SizedBox( // Wrap in SizedBox to control width
                    width: double.infinity, // Make it take full available width
                    child: CustomElevatedButton(
                      text: 'Log in with Facebook',
                      icon: Icons.facebook, // Keep using IconData for Facebook if you prefer
                      backgroundColor: Colors.white,
                      textColor: Colors.black87,
                      iconColor: Colors.blue[800], // More visible blue
                      iconSize: 35.0, // Increased icon size
                      onPressed: () {
                        // TODO: Implement Facebook login
                        print('Login with Facebook');
                      },
                    ),
                  ),
                  const SizedBox(height: 30),

                  // OR Divider
                  const Text(
                    'OR',
                    style: TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Username Field
                  CustomTextField(
                    controller: _usernameController,
                    hintText: 'Username',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your username';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Password Field
                  CustomTextField(
                    controller: _passwordController,
                    hintText: 'Password',
                    obscureText: true, // This enables the visibility toggle
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password is required';
                      }
                      // You can add more complex password validation here
                      if (value.length < 8) {
                        return 'Password must contain at least 8 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),

                  // Login Button
                  SizedBox(
                    width: double.infinity, // Make it take full available width
                    child: CustomElevatedButton(
                      text: 'Log in',
                      onPressed: _login,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Forgot Password
                  Align(
                    alignment: Alignment.center,
                    child: TextButton(
                      onPressed: () {
                        // TODO: Implement forgot password logic
                        print('Forgot Password?');
                      },
                      child: const Text(
                        'Forgot password?',
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Don't have an account? Sign Up
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account? ",
                        style: TextStyle(color: Colors.black54),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SignupScreen()),
                          );
                        },
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                            color: Colors.blueAccent, // Use blue accent for link
                            fontWeight: FontWeight.bold,
                          ),
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
    );
  }
}
