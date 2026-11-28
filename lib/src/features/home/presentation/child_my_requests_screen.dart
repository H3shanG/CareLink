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

  final EmergencyTransportRequestStore _emergencyStore =
      EmergencyTransportRequestStore();

  // ==========================================
  // FIREBASE STREAMS
  // ==========================================

  late final Stream<QuerySnapshot<Map<String, dynamic>>> _childCareStream;

  late final Stream<QuerySnapshot<Map<String, dynamic>>> _medicineStream;

  late final Stream<QuerySnapshot<Map<String, dynamic>>> _rentalStream;

  late final Stream<QuerySnapshot<Map<String, dynamic>>> _appointmentStream;

  late final Stream<QuerySnapshot<Map<String, dynamic>>> _emergencyStream;

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

    _emergencyStream = _emergencyStore.getRequests();
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

    // Sort newest requests first.

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
        // Hide internal database fields.

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

      case 'location':
        return 'Pickup Location';

      case 'contact':
        return 'Contact Number';

      case 'details':
        return 'Emergency Details';

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

            if (groupName == 'Emergency Transport')
              const Padding(
                padding: EdgeInsets.only(top: 8),

                child: Text(
                  'Demo only. No ambulance or emergency '
                  'service has been contacted.',

                  style: TextStyle(color: Colors.red, fontSize: 12),
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

  Widget _buildRequests(
    Map<String, List<Map<String, String>>> groups, {
    required List<String> failedGroups,
    required bool isLoading,
  }) {
    final totalRequests = groups.values.fold<int>(
      0,
      (total, requests) => total + requests.length,
    );

    if (totalRequests == 0 && failedGroups.isEmpty && !isLoading) {
      return _buildEmptyState();
    }

    return ListView(
      padding: const EdgeInsets.all(16),

      children: [
        Text(
          isLoading || failedGroups.isNotEmpty
              ? 'Loaded Requests: $totalRequests'
              : 'Total Requests: $totalRequests',

          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 16),

        if (isLoading)
          const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: LinearProgressIndicator(),
          ),

        if (failedGroups.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),

            child: Text(
              'Unable to load: ${failedGroups.join(', ')}. '
              'Check your connection and Firebase permissions.',

              style: const TextStyle(color: Colors.red),
            ),
          ),

        for (final group in groups.entries)
          for (final request in group.value)
            _buildRequestCard(group.key, request),
      ],
    );
  }

  // ==========================================
  // COMBINE ALL FIVE FIREBASE COLLECTIONS
  // ==========================================

  Widget _buildCombinedRequests(
    Map<String, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>> snapshots,
  ) {
    final groups = <String, List<Map<String, String>>>{};

    final failedGroups = <String>[];

    bool isLoading = false;

    for (final entry in snapshots.entries) {
      final snapshot = entry.value;

      if (snapshot.hasError) {
        failedGroups.add(entry.key);

        final error = snapshot.error;

        if (error is FirebaseException) {
          debugPrint('${entry.key} Firestore error: ${error.code}');
        }

        continue;
      }

      if (!snapshot.hasData &&
          snapshot.connectionState == ConnectionState.waiting) {
        isLoading = true;
      }

      groups[entry.key] = _convertDocuments(snapshot.data);
    }

    return _buildRequests(
      groups,
      failedGroups: failedGroups,
      isLoading: isLoading,
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
          // PEDIATRIC MEDICINE STREAM

          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _medicineStream,

            builder: (context, medicineSnapshot) {
              // BABY EQUIPMENT RENTAL STREAM

              return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _rentalStream,

                builder: (context, rentalSnapshot) {
                  // PEDIATRICIAN APPOINTMENT STREAM

                  return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: _appointmentStream,

                    builder: (context, appointmentSnapshot) {
                      // EMERGENCY TRANSPORT STREAM

                      return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: _emergencyStream,

                        builder: (context, emergencySnapshot) {
                          return _buildCombinedRequests({
                            'Sick Child Care': childCareSnapshot,

                            'Pediatric Medicine': medicineSnapshot,

                            'Baby Equipment Rental': rentalSnapshot,

                            'Pediatrician Appointment': appointmentSnapshot,

                            'Emergency Transport': emergencySnapshot,
                          });
                        },
                      );
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
