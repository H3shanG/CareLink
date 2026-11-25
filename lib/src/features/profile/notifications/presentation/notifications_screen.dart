import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ListTile(
            leading: Icon(Icons.calendar_month, color: Colors.blue),
            title: Text('Booking Update'),
            subtitle: Text('Your booking has been confirmed.'),
            trailing: Text('Today'),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.medical_services, color: Colors.green),
            title: Text('Health Reminder'),
            subtitle: Text('Remember to check your health records.'),
            trailing: Text('Yesterday'),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.favorite, color: Colors.red),
            title: Text('CareLink Update'),
            subtitle: Text('Thank you for using CareLink!'),
            trailing: Text('2 days ago'),
          ),
        ],
      ),
    );
  }
}
