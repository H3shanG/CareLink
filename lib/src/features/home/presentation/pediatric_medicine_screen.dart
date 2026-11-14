
import 'package:flutter/material.dart';

class PediatricMedicineScreen extends StatelessWidget {
  const PediatricMedicineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pediatric Medicine'),
        backgroundColor: const Color(0xFFF3E8FF),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.medication_outlined,
              size: 70,
              color: Colors.purple,
            ),
            SizedBox(height: 20),
            Text(
              'Pediatric Medicine',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Pediatric medicine services will appear here.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
