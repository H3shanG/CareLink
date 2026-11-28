import 'package:cloud_firestore/cloud_firestore.dart';

import '../../auth/services/auth_service.dart';

class EquipmentRentalRepository {
  final CollectionReference<Map<String, dynamic>> _col =
      FirebaseFirestore.instance.collection('equipment_rentals');

  // Creates a rental request for the signed-in user
  Future<void> createRental({
    required String equipment,
    required String price,
    required int duration,
    required String address,
    required String phone,
  }) async {
    final uid = AuthService.requireUserId();

    await _col.add({
      'userId': uid,
      'equipment': equipment,
      'price': price,
      'duration': duration,
      'address': address,
      'phone': phone,
      'status': 'Pending',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Only the signed-in user's own rentals (newest first is sorted in the UI)
  Stream<List<Map<String, dynamic>>> watchMyRentals() {
    final uid = AuthService.requireUserId();
    return _col
        .where('userId', isEqualTo: uid)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }

  Future<void> cancelRental(String rentalId) {
    return _col.doc(rentalId).update({
      'status': 'Cancelled',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}