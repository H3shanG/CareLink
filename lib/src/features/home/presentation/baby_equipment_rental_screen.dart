
import 'package:flutter/material.dart';

class BabyEquipmentRentalScreen extends StatelessWidget {
  const BabyEquipmentRentalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Baby Equipment Rental'),
        backgroundColor: const Color(0xFFE3F2FD),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.child_friendly,
              size: 70,
              color: Colors.blue,
            ),
            SizedBox(height: 20),
            Text(
              'Baby Equipment Rental',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Baby equipment rental services will appear here.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
