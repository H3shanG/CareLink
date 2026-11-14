import 'package:flutter/material.dart';
import '../data/caregiver_model.dart';
import 'caregiver_booking_screen.dart';

class CaregiverProfileScreen extends StatelessWidget {
  final Caregiver caregiver;
  const CaregiverProfileScreen({super.key, required this.caregiver});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Caregiver Profile'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: CircleAvatar(
              radius: 52,
              backgroundColor: scheme.primaryContainer,
              child: Icon(Icons.person, size: 60, color: scheme.primary),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(caregiver.name,
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold)),
          ),
          Center(
            child: Text(caregiver.role,
                style: const TextStyle(color: Colors.grey)),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 18),
              Text(' ${caregiver.rating} (${caregiver.reviews} reviews)'),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _InfoBox(
                  label: 'Experience',
                  value: '${caregiver.experienceYears} yrs'),
              const SizedBox(width: 12),
              _InfoBox(label: 'Distance', value: caregiver.distance),
              const SizedBox(width: 12),
              _InfoBox(
                  label: 'Rate', value: 'Rs. ${caregiver.pricePerHour}/hr'),
            ],
          ),
          const SizedBox(height: 20),
          const Text('About',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(caregiver.about),
          const SizedBox(height: 16),
          const Text('Services',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            children:
                caregiver.tags.map((t) => Chip(label: Text(t))).toList(),
          ),
          const SizedBox(height: 16),
          const Text('Languages',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(caregiver.languages.join(', ')),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        CaregiverBookingScreen(caregiver: caregiver),
                  ),
                );
              },
              child: const Text('Book Now'),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final String label;
  final String value;
  const _InfoBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(value,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}