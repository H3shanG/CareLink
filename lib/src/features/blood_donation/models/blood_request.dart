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
  final String patientName;
  final String bloodGroup;
  final int units;
  final String hospital;
  final Urgency urgency;
  final DateTime neededBy;
  final String contactNumber;
  final String? note;

  const BloodRequest({
    required this.patientName,
    required this.bloodGroup,
    required this.units,
    required this.hospital,
    required this.urgency,
    required this.neededBy,
    required this.contactNumber,
    this.note,
  });

  Map<String, dynamic> toMap() => {
        'patientName': patientName,
        'bloodGroup': bloodGroup,
        'units': units,
        'hospital': hospital,
        'urgency': urgency.name,
        'neededBy': neededBy.toIso8601String(),
        'contactNumber': contactNumber,
        'note': note,
      };
}