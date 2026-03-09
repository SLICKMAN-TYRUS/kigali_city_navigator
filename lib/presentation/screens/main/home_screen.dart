// presentation/screens/main/home_screen.dart
// Main app shell with BottomNavigationBar
// Contains Directory, My Listings, Map View, and Settings screens

import 'package:flutter/material.dart';
import 'directory_screen.dart';
import 'my_listings_screen.dart';
import 'map_view_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // Four main screens as per assignment requirements
  final List<Widget> _screens = [
    const DirectoryScreen(),
    const MyListingsScreen(),
    const MapViewScreen(),
    const SettingsScreen(),
  ];

  final List<String> _titles = [
    'Directory',
    'My Listings',
    'Map View',
    'Settings',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // No app bar here - each screen manages its own
      body: IndexedStack(
        // IndexedStack keeps all screens alive but only shows current one
        // This preserves state when switching tabs
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed, // Shows all 4 labels
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Directory',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder),
            label: 'My Listings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
