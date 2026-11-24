import 'package:flutter/material.dart';
import '../../caregiver/data/caregiver_model.dart';

class Booking {
  // Firestore document id. Empty until the booking is saved.
  final String docId;
  final String id;
  final Caregiver caregiver;
  final String service;
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String address;
  final int total;
  final String status;

  const Booking({
    this.docId = '',
    required this.id,
    required this.caregiver,
    required this.service,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.address,
    required this.total,
    this.status = 'pending',
  });

  Booking copyWith({String? docId, String? status}) {
    return Booking(
      docId: docId ?? this.docId,
      id: id,
      caregiver: caregiver,
      service: service,
      date: date,
      startTime: startTime,
      endTime: endTime,
      address: address,
      total: total,
      status: status ?? this.status,
    );
  }
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
  final suffix = (DateTime.now().millisecondsSinceEpoch % 10000)
      .toString()
      .padLeft(4, '0');
  return 'CLB-${d.year}$m$day-$suffix';
}