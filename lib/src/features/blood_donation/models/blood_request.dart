import 'package:cloud_firestore/cloud_firestore.dart';

enum Urgency { normal, urgent, critical }

extension UrgencyLabel on Urgency {
  String get label {
    switch (this) {
      case Urgency.normal:
        return 'Normal';
      case Urgency.urgent:
        return 'Urgent';
      case Urgency.critical:
        return 'Critical';
    }
  }
}

class BloodRequest {
  final String? id;
  final String? userId; // repository එක විසින් දානවා
  final String patientName;
  final String bloodGroup;
  final int units;
  final String hospital;
  final Urgency urgency;
  final DateTime neededBy;
  final String contactNumber;
  final String? note;
  final String status; // 'open' | 'fulfilled' | 'cancelled'
  final DateTime? createdAt;

  const BloodRequest({
    this.id,
    this.userId,
    required this.patientName,
    required this.bloodGroup,
    required this.units,
    required this.hospital,
    required this.urgency,
    required this.neededBy,
    required this.contactNumber,
    this.note,
    this.status = 'open',
    this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'patientName': patientName,
        'bloodGroup': bloodGroup,
        'units': units,
        'hospital': hospital,
        'urgency': urgency.name,
        'neededBy': Timestamp.fromDate(neededBy),
        'contactNumber': contactNumber,
        'note': note,
        'status': status,
        'createdAt': FieldValue.serverTimestamp(),
      };

  factory BloodRequest.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return BloodRequest(
      id: doc.id,
      userId: d['userId'] as String?,
      patientName: d['patientName'] as String? ?? '',
      bloodGroup: d['bloodGroup'] as String? ?? '',
      units: (d['units'] as num?)?.toInt() ?? 1,
      hospital: d['hospital'] as String? ?? '',
      urgency: Urgency.values.firstWhere(
        (u) => u.name == d['urgency'],
        orElse: () => Urgency.normal,
      ),
      neededBy: (d['neededBy'] as Timestamp).toDate(),
      contactNumber: d['contactNumber'] as String? ?? '',
      note: d['note'] as String?,
      status: d['status'] as String? ?? 'open',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}