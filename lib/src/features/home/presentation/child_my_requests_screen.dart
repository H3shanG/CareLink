import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'child_care_request_store.dart';
import 'baby_equipment_rental_store.dart';
import 'pediatric_medicine_request_store.dart';
import 'pediatrician_appointment_store.dart';
import 'emergency_transport_request_store.dart';

class ChildMyRequestsScreen extends StatelessWidget {
  const ChildMyRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || snapshot.data == null) {
          return Scaffold(
            backgroundColor: const Color(0xFFF9FAFC),
            appBar: AppBar(
              title: const Text('My Requests'),
              backgroundColor: Colors.white,
            ),
            body: const Center(
              child: Text('Please log in to view your requests.'),
            ),
          );
        }

        return _ChildMyRequestsContent(key: ValueKey(snapshot.data!.uid));
      },
    );
  }
}

class _ChildMyRequestsContent extends StatefulWidget {
  const _ChildMyRequestsContent({super.key});

  @override
  State<_ChildMyRequestsContent> createState() =>
      _ChildMyRequestsContentState();
}

class _ChildMyRequestsContentState extends State<_ChildMyRequestsContent> {
  // Firebase backend stores

  final ChildCareRequestStore _childCareStore = ChildCareRequestStore();

  final PediatricMedicineRequestStore _medicineStore =
      PediatricMedicineRequestStore();

  final BabyEquipmentRentalStore _rentalStore = BabyEquipmentRentalStore();

  // Firebase streams

  late final Stream<QuerySnapshot<Map<String, dynamic>>> _childCareStream;

  late final Stream<QuerySnapshot<Map<String, dynamic>>> _medicineStream;

  late final Stream<QuerySnapshot<Map<String, dynamic>>> _rentalStream;

  @override
  void initState() {
    super.initState();

    _childCareStream = _childCareStore.getRequests();

    _medicineStream = _medicineStore.getRequests();

    _rentalStream = _rentalStore.getRentals();
  }

  // Convert Firebase timestamps to readable text

  String _formatValue(dynamic value) {
    if (value is Timestamp) {
      return value.toDate().toString().substring(0, 16);
    }

    if (value == null) {
      return 'Not available';
    }

    return value.toString();
  }

  // Convert Firestore documents into displayable maps

  List<Map<String, String>> _convertDocuments(
    QuerySnapshot<Map<String, dynamic>>? snapshot,
  ) {
    if (snapshot == null) {
      return [];
    }

    final documents = snapshot.docs.toList();

    // Sort newest requests first

    documents.sort((a, b) {
      final aTime = a.data()['createdAt'];
      final bTime = b.data()['createdAt'];

      if (aTime is Timestamp && bTime is Timestamp) {
        return bTime.compareTo(aTime);
      }

      if (aTime is Timestamp) return -1;
      if (bTime is Timestamp) return 1;

      return 0;
    });

    return documents.map((doc) {
      final data = doc.data();

      final request = <String, String>{};

      for (final entry in data.entries) {
        // Do not display internal database fields

        if (entry.key == 'userId' || entry.key == 'updatedAt') {
          continue;
        }

        final key = entry.key == 'createdAt' ? 'date' : entry.key;

        request[key] = _formatValue(entry.value);
      }

      return request;
    }).toList();
  }

  // Improve the displayed field labels

  String _formatLabel(String key) {
    switch (key) {
      case 'name':
      case 'childName':
        return 'Child Name';

      case 'age':
        return 'Age';

      case 'symptoms':
        return 'Symptoms';

      case 'medicine':
        return 'Medicine';

      case 'notes':
        return 'Notes';

      case 'equipment':
        return 'Equipment';

      case 'duration':
        return 'Duration (Days)';

      case 'address':
        return 'Address';

      case 'doctor':
        return 'Doctor';

      case 'appointmentDate':
        return 'Appointment Date';

      case 'appointmentTime':
        return 'Appointment Time';

      case 'status':
        return 'Status';

      case 'date':
        return 'Submitted';

      default:
        return key;
    }
  }

  // Original empty requests screen

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_outlined, size: 70, color: Colors.grey),

          SizedBox(height: 16),

          Text(
            'No Requests Yet',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          SizedBox(height: 8),

          Text('Your child care requests will appear here.'),
        ],
      ),
    );
  }

  // Original request card design

  Widget _buildRequestCard(String groupName, Map<String, String> request) {
    return Card(
      color: Colors.white,

      margin: const EdgeInsets.only(bottom: 12),

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),

      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text(
              groupName,

              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),

            const SizedBox(height: 12),

            for (final entry in request.entries)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),

                child: Text(
                  '${_formatLabel(entry.key)}: '
                  '${entry.value}',
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Display all request groups

  Widget _buildRequests(Map<String, List<Map<String, String>>> groups) {
    final totalRequests = groups.values.fold<int>(
      0,
      (total, requests) => total + requests.length,
    );

    if (totalRequests == 0) {
      return _buildEmptyState();
    }

    return ListView(
      padding: const EdgeInsets.all(16),

      children: [
        Text(
          'Total Requests: $totalRequests',

          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 16),

        for (final group in groups.entries)
          for (final request in group.value)
            _buildRequestCard(group.key, request),
      ],
    );
  }

  // Handle Firebase loading and errors

  Widget _buildErrorState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Text(
          'Unable to load requests. '
          'Please check your connection and Firebase permissions.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.red),
        ),
      ),
    );
  }

  // Main user interface

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),

      appBar: AppBar(
        title: const Text('My Requests'),
        backgroundColor: Colors.white,
      ),

      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _childCareStream,

        builder: (context, childCareSnapshot) {
          if (childCareSnapshot.hasError) {
            return _buildErrorState();
          }

          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _medicineStream,

            builder: (context, medicineSnapshot) {
              if (medicineSnapshot.hasError) {
                return _buildErrorState();
              }

              return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _rentalStream,

                builder: (context, rentalSnapshot) {
                  if (rentalSnapshot.hasError) {
                    return _buildErrorState();
                  }

                  // Wait for all Firebase collections

                  if ((childCareSnapshot.connectionState ==
                              ConnectionState.waiting &&
                          !childCareSnapshot.hasData) ||
                      (medicineSnapshot.connectionState ==
                              ConnectionState.waiting &&
                          !medicineSnapshot.hasData) ||
                      (rentalSnapshot.connectionState ==
                              ConnectionState.waiting &&
                          !rentalSnapshot.hasData)) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final groups = <String, List<Map<String, String>>>{
                    // Firebase collections

                    'Sick Child Care': _convertDocuments(
                      childCareSnapshot.data,
                    ),

                    'Pediatric Medicine': _convertDocuments(
                      medicineSnapshot.data,
                    ),

                    'Baby Equipment Rental': _convertDocuments(
                      rentalSnapshot.data,
                    ),

                    // Temporary lists until the remaining
                    // backend modules are implemented
                    'Pediatrician Appointment': PediatricianAppointmentStore
                        .appointments
                        .reversed
                        .toList(),

                    'Emergency Transport': EmergencyTransportRequestStore
                        .requests
                        .reversed
                        .toList(),
                  };

                  return _buildRequests(groups);
                },
              );
            },
          );
        },
      ),
    );
  }
}
