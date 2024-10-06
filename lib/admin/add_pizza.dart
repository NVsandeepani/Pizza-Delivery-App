import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddPizzaPage extends StatefulWidget {
  const AddPizzaPage({super.key}); // Constructor for the stateful widget.

  @override
  _AddPizzaPageState createState() =>
      _AddPizzaPageState(); // Create the state for this widget.
}

class _AddPizzaPageState extends State<AddPizzaPage> {
  // State class to manage the state of the widget.

  final _formKey =
      GlobalKey<FormState>(); // Key to identify the form and manage validation.
  final _nameController =
      TextEditingController(); // Controller for the pizza name input field.
  final _descriptionController =
      TextEditingController(); // Controller for the description input field.
  final _priceController =
      TextEditingController(); // Controller for the price input field.
  String _badge = 'spicy'; // Initial value for the badge dropdown.
  File? _imageFile; // Variable to store the selected image file.

  final picker = ImagePicker(); // Instance of ImagePicker to select images.

  // Function to pick an image from the gallery.
  Future pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile
            .path); // If an image is picked, set the _imageFile variable.
      } else {
        print('No image selected.');
      }
    });
  }

  // Function to upload the selected image to Firebase Storage.
  Future<String> uploadImageToFirebase(File imageFile) async {
    FirebaseStorage storage =
        FirebaseStorage.instance; // Get an instance of Firebase Storage.
    Reference ref = storage.ref().child(
        "pizza_images/${DateTime.now()}.jpg"); // Create a reference with a unique name.
    UploadTask uploadTask = ref.putFile(imageFile); // Upload the file.
    TaskSnapshot taskSnapshot =
        await uploadTask; // Wait for the upload to complete.
    return await taskSnapshot.ref
        .getDownloadURL(); // Get the download URL of the uploaded image.
  }

  // Function to add the pizza details to Firestore.
  Future<void> addPizzaToFirestore(String name, String description,
      double price, String imageUrl, String badge) async {
    FirebaseFirestore firestore =
        FirebaseFirestore.instance; // Get an instance of Firestore.
    await firestore.collection('pizzas').add({
      'name': name, // Add the pizza name to Firestore.
      'description': description, // Add the description to Firestore.
      'price': price, // Add the price to Firestore.
      'imageUrl': imageUrl, // Add the image URL to Firestore.
      'badge': badge, // Add the badge to Firestore.
    });
  }

  // Function to validate the form, upload the image, and add pizza data to Firestore.
  Future<void> submitPizzaData() async {
    if (_formKey.currentState!.validate() && _imageFile != null) {
      // Check if the form is valid and an image is selected.
      String imageUrl = await uploadImageToFirebase(
          _imageFile!); // Upload the image and get the URL.
      await addPizzaToFirestore(
        _nameController.text,
        _descriptionController.text,
        double.parse(_priceController.text),
        imageUrl,
        _badge,
      );
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
              Text('Pizza added successfully!'))); // Show a success message.
      _formKey.currentState!.reset(); // Reset the form fields.
      setState(() {
        _imageFile = null; // Reset the selected image.
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Please complete the form and select an image'))); // Show an error message if validation fails.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Pizza',
          style: TextStyle(color: Colors.white), // Set the text color to white.
        ),
        centerTitle: true, // Center the title in the app bar.
        backgroundColor:
            Colors.deepOrange, // Set the background color of the app bar.
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Add padding around the body.
        child: Form(
          key: _formKey, // Assign the form key to the form widget.
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller:
                    _nameController, // Bind the controller to the input field.
                decoration: const InputDecoration(labelText: 'Pizza Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter pizza name'; // Validate that the name is not empty.
                  }
                  return null;
                },
              ),
              TextFormField(
                controller:
                    _descriptionController, // Bind the controller to the input field.
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter description'; // Validate that the description is not empty.
                  }
                  return null;
                },
              ),
              TextFormField(
                controller:
                    _priceController, // Bind the controller to the input field.
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType:
                    TextInputType.number, // Set the keyboard type to number.
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter price'; // Validate that the price is not empty.
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _badge, // Set the initial value of the dropdown.
                items: ['spicy', 'non-veg'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value), // Create dropdown items.
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _badge = newValue!; // Update the selected badge.
                  });
                },
                decoration: const InputDecoration(
                    labelText: 'Badge'), // Set the label for the dropdown.
              ),
              const SizedBox(height: 20), // Add vertical spacing.
              _imageFile != null
                  ? Image.file(
                      _imageFile!,
                      height: 200,
                      width: double.infinity, // Display the selected image.
                    )
                  : Container(
                      height: 200,
                      color: Colors.grey[
                          200], // Display a placeholder if no image is selected.
                      child: const Icon(Icons.image, size: 100)),
              const SizedBox(height: 20), // Add vertical spacing.
              SizedBox(
                height: 45,
                child: ElevatedButton(
                  onPressed:
                      pickImage, // Call the pickImage function when pressed.
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlue,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 75, vertical: 10), // Style the button.
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(10), // Rounded corners
                      ),
                      textStyle: const TextStyle(fontSize: 17),
                      foregroundColor: Colors.white),
                  child: const Text('Pick Image'),
                ),
              ),
              const SizedBox(height: 20), // Add vertical spacing.
              SizedBox(
                height: 45,
                child: ElevatedButton(
                  onPressed:
                      submitPizzaData, // Call the submitPizzaData function when pressed.
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightGreen,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 75, vertical: 10), // Style the button.
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(10), // Rounded corners
                      ),
                      textStyle: const TextStyle(fontSize: 17),
                      foregroundColor: Colors.white),
                  child: const Text('Add Pizza'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
