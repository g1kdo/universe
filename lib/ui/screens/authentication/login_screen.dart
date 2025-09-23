// lib/ui/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:universe/ui/components/bars/custom_text_field.dart';
import 'package:universe/ui/components/custom_elevated_button.dart';
import 'package:universe/ui/screens/authentication/signup_screen.dart'; // For navigation to signup
import 'package:universe/ui/screens/home_screen.dart'; // For navigation to home
import 'package:universe/services/auth_service.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await _authService.signInWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text,
        );
        
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString())),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  void _loginWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.signInWithGoogle();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }


  void _forgotPassword() async {
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email first')),
      );
      return;
    }

    try {
      await _authService.sendPasswordResetEmail(_emailController.text.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset email sent')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: Container(
        // Background gradient from welcome/home screen
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
                  Text(
                    'Welcome Back!',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Sign in to continue!',
                    style: TextStyle(
                      fontSize: 18,
                      color: isDark ? Colors.white.withValues(alpha:0.8) : Colors.black54,
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
                      backgroundColor: isDark ? Colors.white.withValues(alpha:0.9) : Colors.white,
                      textColor: isDark ? Colors.black : Colors.black87,
                      // For image assets, iconColor might tint the image.
                      // If your Google logo is already colored, you might remove iconColor.
                      // iconColor: Colors.red[700],
                      iconSize: 35.0, // Increased icon size for the image
                      onPressed: _isLoading ? null : _loginWithGoogle,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // OR Divider
                  Text(
                    'OR',
                    style: TextStyle(
                      color: isDark ? Colors.white.withValues(alpha:0.7) : Colors.black54,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Email Field
                  CustomTextField(
                    controller: _emailController,
                    hintText: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
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
                      text: _isLoading ? 'Logging in...' : 'Log in',
                      onPressed: _isLoading ? null : _login,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Forgot Password
                  Align(
                    alignment: Alignment.center,
                    child: TextButton(
                      onPressed: _isLoading ? null : _forgotPassword,
                      child: Text(
                        'Forgot password?',
                        style: TextStyle(color: isDark ? Colors.white.withValues(alpha:0.7) : Colors.black54),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Don't have an account? Sign Up
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: TextStyle(color: isDark ? Colors.white.withValues(alpha:0.7) : Colors.black54),
                      ),
                      GestureDetector(
                        onTap: _isLoading ? null : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SignupScreen()),
                          );
                        },
                        child: Text(
                          'Sign Up',
                          style: TextStyle(
                            color: isDark ? Colors.blue[300] : Colors.blueAccent, // Use blue accent for link
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
