import 'package:flutter/material.dart';

class EquipmentRentalScreen extends StatelessWidget {
  const EquipmentRentalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Equipment Rental'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Available Medical Equipment',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          _buildEquipmentCard(
            context,
            icon: Icons.accessible,
            name: 'Wheelchair',
            description: 'Comfortable wheelchair for daily mobility.',
            price: 'Rs. 1,000 / day',
          ),

          _buildEquipmentCard(
            context,
            icon: Icons.airline_seat_flat,
            name: 'Hospital Bed',
            description: 'Adjustable bed for home patient care.',
            price: 'Rs. 2,500 / day',
          ),

          _buildEquipmentCard(
            context,
            icon: Icons.monitor_heart,
            name: 'Oxygen Concentrator',
            description: 'Equipment to support oxygen therapy.',
            price: 'Rs. 3,000 / day',
          ),

          _buildEquipmentCard(
            context,
            icon: Icons.health_and_safety,
            name: 'Blood Pressure Monitor',
            description: 'Monitor blood pressure at home.',
            price: 'Rs. 500 / day',
          ),
        ],
      ),
    );
  }

  Widget _buildEquipmentCard(
    BuildContext context, {
    required IconData icon,
    required String name,
    required String description,
    required String price,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 40, color: Colors.blue),
            const SizedBox(height: 10),
            Text(
              name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(description),
            const SizedBox(height: 10),
            Text(
              price,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$name selected for rental')),
                  );
                },
                child: const Text('Rent Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
