
import 'package:flutter/material.dart';

class BabyHealthRecordScreen extends StatelessWidget {
  const BabyHealthRecordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Baby Health Record'),
        backgroundColor: const Color(0xFFEAF8F4),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description_outlined,
              size: 70,
              color: Colors.teal,
            ),
            SizedBox(height: 20),
            Text(
              'Baby Health Record',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Your baby health records will appear here.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
