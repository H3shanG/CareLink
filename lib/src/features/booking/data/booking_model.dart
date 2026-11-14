import 'package:flutter/material.dart';
import '../../caregiver/data/caregiver_model.dart';

class Booking {
  final String id;
  final Caregiver caregiver;
  final String service;
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String address;
  final int total;

  const Booking({
    required this.id,
    required this.caregiver,
    required this.service,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.address,
    required this.total,
  });
}

String formatDate(DateTime d) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  return '${d.day} ${months[d.month - 1]} ${d.year}';
}

String makeBookingId(DateTime d) {
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return 'CLB-${d.year}$m$day-001';
}