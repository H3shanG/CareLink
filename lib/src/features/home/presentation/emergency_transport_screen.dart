
import 'package:flutter/material.dart';

class EmergencyTransportScreen extends StatelessWidget {
  const EmergencyTransportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Transport'),
        backgroundColor: const Color(0xFFFFE7EA),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_shipping_outlined,
              size: 70,
              color: Colors.red,
            ),
            SizedBox(height: 20),
            Text(
              'Emergency Transport',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Emergency transport services will appear here.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
