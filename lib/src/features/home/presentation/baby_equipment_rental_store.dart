import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BabyEquipmentRentalStore {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Available equipment types
  static const List<String> equipmentList = [
    'Baby Stroller',
    'Baby Crib',
    'Baby Car Seat',
    'Baby Walker',
    'Baby High Chair',
    'Baby Carrier',
  ];

  // Connect to Firestore collection
  CollectionReference<Map<String, dynamic>> get _collection =>
      _db.collection('baby_equipment_rentals');

  // Get logged-in user's UID
  String get _userId {
    final user = _auth.currentUser;

    if (user == null) {
      throw StateError('You must be logged in.');
    }

    return user.uid;
  }

  // Validate rental request details
  void _validateRental({
    required String equipment,
    required int duration,
    required String address,
  }) {
    if (!equipmentList.contains(equipment)) {
      throw ArgumentError('Invalid equipment type');
    }

    if (duration <= 0) {
      throw ArgumentError('Invalid rental duration');
    }

    if (address.trim().isEmpty || address.trim().length > 500) {
      throw ArgumentError('Invalid delivery address');
    }
  }

  // ==========================================
  // CREATE RENTAL REQUEST
  // ==========================================

  Future<String> addRental({
    required String equipment,
    required int duration,
    required String address,
  }) async {
    _validateRental(equipment: equipment, duration: duration, address: address);

    final doc = await _collection.add({
      'userId': _userId,
      'equipment': equipment,
      'duration': duration,
      'address': address.trim(),
      'status': 'Pending',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return doc.id;
  }

  // ==========================================
  // READ RENTAL REQUESTS
  // ==========================================

  Stream<QuerySnapshot<Map<String, dynamic>>> getRentals() {
    return _collection.where('userId', isEqualTo: _userId).snapshots();
  }

  // ==========================================
  // UPDATE RENTAL REQUEST
  // ==========================================

  Future<void> updateRental({
    required String requestId,
    required String equipment,
    required int duration,
    required String address,
  }) async {
    _validateRental(equipment: equipment, duration: duration, address: address);

    await _collection.doc(requestId).update({
      'equipment': equipment,
      'duration': duration,
      'address': address.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ==========================================
  // DELETE RENTAL REQUEST
  // ==========================================

  Future<void> deleteRental(String requestId) async {
    await _collection.doc(requestId).delete();
  }
}
