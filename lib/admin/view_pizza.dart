import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pizza_delivery_app/admin/update_pizza.dart';

// This is the main widget class for viewing pizzas. It extends StatelessWidget, meaning it's immutable.
class ViewPizzaPage extends StatelessWidget {
  const ViewPizzaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // A Scaffold provides the structure for the visual interface of the page.
      appBar: AppBar(
        // AppBar at the top of the page with the title 'Pizzas'.
        title: const Text(
          'Pizzas',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepOrange, // Background color of the AppBar.
      ),
      body: StreamBuilder<QuerySnapshot>(
        // StreamBuilder listens to a stream of data (real-time updates) from Firestore.
        stream: FirebaseFirestore.instance.collection('pizzas').snapshots(),
        builder: (context, snapshot) {
          // Checking the connection state of the stream.
          if (snapshot.connectionState == ConnectionState.waiting) {
            // While waiting for data, a loading spinner is displayed.
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // If there's an error, display the error message.
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            // If no data is found or the collection is empty, display a message.
            return const Center(child: Text('No pizzas found.'));
          } else {
            // If data is available, retrieve the list of pizzas.
            final pizzas = snapshot.data!.docs;
            return ListView.builder(
              // ListView.builder creates a scrollable list of items.
              itemCount: pizzas.length, // Number of pizzas to display.
              itemBuilder: (context, index) {
                final pizza = pizzas[index]; // Get each pizza document.
                return Card(
                  // Each pizza is displayed in a Card widget.
                  color: Colors.deepOrange[50],
                  margin: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0), // Card margins.
                  elevation: 5, // Card shadow elevation.
                  child: ListTile(
                    // ListTile is used to display pizza details in a list format.
                    contentPadding:
                        const EdgeInsets.all(8.0), // Padding inside the card.
                    title: Text(
                      pizza['name'], // Pizza name displayed as the title.
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      pizza[
                          'description'], // Pizza description displayed below the title.
                      maxLines:
                          3, // Limit to 3 lines, with ellipsis if it overflows.
                      overflow: TextOverflow.ellipsis,
                    ),
                    leading: Image.network(
                      pizza['imageUrl'], // Pizza image displayed on the left.
                    ),
                    trailing: Text(
                      '\$${pizza['price']}', // Pizza price displayed on the right.
                      style: const TextStyle(
                          color: Colors.deepOrange,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
                      // When the ListTile is tapped, navigate to the UpdatePizzaPage.
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UpdatePizzaPage(
                              pizzaId: pizza
                                  .id), // Pass the pizza ID to the update page.
                        ),
                      );
                    },
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
