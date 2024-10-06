import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pizza_delivery_app/login.dart';

class AccountInfoPage extends StatefulWidget {
  const AccountInfoPage({super.key});

  @override
  _AccountInfoPageState createState() => _AccountInfoPageState();
}

class _AccountInfoPageState extends State<AccountInfoPage> {
  // Initialize FirebaseAuth and Firestore instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Declare a future to hold user data from Firestore
  late Future<DocumentSnapshot> _userData;

  @override
  void initState() {
    super.initState();
    // Get the current user's ID
    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      // Fetch user data from Firestore based on the current user's ID
      _userData = _firestore.collection('users').doc(userId).get();
    } else {
      // If no user is logged in, set a default future
      _userData = Future.value(null);
    }
  }

  // Method to handle user logout
  Future<void> _logout() async {
    try {
      await _auth.signOut(); // Sign out the user
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
            builder: (context) =>
                const LoginPage()), // Navigate to the login page
      );
    } catch (e) {
      // Show an error message if something goes wrong
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error logging out: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Account Information', // Title of the app bar
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.redAccent, // App bar background color
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _userData, // The future to build the widget with
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child:
                    CircularProgressIndicator()); // Show a loading spinner while fetching data
          }

          if (snapshot.hasError) {
            return Center(
                child: Text(
                    'Error: ${snapshot.error}')); // Show an error message if there's an issue
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
                child: Text(
                    'No data found.')); // Show a message if no data is found
          }

          // Extract user data from the snapshot
          final data = snapshot.data!.data() as Map<String, dynamic>;
          final name = data['name'] ?? 'No name';
          final email = data['userEmail'] ?? 'No email';
          final mobile = data['mobile'] ?? 'No mobile number';
          final address = data['address'] ?? 'No address';
          final profileImage =
              data['profileImage'] ?? 'dp_3.png'; // Default image if not found

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    backgroundImage: AssetImage(
                        'assets/profile_pic/$profileImage'), // Display the user's profile image
                    radius: 100, // Radius of the avatar
                  ),
                ),
                const SizedBox(height: 20),
                // Display user name
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3), // Shadow position
                      ),
                    ],
                  ),
                  child: Text(
                    'Name: $name',
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Display user email
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text('Email: $email',
                      style: const TextStyle(fontSize: 18)),
                ),
                const SizedBox(height: 10),
                // Display user mobile number
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text('Mobile Number: $mobile',
                      style: const TextStyle(fontSize: 18)),
                ),
                const SizedBox(height: 10),
                // Display user address
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text('Address: $address',
                      style: const TextStyle(fontSize: 18)),
                ),
                const SizedBox(height: 20),
                // Logout button
                Center(
                  child: ElevatedButton(
                    onPressed: _logout,
                    style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.red, // Background color of the button
                        padding: const EdgeInsets.symmetric(
                            horizontal: 100, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(10), // Rounded corners
                        ),
                        textStyle: const TextStyle(fontSize: 18),
                        foregroundColor: Colors.white),
                    child: const Text('Log Out'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
