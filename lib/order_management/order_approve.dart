import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// This is the main widget for the Order Approve page.
class OrderApprovePage extends StatefulWidget {
  const OrderApprovePage({super.key});

  @override
  _OrderApprovePageState createState() => _OrderApprovePageState();
}

// This is the state class for OrderApprovePage, where the main logic resides.
class _OrderApprovePageState extends State<OrderApprovePage> {
  // Initializing Firebase authentication and Firestore instances.
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Variable to store the currently logged-in user.
  User? currentUser;

  // Initialize the state by getting the current user.
  @override
  void initState() {
    super.initState();
    currentUser = _auth.currentUser;
  }

  // Function to update the order status in Firestore.
  Future<void> _updateOrderStatus(String orderId, String status) async {
    try {
      print('Attempting to update order status for $orderId to $status');
      await _firestore.collection('orders').doc(orderId).update({
        'status': status,
      });
      print('Order status updated successfully');
    } catch (e) {
      print('Error updating order status: $e');
    }
  }

  // Function to get user details from Firestore based on the email.
  Future<Map<String, dynamic>> _getUserDetails(String userEmail) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('userEmail', isEqualTo: userEmail)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot userDoc = querySnapshot.docs.first;
        print('User document exists');
        print('User data: ${userDoc.data()}');
        return userDoc.data() as Map<String, dynamic>;
      } else {
        print('User document does not exist');
        return {};
      }
    } catch (e) {
      print('Error fetching user details: $e');
      return {};
    }
  }

  // Function to build the status radio buttons with colors and text.
  Widget _buildStatusRadio(
      String orderId, String currentStatus, String status) {
    // Function to get color based on the status.
    Color getStatusColor(String status) {
      switch (status) {
        case 'Awaiting Payment':
          return const Color.fromARGB(255, 28, 164, 233);
        case 'On The Way':
          return Colors.orange;
        case 'Delivered':
          return Colors.green;
        default:
          return Colors.grey[200]!;
      }
    }

    // Return a styled container with a ListTile containing a radio button.
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color:
            currentStatus == status ? getStatusColor(status) : Colors.grey[200],
        border: Border.all(
          color: currentStatus == status
              ? getStatusColor(status)
              : Colors.grey[400]!,
          width: 1.5,
        ),
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
        title: Text(
          status,
          style: TextStyle(
            fontSize: 15,
            color: currentStatus == status ? Colors.white : Colors.black87,
          ),
        ),
        // Radio button that changes order status when selected.
        leading: Radio<String>(
          value: status,
          groupValue: currentStatus,
          onChanged: (value) {
            if (value != null) {
              _updateOrderStatus(orderId, value);
              setState(() {
                // This updates the UI to reflect the color change.
                currentStatus = value;
              });
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // If no user is logged in, show a message.
    if (currentUser == null) {
      return const Scaffold(
        body: Center(
          child: Text("No user logged in"),
        ),
      );
    }

    // Check if the current user is an admin.
    bool isAdmin = currentUser!.email ==
        'admin@gmail.com'; // Replace with your admin check logic

    // If the user is not an admin, show an access denied message.
    if (!isAdmin) {
      return const Scaffold(
        body: Center(
          child: Text("Access denied. Admins only."),
        ),
      );
    }

    // Build the main UI of the page.
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Order Management',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepOrange,
      ),
      // StreamBuilder to listen to changes in the orders collection.
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('orders').snapshots(),
        builder: (context, snapshot) {
          // Show a message if there are no orders.
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No orders found"));
          }

          final orders = snapshot.data!.docs;

          // Build a list of orders.
          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              var order = orders[index].data() as Map<String, dynamic>;
              String orderId = orders[index].id;
              String currentStatus = order['status'] ?? 'Awaiting Payment';
              String userEmail = order['userEmail'] ?? 'Unknown';
              String pizzaName = order['pizzaName'] ?? 'Unknown';
              String selectedSize = order['selectedSize'] ?? 'Unknown';
              double price = order['price'] ?? 0.0;
              int quantity = order['quantity'] ?? 1;
              double totalPrice = price * quantity;

              // FutureBuilder to get user details asynchronously.
              return FutureBuilder<Map<String, dynamic>>(
                future: _getUserDetails(userEmail),
                builder: (context, userSnapshot) {
                  if (userSnapshot.hasError) {
                    print('Error fetching user details: ${userSnapshot.error}');
                    return const Center(
                        child: Text('Error fetching user details'));
                  }

                  var userDetails = userSnapshot.data ?? {};
                  String userName = userDetails['name'] ?? 'Unknown';
                  String userAddress = userDetails['address'] ?? 'Unknown';
                  String mobileNumber = userDetails['mobile'] ?? 'Unknown';

                  // Card displaying order and user details.
                  return Card(
                    elevation: 5,
                    color: Colors.deepOrange[50],
                    margin: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 16.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Order ID: $orderId",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "User Name: $userName",
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Pizza Name: $pizzaName",
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Selected Size: $selectedSize",
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Email: $userEmail",
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Address: $userAddress",
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Mobile Number: $mobileNumber",
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Price: \$${price.toStringAsFixed(2)}",
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Quantity: $quantity",
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Total Price: \$${price.toStringAsFixed(2)} * $quantity = \$${totalPrice.toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const SizedBox(height: 16),
                          const Text(
                            "Update Status:",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepOrange,
                            ),
                          ),
                          // Display the radio buttons for order status update.
                          _buildStatusRadio(
                              orderId, currentStatus, 'Awaiting Payment'),
                          _buildStatusRadio(
                              orderId, currentStatus, 'On The Way'),
                          _buildStatusRadio(
                              orderId, currentStatus, 'Delivered'),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
