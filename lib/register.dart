// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// StatefulWidget to create a register page with form functionality
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key}); // Constructor with optional key parameter

  @override
  _RegisterPageState createState() =>
      _RegisterPageState(); // Create state for RegisterPage
}

// State class for RegisterPage
class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>(); // Key to uniquely identify the Form
  String _name = ''; // Store user name
  String _email = ''; // Store user email
  String _password = ''; // Store user password
  String _mobileNumber = ''; // Store user mobile number
  String _address = ''; // Store user address
  String _selectedImage = 'dp_3.png'; // Default profile image
  final List<String> _imageOptions = [
    // List of available profile images
    'dp_1.png',
    'dp_2.png',
    'dp_3.png',
    'dp_4.png',
    'dp_5.png',
    'dp_6.png'
  ];
  int _currentImageIndex = 0; // Index to track the currently selected image
  final String _userType = 'user'; // Default user type

  final FirebaseAuth _auth =
      FirebaseAuth.instance; // FirebaseAuth instance for user authentication
  final FirebaseFirestore _firestore = FirebaseFirestore
      .instance; // FirebaseFirestore instance for database operations

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Registration'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Padding around the form
        child: Form(
          key: _formKey, // Attach the form key
          child: ListView(
            children: [
              _buildProfileImageSelector(), // Widget to select profile image
              const SizedBox(height: 20), // Space between widgets
              TextFormField(
                decoration: const InputDecoration(
                    labelText: 'Name'), // Input field for user name
                keyboardType:
                    TextInputType.name, // Keyboard type for name input
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name'; // Validation message
                  }
                  return null;
                },
                onSaved: (value) => _name = value!, // Save name value
              ),
              TextFormField(
                decoration: const InputDecoration(
                    labelText: 'Email'), // Input field for email
                keyboardType:
                    TextInputType.emailAddress, // Keyboard type for email input
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email'; // Validation message
                  }
                  return null;
                },
                onSaved: (value) => _email = value!, // Save email value
              ),
              TextFormField(
                decoration: const InputDecoration(
                    labelText: 'Password'), // Input field for password
                obscureText: true, // Hide password text
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password'; // Validation message
                  }
                  return null;
                },
                onSaved: (value) => _password = value!, // Save password value
              ),
              TextFormField(
                decoration: const InputDecoration(
                    labelText:
                        'Mobile Number'), // Input field for mobile number
                keyboardType:
                    TextInputType.phone, // Keyboard type for phone input
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your mobile number'; // Validation message
                  }
                  return null;
                },
                onSaved: (value) =>
                    _mobileNumber = value!, // Save mobile number value
              ),
              TextFormField(
                decoration: const InputDecoration(
                    labelText: 'Address'), // Input field for address
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your address'; // Validation message
                  }
                  return null;
                },
                onSaved: (value) => _address = value!, // Save address value
              ),
              const SizedBox(height: 20), // Space between widgets
              Padding(
                padding: const EdgeInsets.only(
                    left: 25, right: 25), // Padding around the button
                child: ElevatedButton(
                  onPressed: _submitForm, // Submit form action
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 224, 57, 6), // Button color

                      padding: const EdgeInsets.symmetric(
                          horizontal: 100, vertical: 15), // Button padding
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(10), // Rounded corners
                      ),
                      textStyle:
                          const TextStyle(fontSize: 18), // Button text style
                      foregroundColor: Colors.white), // Button text color
                  child: const Text('Register'), // Button text
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget to build the profile image selector
  Widget _buildProfileImageSelector() {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _currentImageIndex = (_currentImageIndex + 1) %
                  _imageOptions.length; // Cycle through image options
              _selectedImage =
                  _imageOptions[_currentImageIndex]; // Update selected image
            });
          },
          child: CircleAvatar(
            backgroundImage: AssetImage(
                'assets/profile_pic/$_selectedImage'), // Display selected image
            radius: 100, // Image size
          ),
        ),
        const SizedBox(height: 10), // Space below image
        const Text(
          'Tap to change image', // Text below image
          style: TextStyle(fontSize: 16, color: Colors.grey), // Text style
        ),
      ],
    );
  }

  // Method to handle form submission
  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Check if form is valid
      _formKey.currentState!.save(); // Save form values
      try {
        // Create user with email and password using Firebase Authentication
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: _email,
          password: _password,
        );

        // Hash the password before storing it
        String hashedPassword = _hashPassword(_password);

        // Save additional user data to Firestore
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'name': _name,
          'userEmail': _email,
          'hashedPassword': hashedPassword,
          'mobile': _mobileNumber,
          'address': _address,
          'profileImage': _selectedImage,
          'userType': _userType, // Save user type
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User registered successfully!')),
        );
      } on FirebaseAuthException catch (e) {
        // Show error message if registration fails
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to register user: ${e.message}')),
        );
      }
    }
  }

  // Method to hash the password using SHA-256
  String _hashPassword(String password) {
    var bytes = utf8.encode(password); // Encode password to bytes
    var digest = sha256.convert(bytes); // Compute SHA-256 hash
    return digest.toString(); // Return hash as string
  }
}
