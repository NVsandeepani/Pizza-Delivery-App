import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pizza_delivery_app/order_management/order_summary.dart';

// StatefulWidget for displaying pizza details
class PizzaDetailsPage extends StatefulWidget {
  final String pizzaName;
  final String description;
  final String imageUrl;
  final double price;

  // Constructor with required parameters
  const PizzaDetailsPage({
    super.key,
    required this.pizzaName,
    required this.description,
    required this.imageUrl,
    required this.price,
  });

  @override
  _PizzaDetailsPageState createState() => _PizzaDetailsPageState();
}

class _PizzaDetailsPageState extends State<PizzaDetailsPage>
    with SingleTickerProviderStateMixin {
  int _quantity = 1; // Default quantity
  String _selectedSize = 'M'; // Default pizza size

  // Define size constants for the pizza image
  final Map<String, double> _sizeMap = {
    'S': 200.0,
    'M': 250.0,
    'L': 300.0,
  };

  late AnimationController _animationController; // Controller for animations
  late Animation<double> _scaleAnimation; // Animation for scaling effect
  late Animation<double> _rotationAnimation; // Animation for rotation effect

  @override
  void initState() {
    super.initState();
    // Initialize AnimationController
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Initialize scale animation
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    // Initialize rotation animation
    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.forward(); // Start the animation
  }

  @override
  void dispose() {
    _animationController.dispose(); // Dispose of animation controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get current user's email from Firebase Auth
    final String? userEmail = FirebaseAuth.instance.currentUser?.email;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.pizzaName, // Title of the AppBar
          style: const TextStyle(color: Colors.white),
        ),
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.red, // Background color of the AppBar
        iconTheme: const IconThemeData(
          color: Colors.white, // Color of icons in the AppBar
        ),
      ),
      body: Stack(
        children: [
          // Full-circle background aligned to the top
          Positioned(
            top: -150, // Adjust vertical position
            left: -50, // Adjust horizontal position
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.orange
                    .withOpacity(0.2), // Background color with opacity
              ),
            ),
          ),
          // Pizza image with rotation and scaling animations
          Positioned(
            top: 16, // Position from top
            left: MediaQuery.of(context).size.width / 2 -
                (_sizeMap[_selectedSize]! / 2), // Center horizontally
            child: RotationTransition(
              turns: _rotationAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: _sizeMap[_selectedSize],
                  height: _sizeMap[_selectedSize],
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 3,
                        blurRadius: 7,
                        offset: const Offset(0, 3), // Shadow position
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.network(
                      widget.imageUrl, // Display pizza image
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Content aligned to the bottom
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize:
                    MainAxisSize.min, // Column takes only needed space
                children: [
                  // Pizza Name
                  Text(
                    widget.pizzaName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Pizza Description
                  Text(
                    widget.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Pizza Size Selection
                  const Text(
                    'Select Size',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _buildSizeOption('S'),
                      _buildSizeOption('M'),
                      _buildSizeOption('L'),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Quantity and Price
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Text(
                            'Quantity',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Spacer(),
                          Text(
                            'Price',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          // Quantity Selector
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                color: Colors.red,
                                onPressed: _quantity > 1
                                    ? () {
                                        setState(() {
                                          _quantity--;
                                        });
                                      }
                                    : null,
                              ),
                              Text(
                                _quantity.toString(),
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.black87,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add),
                                color: Colors.red,
                                onPressed: () {
                                  setState(() {
                                    _quantity++;
                                  });
                                },
                              ),
                            ],
                          ),
                          const Spacer(),
                          // Price Display
                          Text(
                            'Price: \$${(widget.price * _quantity).toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Buy Button
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate to OrderSummaryPage with pizza details and user email
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OrderSummaryPage(
                              pizzaName: widget.pizzaName,
                              description: widget.description,
                              imageUrl: widget.imageUrl,
                              price: widget.price,
                              quantity: _quantity,
                              selectedSize: _selectedSize,
                              userEmail: userEmail ?? '', // Pass user's email
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.lightBlue, // Button background color
                          padding: const EdgeInsets.symmetric(
                              horizontal: 100, vertical: 15),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                          ),
                          textStyle: const TextStyle(fontSize: 18),
                          foregroundColor: Colors.white),
                      child: const Text('Buy Now'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Method to build size option buttons
  Widget _buildSizeOption(String size) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSize = size; // Update selected size

          // Update the scale and rotation animations
          _scaleAnimation = Tween<double>(
            begin: _scaleAnimation.value,
            end: _sizeMap[size]! / _sizeMap[_selectedSize]!,
          ).animate(
            CurvedAnimation(
              parent: _animationController,
              curve: Curves.easeInOut,
            ),
          );

          _rotationAnimation = Tween<double>(
            begin: _rotationAnimation.value,
            end: _rotationAnimation.value + 0.06, // Rotate slightly
          ).animate(
            CurvedAnimation(
              parent: _animationController,
              curve: Curves.easeInOut,
            ),
          );

          _animationController.forward(from: 0.0); // Reset animation
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          color: _selectedSize == size
              ? Colors.red
              : Colors.grey[200], // Highlight selected size
        ),
        child: Text(
          size,
          style: TextStyle(
            fontSize: 16,
            color: _selectedSize == size ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}
