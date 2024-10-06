import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// Define a stateful widget for the Order History Page
class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  _OrderHistoryPageState createState() => _OrderHistoryPageState();
}

// State class for the Order History Page
class _OrderHistoryPageState extends State<OrderHistoryPage> {
  final FirebaseAuth _auth = FirebaseAuth
      .instance; // Create an instance of FirebaseAuth to manage user authentication
  final FirebaseFirestore _firestore = FirebaseFirestore
      .instance; // Create an instance of FirebaseFirestore to access Firestore database

  User? currentUser; // Variable to hold the currently logged-in user

  @override
  void initState() {
    super.initState();
    currentUser =
        _auth.currentUser; // Initialize the currentUser with the logged-in user
  }

  // Method to update the order status in Firestore
  Future<void> _updateOrderStatus(String orderId, String status) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status':
            status, // Update the 'status' field of the order with the given status
      });
    } catch (e) {
      print(
          'Error updating order status: $e'); // Print error if updating the status fails
    }
  }

  // Method to build a radio button for each order status
  Widget _buildStatusRadio(
      String orderId, String currentStatus, String status) {
    // Function to determine the background color based on the status
    Color getStatusColor(String status) {
      switch (status) {
        case 'Awaiting Payment':
          return const Color.fromARGB(
              255, 28, 164, 233); // Blue color for 'Awaiting Payment' status
        case 'On The Way':
          return Colors.orange; // Orange color for 'On The Way' status
        case 'Delivered':
          return Colors.green; // Green color for 'Delivered' status
        default:
          return Colors.grey[200]!; // Default grey color for other statuses
      }
    }

    // Return a container with a radio button styled based on the status
    return SizedBox(
      child: Container(
        margin: const EdgeInsets.symmetric(
          vertical: 4.0,
        ), // Vertical margin around the container

        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0), // Rounded corners
          color: currentStatus == status
              ? getStatusColor(status)
              : Colors.grey[200], // Set color based on current status
          border: Border.all(
            color: currentStatus == status
                ? getStatusColor(status)
                : Colors.grey[
                    400]!, // Border color also depends on the current status
            width: 1.5,
          ),
        ),
        child: ListTile(
          dense: true,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 16.0), // Horizontal padding inside the ListTile

          title: Text(
            status, // Display the status text
            style: TextStyle(
              fontSize: 15,
              color: currentStatus == status
                  ? Colors.white
                  : Colors.black87, // Text color depends on the current status
            ),
          ),
          leading: Radio<String>(
            value: status, // Value for the radio button
            groupValue: currentStatus, // Current selected value for the group
            onChanged:
                null, // Disable interaction as the status cannot be changed by the user
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // If no user is logged in, display a message
    if (currentUser == null) {
      return const Scaffold(
        body: Center(
          child: Text("No user logged in"),
        ),
      );
    }

    // Return the main scaffold for the Order History Page
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Orders', // Title for the AppBar
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor:
            Colors.red, // Set AppBar background color to deep orange
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('orders')
            .where('userEmail', isEqualTo: currentUser!.email)
            .snapshots(), // Listen to real-time updates of orders for the logged-in user
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child:
                    CircularProgressIndicator()); // Show a loading indicator while waiting for data
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
                child: Text(
                    "No orders found for ${currentUser!.email}")); // Show a message if no orders are found
          }

          final orders =
              snapshot.data!.docs; // Get the list of orders from the snapshot

          // Build a ListView to display each order
          return ListView.builder(
            itemCount: orders.length, // Number of items in the list
            itemBuilder: (context, index) {
              var order = orders[index].data()
                  as Map<String, dynamic>; // Get the order data
              String orderId = orders[index].id; // Get the order ID
              String currentStatus = order['status'] ??
                  'Awaiting Payment'; // Get the current status, default to 'Awaiting Payment'
              String pizzaName = order['pizzaName'] ??
                  'Unknown Pizza'; // Get the pizza name, default to 'Unknown Pizza'
              double price =
                  order['price'] ?? 0.0; // Get the price, default to 0.0
              int quantity =
                  order['quantity'] ?? 1; // Get the quantity, default to 1
              String selectedSize = order['selectedSize'] ??
                  'Unknown Size'; // Get the selected size, default to 'Unknown Size'
              double totalPrice = price * quantity; // Calculate the total price

              // Return a Card widget for each order
              return Card(
                elevation: 5, // Set elevation for shadow effect
                color: Colors.deepOrange[50], // Background color for the card
                margin: const EdgeInsets.symmetric(
                    vertical: 8.0, horizontal: 16.0), // Margin around the card
                child: Padding(
                  padding:
                      const EdgeInsets.all(16.0), // Padding inside the card
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment
                        .start, // Align content to the start of the column
                    children: [
                      Text(
                        "Order ID: $orderId", // Display the order ID
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8), // Add vertical spacing
                      Text(
                        "Pizza Name: $pizzaName", // Display the pizza name
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Selected Size: $selectedSize", // Display the selected pizza size
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Price: \$$price", // Display the price
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Quantity: $quantity", // Display the quantity
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Total Price: \$$price * $quantity = \$$totalPrice", // Display the calculated total price
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const SizedBox(height: 16),
                      const Text(
                        "Current Status :", // Display the label for current status
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      _buildStatusRadio(orderId, currentStatus,
                          'Awaiting Payment'), // Build the radio button for 'Awaiting Payment' status
                      _buildStatusRadio(orderId, currentStatus,
                          'On The Way'), // Build the radio button for 'On The Way' status
                      _buildStatusRadio(orderId, currentStatus,
                          'Delivered'), // Build the radio button for 'Delivered' status
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
