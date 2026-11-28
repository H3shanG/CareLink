import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../home/presentation/baby_health_record_store.dart';

class MyHealthRecordsScreen extends StatefulWidget {
  const MyHealthRecordsScreen({super.key});

  @override
  State<MyHealthRecordsScreen> createState() => _MyHealthRecordsScreenState();
}

class _MyHealthRecordsScreenState extends State<MyHealthRecordsScreen> {
  final BabyHealthRecordStore _store = BabyHealthRecordStore();

  late final Stream<QuerySnapshot<Map<String, dynamic>>> _recordsStream;

  @override
  void initState() {
    super.initState();
    _recordsStream = _store.getRecords();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Health Records'), centerTitle: true),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _recordsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Unable to load health records.'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final records = snapshot.data?.docs ?? [];

          if (records.isEmpty) {
            return const Center(
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
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: records.length,
            itemBuilder: (context, index) {
              final record = records[index].data();

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
                              record['name']?.toString() ?? 'Baby',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      _detail('Date of Birth', _formatDate(record['dob'])),
                      _detail('Blood Group', record['bloodGroup']?.toString()),
                      _detail(
                        'Weight',
                        record['weight'] != null
                            ? '${record['weight']} kg'
                            : null,
                      ),
                      _detail(
                        'Height',
                        record['height'] != null
                            ? '${record['height']} cm'
                            : null,
                      ),
                      _detail('Recorded At', _formatDate(record['createdAt'])),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(dynamic value) {
    if (value == null) {
      return 'Not available';
    }

    if (value is Timestamp) {
      final date = value.toDate();
      return '${date.day}/${date.month}/${date.year}';
    }

    return value.toString();
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
