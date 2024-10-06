import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

// Stateful widget for updating pizza details
class UpdatePizzaPage extends StatefulWidget {
  final String pizzaId;

  UpdatePizzaPage({required this.pizzaId});

  @override
  _UpdatePizzaPageState createState() => _UpdatePizzaPageState();
}

class _UpdatePizzaPageState extends State<UpdatePizzaPage> {
  // Controllers to handle the text input fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _badgeController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  File? _selectedImage; // File to store the selected image
  String? _imageUrl; // URL of the existing pizza image

  final ImagePicker _picker = ImagePicker(); // Image picker instance

  @override
  void initState() {
    super.initState();
    _loadPizzaData(); // Load pizza data when the page is initialized
  }

  // Load the pizza data from Firestore and populate the text fields
  Future<void> _loadPizzaData() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('pizzas')
        .doc(widget.pizzaId)
        .get();

    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    setState(() {
      _nameController.text = data['name'] ?? ''; // Set name
      _descriptionController.text =
          data['description'] ?? ''; // Set description
      _badgeController.text = data['badge'] ?? ''; // Set badge
      _priceController.text = data['price'].toString(); // Set price
      _imageUrl = data['imageUrl'] ?? ''; // Set image URL
    });
  }

  // Update the pizza details in Firestore
  Future<void> _updatePizza() async {
    String imageUrl =
        _imageUrl ?? ''; // Use existing image URL if no new image is selected

    // If a new image is selected, upload it to Firebase Storage
    if (_selectedImage != null) {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('pizza_images/${widget.pizzaId}.jpg');

      await storageRef.putFile(_selectedImage!); // Upload the file
      imageUrl = await storageRef.getDownloadURL(); // Get the download URL
    }

    // Update the Firestore document with new data
    await FirebaseFirestore.instance
        .collection('pizzas')
        .doc(widget.pizzaId)
        .update({
      'name': _nameController.text,
      'description': _descriptionController.text,
      'badge': _badgeController.text,
      'price': double.parse(_priceController.text), // Convert price to double
      'imageUrl': imageUrl,
    });

    // Show a success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pizza updated successfully')),
    );

    Navigator.pop(context); // Go back to the pizza list after updating
  }

  // Delete the pizza from Firestore
  Future<void> _deletePizza() async {
    await FirebaseFirestore.instance
        .collection('pizzas')
        .doc(widget.pizzaId)
        .delete();

    // Show a success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pizza deleted successfully')),
    );

    Navigator.pop(context); // Go back to the pizza list after deletion
  }

  // Pick an image from the gallery
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path); // Set the selected image file
        _imageUrl = null; // Clear existing URL if a new image is selected
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Pizza',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepOrange,
        iconTheme: const IconThemeData(
          color: Colors.white, // Change this to the desired color
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Text field for pizza name
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Pizza Name'),
            ),
            const SizedBox(height: 8),
            // Text field for pizza description
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 8),
            // Text field for pizza badge
            TextField(
              controller: _badgeController,
              decoration: const InputDecoration(labelText: 'Badge'),
            ),
            const SizedBox(height: 8),
            // Text field for pizza price
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number, // Input type as number
            ),
            const SizedBox(height: 8),
            // Display the selected image or existing image from URL
            _selectedImage == null && _imageUrl != null
                ? Image.network(
                    _imageUrl!,
                    height: 200,
                  )
                : _selectedImage != null
                    ? Image.file(
                        _selectedImage!,
                        height: 200,
                      )
                    : Container(height: 200, color: Colors.grey[200]),
            const SizedBox(height: 16),
            // Button to pick an image
            SizedBox(
              height: 45,
              child: ElevatedButton(
                onPressed: _pickImage,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightGreen,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 75, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(10), // Rounded corners
                    ),
                    textStyle: const TextStyle(fontSize: 18),
                    foregroundColor: Colors.white),
                child: const Text('Pick Image'),
              ),
            ),
            const SizedBox(height: 16),
            // Row containing Update and Delete buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  height: 45,
                  child: ElevatedButton(
                    onPressed: _updatePizza, // Call update pizza function
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlue,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 75, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(10), // Rounded corners
                        ),
                        textStyle: const TextStyle(fontSize: 18),
                        foregroundColor: Colors.white),
                    child: const Text('Update'),
                  ),
                ),
                SizedBox(
                  height: 45,
                  child: ElevatedButton(
                    onPressed: _deletePizza, // Call delete pizza function
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(10), // Rounded corners
                        ),
                        textStyle: const TextStyle(fontSize: 18),
                        foregroundColor: Colors.white),
                    child: const Text('Delete'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
