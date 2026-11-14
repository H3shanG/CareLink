
import 'package:flutter/material.dart';

class PediatricianLocatorScreen extends StatelessWidget {
  const PediatricianLocatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pediatrician Locator'),
        backgroundColor: const Color(0xFFE8F5E9),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_on_outlined,
              size: 70,
              color: Colors.green,
            ),
            SizedBox(height: 20),
            Text(
              'Pediatrician Locator',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Find pediatricians near you.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
