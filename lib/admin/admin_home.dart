import 'package:flutter/material.dart';
import 'package:pizza_delivery_app/admin/add_pizza.dart';
import 'package:pizza_delivery_app/admin/view_pizza.dart';
import 'package:pizza_delivery_app/order_management/order_approve.dart';
import 'package:pizza_delivery_app/user/account_info.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  _AdminHomePageState createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const AddPizzaPage(),
    const ViewPizzaPage(),
    const OrderApprovePage(),
    const AccountInfoPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors
                .black, // Dark background color for the bottom navigation bar
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              // Optional: adds shadow for better visibility
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, -2), // Shadow position
              ),
            ],
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType
                .fixed, // Ensures background color is respected
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            selectedItemColor:
                Colors.orange[300], // Orange color for selected item
            unselectedItemColor:
                Colors.grey[400], // Light grey for unselected items
            backgroundColor:
                Colors.transparent, // Transparent to show container color
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.local_pizza_rounded),
                label: 'Add Pizza',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.list_alt_rounded),
                label: 'View Pizza',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.add_task_sharp),
                label: 'Orders',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'User',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
