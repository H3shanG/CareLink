import 'package:flutter/material.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help & Support'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'How can we help you?',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('Find answers to common questions about CareLink.'),
          const SizedBox(height: 20),

          const Text(
            'Frequently Asked Questions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          _faq(
            'How do I book a caregiver?',
            'Open Caregiver / Nurse Booking, select a caregiver, '
                'and follow the booking steps.',
          ),
          _faq(
            'Where can I see my bookings?',
            'Open Profile and select My Bookings to view your bookings.',
          ),
          _faq(
            'How do I save a caregiver?',
            'Tap the heart icon beside a caregiver. You can find '
                'saved caregivers under Profile → Saved Providers.',
          ),
          _faq(
            'Where can I view my health records?',
            'Open Profile and select My Health Records.',
          ),
          _faq(
            'How do I change my profile details?',
            'Open Profile → My Profile, update your details, '
                'and tap Save Changes.',
          ),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 12),

          const Text(
            'Contact Support',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          const ListTile(
            leading: Icon(Icons.email_outlined),
            title: Text('Email Support'),
            subtitle: Text('Please contact the CareLink support team.'),
          ),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('About CareLink'),
            subtitle: Text(
              'CareLink helps users access care services '
              'and manage their care-related information.',
            ),
          ),
        ],
      ),
    );
  }

  static Widget _faq(String question, String answer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(answer),
          ),
        ],
      ),
    );
  }
}
