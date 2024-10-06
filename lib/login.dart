// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pizza_delivery_app/admin/admin_home.dart';
import 'package:pizza_delivery_app/register.dart';
import 'package:pizza_delivery_app/user/user_home.dart';

// Define the LoginPage widget
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

// State class for LoginPage
class _LoginPageState extends State<LoginPage> {
  // Controllers for email and password fields
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Key to validate the form
  final _formKey = GlobalKey<FormState>();

  // State variables for password visibility and loading indicator
  bool _obscureText = true;
  bool _isLoading = false;

  // Toggle password visibility
  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  // Function to handle login
  Future<void> _login() async {
    // Validate the form
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Sign in the user with email and password
        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        // Fetch user type from Firestore
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        if (userDoc.exists) {
          String userType =
              userDoc['userType'] ?? 'user'; // Default to 'user' if not set

          // Navigate based on user type
          if (userType == 'admin') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AdminHomePage()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const UserHomePage()),
            );
          }

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login successful')),
          );
        } else {
          // User data not found in Firestore
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User data not found')),
          );
        }
      } on FirebaseAuthException catch (e) {
        setState(() {
          _isLoading = false;
        });

        // Log the error code and message for debugging
        print('FirebaseAuthException caught: ${e.code} - ${e.message}');

        // Determine error message based on the error code
        String message;
        switch (e.code) {
          case 'user-not-found':
            message = 'No user found for that email.';
            break;
          case 'wrong-password':
            message = 'Wrong password provided.';
            break;
          case 'invalid-email':
            message = 'The email address is badly formatted.';
            break;
          case 'user-disabled':
            message = 'The user account has been disabled by an administrator.';
            break;
          case 'network-request-failed':
            message =
                'Network request failed. Please check your internet connection.';
            break;
          default:
            message = 'An error occurred: ${e.message}';
            break;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      } catch (e) {
        setState(() {
          _isLoading = false;
        });

        // Log unexpected exceptions
        print('Unexpected exception caught: $e');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An unexpected error occurred.')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          // Optionally add a title or other widgets here
          ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Display the app logo
              Image.asset(
                'assets/pizza_logo.png',
                height: 300,
                width: 300,
              ),
              const SizedBox(height: 16),
              const Text(
                'Welcome Back!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              // Form for email and password input
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        isDense: true, // Reduce height
                        labelText: 'Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(8),
                          ),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        String pattern =
                            r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
                        RegExp regex = RegExp(pattern);
                        if (!regex.hasMatch(value)) {
                          return 'Enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscureText,
                      decoration: InputDecoration(
                        isDense: true, // Reduce height
                        labelText: 'Password',
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(8),
                          ),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureText
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: _togglePasswordVisibility,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),
                    // Show loading indicator or login button
                    if (_isLoading)
                      const CircularProgressIndicator()
                    else
                      ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepOrange[800],
                            padding: const EdgeInsets.symmetric(
                                horizontal: 100, vertical: 15),
                            textStyle: const TextStyle(fontSize: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(10), // Rounded corners
                            ),
                            foregroundColor: Colors.white),
                        child: const Text('Login'),
                      ),
                    const SizedBox(height: 16),
                    // Forgot password button
                    TextButton(
                      onPressed: () async {
                        String email = _emailController.text.trim();

                        if (email.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Please enter your email to reset password')),
                          );
                          return;
                        }

                        try {
                          await FirebaseAuth.instance
                              .sendPasswordResetEmail(email: email);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Password reset email sent!')),
                          );
                        } on FirebaseAuthException catch (e) {
                          String message;
                          switch (e.code) {
                            case 'invalid-email':
                              message = 'The email address is badly formatted.';
                              break;
                            case 'user-not-found':
                              message = 'No user found for that email.';
                              break;
                            default:
                              message = 'An error occurred: ${e.message}';
                              break;
                          }

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(message)),
                          );
                        } catch (e) {
                          // Log unexpected exceptions
                          print('Unexpected exception caught: $e');

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('An unexpected error occurred.')),
                          );
                        }
                      },
                      child: const Text('Forgot Password?'),
                    ),
                    const SizedBox(height: 1),
                    // Navigate to registration page
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const RegisterPage()),
                        );
                      },
                      child: const Text('Don\'t have an account? Register'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
