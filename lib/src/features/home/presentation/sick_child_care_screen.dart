
import 'package:flutter/material.dart';

class SickChildCareScreen extends StatelessWidget {
  const SickChildCareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sick Child Care'),
        backgroundColor: const Color(0xFFFFE7EA),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.medical_services_outlined,
              size: 70,
              color: Colors.pink,
            ),
            SizedBox(height: 20),
            Text(
              'Sick Child Care Services',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text('Find care services for your child.'),
          ],
        ),
      ),
    );
  }
}
