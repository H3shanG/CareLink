import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'booking_model.dart';

class BookingRepository {
  final CollectionReference<Map<String, dynamic>> _col =
      FirebaseFirestore.instance.collection('bookings');

  // Saves the booking to Firestore and returns the new document id.
  Future<String> createBooking(Booking booking) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('You must be logged in to book');
    }

    final doc = await _col.add({
      'userId': user.uid,
      'bookingCode': booking.id,
      'caregiverId': booking.caregiver.id,
      'caregiverName': booking.caregiver.name,
      'caregiverRole': booking.caregiver.role,
      'service': booking.service,
      'date': Timestamp.fromDate(booking.date),
      'startMinutes':
          booking.startTime.hour * 60 + booking.startTime.minute,
      'endMinutes': booking.endTime.hour * 60 + booking.endTime.minute,
      'address': booking.address,
      'total': booking.total,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });

    return doc.id;
  }
}