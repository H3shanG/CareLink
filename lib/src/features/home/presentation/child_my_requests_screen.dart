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
  // ==========================================
  // FIREBASE BACKEND STORES
  // ==========================================

  final ChildCareRequestStore _childCareStore = ChildCareRequestStore();

  final PediatricMedicineRequestStore _medicineStore =
      PediatricMedicineRequestStore();

  final BabyEquipmentRentalStore _rentalStore = BabyEquipmentRentalStore();

  final PediatricianAppointmentStore _appointmentStore =
      PediatricianAppointmentStore();

  // ==========================================
  // FIREBASE STREAMS
  // ==========================================

  late final Stream<QuerySnapshot<Map<String, dynamic>>> _childCareStream;

  late final Stream<QuerySnapshot<Map<String, dynamic>>> _medicineStream;

  late final Stream<QuerySnapshot<Map<String, dynamic>>> _rentalStream;

  late final Stream<QuerySnapshot<Map<String, dynamic>>> _appointmentStream;

  // ==========================================
  // INITIALIZE FIREBASE STREAMS
  // ==========================================

  @override
  void initState() {
    super.initState();

    _childCareStream = _childCareStore.getRequests();

    _medicineStream = _medicineStore.getRequests();

    _rentalStream = _rentalStore.getRentals();

    _appointmentStream = _appointmentStore.getAppointments();
  }

  // ==========================================
  // FORMAT FIRESTORE VALUES
  // ==========================================

  String _formatValue(dynamic value) {
    if (value is Timestamp) {
      return value.toDate().toLocal().toString().substring(0, 16);
    }

    if (value == null) {
      return 'Not available';
    }

    return value.toString();
  }

  // ==========================================
  // CONVERT FIRESTORE DOCUMENTS
  // ==========================================

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
        // Hide internal database fields

        if (entry.key == 'userId' ||
            entry.key == 'updatedAt' ||
            entry.key == 'doctorId') {
          continue;
        }

        final key = entry.key == 'createdAt' ? 'date' : entry.key;

        request[key] = _formatValue(entry.value);
      }

      return request;
    }).toList();
  }

  // ==========================================
  // FORMAT DISPLAY LABELS
  // ==========================================

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

      case 'appointmentAt':
        return 'Requested Appointment';

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

  // ==========================================
  // EMPTY REQUESTS SCREEN
  // ==========================================

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

  // ==========================================
  // REQUEST CARD DESIGN
  // ==========================================

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

  // ==========================================
  // DISPLAY ALL REQUEST GROUPS
  // ==========================================

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

  // ==========================================
  // FIREBASE ERROR HANDLING
  // ==========================================

  Widget _buildErrorState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(20),

        child: Text(
          'Unable to load requests. '
          'Please check your connection and '
          'Firebase permissions.',

          textAlign: TextAlign.center,

          style: TextStyle(color: Colors.red),
        ),
      ),
    );
  }

  // ==========================================
  // MAIN USER INTERFACE
  // ==========================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),

      appBar: AppBar(
        title: const Text('My Requests'),
        backgroundColor: Colors.white,
      ),

      // SICK CHILD CARE STREAM
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _childCareStream,

        builder: (context, childCareSnapshot) {
          if (childCareSnapshot.hasError) {
            return _buildErrorState();
          }

          // PEDIATRIC MEDICINE STREAM

          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _medicineStream,

            builder: (context, medicineSnapshot) {
              if (medicineSnapshot.hasError) {
                return _buildErrorState();
              }

              // BABY EQUIPMENT RENTAL STREAM

              return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _rentalStream,

                builder: (context, rentalSnapshot) {
                  if (rentalSnapshot.hasError) {
                    return _buildErrorState();
                  }

                  // PEDIATRICIAN APPOINTMENT STREAM

                  return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: _appointmentStream,

                    builder: (context, appointmentSnapshot) {
                      if (appointmentSnapshot.hasError) {
                        return _buildErrorState();
                      }

                      // Wait until all Firebase
                      // collections have loaded

                      if (!childCareSnapshot.hasData ||
                          !medicineSnapshot.hasData ||
                          !rentalSnapshot.hasData ||
                          !appointmentSnapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final groups = <String, List<Map<String, String>>>{
                        // SICK CHILD CARE

                        'Sick Child Care': _convertDocuments(
                          childCareSnapshot.data,
                        ),

                        // PEDIATRIC MEDICINE
                        'Pediatric Medicine': _convertDocuments(
                          medicineSnapshot.data,
                        ),

                        // BABY EQUIPMENT RENTAL
                        'Baby Equipment Rental': _convertDocuments(
                          rentalSnapshot.data,
                        ),

                        // PEDIATRICIAN APPOINTMENT
                        'Pediatrician Appointment': _convertDocuments(
                          appointmentSnapshot.data,
                        ),

                        // EMERGENCY TRANSPORT
                        // Temporary storage until the
                        // final backend is implemented
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
          );
        },
      ),
    );
  }
}
