import 'package:flutter/material.dart';

import '../../home/presentation/baby_health_record_store.dart';

class MyHealthRecordsScreen extends StatelessWidget {
  const MyHealthRecordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final records = BabyHealthRecordStore.records;

    return Scaffold(
      appBar: AppBar(title: const Text('My Health Records'), centerTitle: true),
      body: records.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.medical_information_outlined,
                      size: 60,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'No health records saved yet.',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Add a baby health record from the Baby Health Record section.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: records.length,
              itemBuilder: (context, index) {
                final record = records[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 14),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(child: Icon(Icons.child_care)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                record['name'] ?? 'Baby',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        _detail('Date of Birth', record['dob']),
                        _detail('Blood Group', record['bloodGroup']),
                        _detail('Weight', '${record['weight']} kg'),
                        _detail('Height', '${record['height']} cm'),
                        _detail('Recorded At', record['recordedAt']),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _detail(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 115,
            child: Text(label, style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(child: Text(value ?? 'Not available')),
        ],
      ),
    );
  }
}
