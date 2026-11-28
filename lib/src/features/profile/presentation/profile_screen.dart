
import 'package:flutter/material.dart';

import '../../auth/services/auth_service.dart';
import '../../../core/routes/route_names.dart';
import '../../booking/presentation/my_bookings_screen.dart';
import '../settings/presentation/settings_screen.dart';
import '../notifications/presentation/notifications_screen.dart';
import '../saved_providers/presentation/saved_providers_screen.dart';
import 'my_profile_screen.dart';
import 'my_health_records_screen.dart';
import 'help_support_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();

  bool _isLoggingOut = false;

  Future<void> _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout from CareLink?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      await _logout();
    }
  }

  Future<void> _logout() async {
    if (_isLoggingOut) return;

    setState(() {
      _isLoggingOut = true;
    });

    try {
      await _authService.logout();

      if (!mounted) return;

      Navigator.of(context)
          .pushNamedAndRemoveUntil(RouteNames.login, (route) => false);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoggingOut = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logout failed. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Profile'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const CircleAvatar(radius: 45, child: Icon(Icons.person, size: 50)),
          const SizedBox(height: 12),
          const Center(
            child: Text(
              'My Account',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 24),

          _buildProfileOption(
            Icons.person_outline,
            'My Profile',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyProfileScreen()),
              );
            },
          ),

          _buildProfileOption(
            Icons.calendar_month,
            'My Bookings',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyBookingsScreen()),
              );
            },
          ),

          _buildProfileOption(
            Icons.medical_services_outlined,
            'My Health Records',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const MyHealthRecordsScreen(),
                ),
              );
            },
          ),

          _buildProfileOption(
            Icons.favorite_border,
            'Saved Providers',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SavedProvidersScreen()),
              );
            },
          ),

          _buildProfileOption(
            Icons.notifications_outlined,
            'Notifications',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              );
            },
          ),

          _buildProfileOption(
            Icons.settings_outlined,
            'Settings',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),

          _buildProfileOption(
            Icons.help_outline,
            'Help & Support',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HelpSupportScreen()),
              );
            },
          ),

          _buildProfileOption(
            Icons.logout,
            _isLoggingOut ? 'Logging out...' : 'Logout',
            onTap: _isLoggingOut ? null : _confirmLogout,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption(
    IconData icon,
    String title, {
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
