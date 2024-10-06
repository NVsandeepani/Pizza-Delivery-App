import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// about the selected pizza and allows the user to confirm their order.
class OrderSummaryPage extends StatelessWidget {
  // Class properties to hold pizza details and user email
  final String pizzaName;
  final String description;
  final String imageUrl;
  final double price;
  final int quantity;
  final String selectedSize;
  final String userEmail; // Added to store the user's email address

  // Constructor to initialize the class properties with required values
  const OrderSummaryPage({
    super.key,
    required this.pizzaName,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.quantity,
    required this.selectedSize,
    required this.userEmail, // Initialize userEmail property
  });

  // Private method to save the order to Firebase Firestore
  Future<void> _saveOrder(BuildContext context) async {
    // Create an instance of FirebaseFirestore to interact with the database
    final FirebaseFirestore _db = FirebaseFirestore.instance;

    // Generate a random order ID using the helper method
    final String orderId = _generateRandomOrderId();

    // Calculate the total price of the order based on price and quantity
    final double totalPrice = price * quantity;

    try {
      // Save the order details in the 'orders' collection in Firestore
      await _db.collection('orders').doc(orderId).set({
        'pizzaName': pizzaName,
        'description': description,
        'imageUrl': imageUrl,
        'price': price,
        'quantity': quantity,
        'selectedSize': selectedSize,
        'totalPrice': totalPrice,
        'status': 'Awaiting Payment', // Set the initial order status
        'timestamp': FieldValue.serverTimestamp(), // Save the server timestamp
        'userEmail': userEmail, // Save the user's email address
      });

      // Show a success message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order placed successfully!'),
        ),
      );

      // Navigate back to the previous screen after order is placed
      Navigator.pop(context);
    } catch (e) {
      // If an error occurs while saving the order, print the error and show a failure message
      print('Error saving order: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error placing order. Please try again.'),
        ),
      );
    }
  }

  // Private helper method to generate a random 5-digit order ID
  String _generateRandomOrderId() {
    final Random random = Random(); // Create an instance of the Random class
    final int randomNumber = 10000 +
        random.nextInt(90000); // Generate a number between 10000 and 99999
    return randomNumber.toString(); // Return the generated number as a string
  }

  @override
  Widget build(BuildContext context) {
    // Calculate the total price of the order
    final double totalPrice = price * quantity;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Summary'), // Title of the AppBar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Add padding around the content
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display the pizza image in the center of the screen
            Center(
              child: Image.network(
                imageUrl,
                width: 200,
                height: 200,
                fit: BoxFit.cover, // Ensure the image covers the space
              ),
            ),
            const SizedBox(height: 16), // Add vertical spacing
            // Display the pizza name in bold text
            Text(
              pizzaName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8), // Add vertical spacing
            // Display the pizza description in grey text
            Text(
              description,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 16), // Add vertical spacing
            // Display the selected pizza size
            Text(
              'Size: $selectedSize',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
            // Display the quantity of pizzas ordered
            Text(
              'Quantity: $quantity',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16), // Add vertical spacing
            // Display the total price in bold orange text
            Text(
              'Total Price: \$${totalPrice.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 16), // Add vertical spacing
            // Button to confirm the order, centered on the screen
            Center(
              child: ElevatedButton(
                onPressed: () => _saveOrder(
                    context), // Call the _saveOrder method when pressed
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue, // Set button color
                  padding:
                      const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                  textStyle: const TextStyle(fontSize: 18), // Set text style
                  foregroundColor: Colors.white, // Set text color
                ),
                child: const Text('Confirm Order'), // Button text
              ),
            ),
          ],
        ),
      ),
    );
  }
}
