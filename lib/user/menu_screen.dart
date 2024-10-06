import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pizza_delivery_app/user/pizza_detail_page.dart';

// The MenuScreen widget displays a grid of pizzas fetched from Firestore.
class MenuScreen extends StatelessWidget {
  MenuScreen({super.key});

  // Instance of Firestore to interact with the database.
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Fetches pizza data from the 'pizzas' collection in Firestore.
  Future<List<Map<String, dynamic>>> fetchPizzas() async {
    // Retrieve all documents from the 'pizzas' collection.
    QuerySnapshot querySnapshot = await firestore.collection('pizzas').get();
    // Map each document to a Map containing pizza details.
    return querySnapshot.docs.map((doc) {
      return {
        'name': doc['name'], // Pizza name
        'price': doc['price'], // Pizza price
        'imageUrl': doc['imageUrl'], // URL of the pizza image
        'description': doc['description'], // Pizza description
        'isSpicy': doc['badge'] == 'spicy', // Spicy badge flag
        'isNonVeg': doc['badge'] == 'non-veg', // Non-Veg badge flag
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pizza Menu', // Title of the AppBar
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.red, // AppBar background color
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchPizzas(), // Call the fetchPizzas method
        builder: (context, snapshot) {
          // Display a loading spinner while data is being fetched
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // Display an error message if there's an issue fetching data
          else if (snapshot.hasError) {
            return const Center(child: Text('Error loading pizzas'));
          }
          // Display a message if no pizza data is available
          else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No pizzas available'));
          }
          // Display the pizza grid if data is successfully fetched
          else {
            final pizzas = snapshot.data!;
            return GridView.builder(
              padding: const EdgeInsets.all(8.0), // Padding around the grid
              itemCount: pizzas.length, // Number of pizza items
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Number of columns
                crossAxisSpacing: 8.0, // Spacing between columns
                mainAxisSpacing: 8.0, // Spacing between rows
                childAspectRatio: 2 / 3, // Aspect ratio of each grid item
              ),
              itemBuilder: (context, index) {
                return Card(
                  color: Colors.deepOrange[50], // Card background color
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(15.0), // Rounded corners
                  ),
                  elevation: 5.0, // Shadow elevation
                  child: GestureDetector(
                    onTap: () {
                      // Navigate to PizzaDetailsPage when the card is tapped
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PizzaDetailsPage(
                            pizzaName: pizzas[index]['name'],
                            description: pizzas[index]['description'],
                            imageUrl: pizzas[index]['imageUrl'],
                            price: pizzas[index]['price'],
                          ),
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Pizza Image
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(15.0),
                            topRight: Radius.circular(15.0),
                          ),
                          child: Image.network(
                            pizzas[index]['imageUrl'],
                            height: 120, // Height of the image
                            width: double.infinity, // Image width
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Row with Badges (Spicy, Non-Veg)
                              Row(
                                children: [
                                  if (pizzas[index]['isNonVeg'])
                                    const Badge(
                                        label: 'Non-Veg',
                                        color: Colors.red),
                                  if (pizzas[index]['isSpicy'])
                                    const Badge(
                                        label: 'Spicy',
                                        color: Colors.redAccent),
                                ],
                              ),
                              const SizedBox(height: 4),
                              // Pizza Name
                              Text(
                                pizzas[index]['name'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              // Pizza Description
                              Text(
                                pizzas[index]['description'],
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color.fromARGB(255, 102, 24, 0),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              // Row with Price
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '\$${pizzas[index]['price'].toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

// The Badge widget displays a small badge with a label and color.
class Badge extends StatelessWidget {
  final String label; // Text to display on the badge
  final Color color; // Background color of the badge

  const Badge({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 4.0), // Margin to the right
      padding: const EdgeInsets.symmetric(
          horizontal: 6.0, vertical: 2.0), // Padding inside the badge
      decoration: BoxDecoration(
        color: color, // Badge background color
        borderRadius: BorderRadius.circular(12.0), // Rounded corners
      ),
      child: Text(
        label, // Badge text
        style: const TextStyle(
          color: Colors.white, // Text color
          fontSize: 10, // Text size
        ),
      ),
    );
  }
}
