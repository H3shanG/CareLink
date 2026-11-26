import 'package:flutter/material.dart';

import 'child_care_request_store.dart';
import 'baby_equipment_rental_store.dart';
import 'pediatric_medicine_request_store.dart';
import 'pediatrician_appointment_store.dart';
import 'emergency_transport_request_store.dart';

class ChildMyRequestsScreen extends StatefulWidget {
  const ChildMyRequestsScreen({super.key});

  @override
  State<ChildMyRequestsScreen> createState() =>
      _ChildMyRequestsScreenState();
}

class _ChildMyRequestsScreenState
    extends State<ChildMyRequestsScreen> {

  @override
  Widget build(BuildContext context) {
    final groups = {
      'Sick Child Care':
          ChildCareRequestStore.requests,
      'Pediatric Medicine':
          PediatricMedicineRequestStore.requests,
      'Baby Equipment Rental':
          BabyEquipmentRentalStore.requests,
      'Pediatrician Appointment':
          PediatricianAppointmentStore.appointments,
      'Emergency Transport':
          EmergencyTransportRequestStore.requests,
    };

    final totalRequests = groups.values.fold<int>(
      0,
      (total, requests) => total + requests.length,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppBar(
        title: const Text('My Requests'),
        backgroundColor: Colors.white,
      ),
      body: totalRequests == 0
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.assignment_outlined,
                    size: 70,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No Requests Yet',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text('Your child care requests will appear here.'),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Total Requests: $totalRequests',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                for (final group in groups.entries)
                  for (final request in group.value.reversed)
                    Card(
                      color: Colors.white,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              group.key,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(height: 12),

                            for (final entry in request.entries)
                              Padding(
                                padding:
                                    const EdgeInsets.only(bottom: 6),
                                child: Text(
                                  '${entry.key}: ${entry.value}',
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
              ],
            ),
    );
  }
}