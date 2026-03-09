// presentation/screens/main/settings_screen.dart
// Shows user profile and notification preferences
// Allows logout

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../domain/providers/auth_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final profile = authProvider.userProfile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Text(
                      (profile?['fullName'] ?? 'U')[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 32,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    profile?['fullName'] ?? 'User',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    authProvider.user?.email ?? '',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Preferences Section
          Text(
            'Preferences',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),

          // Notification toggle
          Card(
            child: SwitchListTile(
              title: const Text('Location Notifications'),
              subtitle: const Text('Get alerts about nearby services'),
              value: authProvider.notificationsEnabled,
              onChanged: (value) {
                authProvider.setNotifications(value);
              },
              secondary: const Icon(Icons.notifications),
            ),
          ),
          const SizedBox(height: 24),

          // Account Section
          Text(
            'Account',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),

          // Logout button
          Card(
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () => _confirmLogout(context, authProvider),
            ),
          ),

          const SizedBox(height: 32),

          // App info
          Center(
            child: Text(
              'Kigali City Navigator v1.0',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context, AuthProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              provider.signOut();
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
