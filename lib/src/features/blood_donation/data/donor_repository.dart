import 'package:cloud_firestore/cloud_firestore.dart';

import '../../auth/services/auth_service.dart';
import '../models/donor.dart';

class DonorRepository {
  final CollectionReference<Map<String, dynamic>> _col =
      FirebaseFirestore.instance.collection('donors');

  // Live list of all donors
  Stream<List<Donor>> watchDonors() {
    return _col.snapshots().map(
          (snap) =>
              snap.docs.map((d) => Donor.fromMap(d.id, d.data())).toList(),
        );
  }

  // The signed-in user's own donor profile (null if not registered yet)
  Future<Donor?> getMyDonorProfile() async {
    final uid = AuthService.currentUserId;
    if (uid == null) return null;

    final snap = await _col.doc(uid).get();
    final data = snap.data();
    if (data == null) return null;
    return Donor.fromMap(snap.id, data);
  }

  // Creates or updates the signed-in user's donor profile.
  // The document id is the userId, so each user has at most one profile.
  Future<void> saveMyDonorProfile({
    required String name,
    required String bloodGroup,
    required String phone,
    String area = '',
    required bool isAvailable,
    double? latitude,
    double? longitude,
  }) async {
    final uid = AuthService.requireUserId();

    await _col.doc(uid).set({
      'userId': uid,
      'name': name,
      'bloodGroup': bloodGroup,
      'phone': phone,
      'area': area,
      'isAvailable': isAvailable,
      'latitude': latitude,
      'longitude': longitude,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Quick on/off switch for "I am available to donate"
  Future<void> setAvailability(bool isAvailable) {
    final uid = AuthService.requireUserId();
    return _col.doc(uid).update({
      'isAvailable': isAvailable,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}