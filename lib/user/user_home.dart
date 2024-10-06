import 'package:flutter/material.dart';
import 'package:pizza_delivery_app/order_management/order_histroy_&_status.dart';
import 'package:pizza_delivery_app/user/menu_screen.dart';
import 'package:pizza_delivery_app/user/search.dart';
import 'package:pizza_delivery_app/user/account_info.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  _UserHomePageState createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    MenuScreen(),
    const SearchFilterScreen(),
    const OrderHistoryPage(),
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
            borderRadius: BorderRadius.circular(15),
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
                Colors.red[400], // Orange color for selected item
            unselectedItemColor:
                Colors.grey[400], // Light grey for unselected items
            backgroundColor:
                Colors.transparent, // Transparent to show container color
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search_rounded),
                label: 'Search',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.assignment),
                label: 'My Orders',
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
