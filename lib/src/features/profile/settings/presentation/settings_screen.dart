import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), centerTitle: true),
      body: ListView(
        children: [
          const SizedBox(height: 10),

          SwitchListTile(
            title: const Text('Push Notifications'),
            subtitle: const Text('Receive app notifications'),
            value: true,
            onChanged: (value) {},
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text('Privacy & Security'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),

          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Language'),
            subtitle: const Text('English'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),

          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About CareLink'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
