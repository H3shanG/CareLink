import 'package:cloud_firestore/cloud_firestore.dart';

import '../../auth/services/auth_service.dart';

class OrganDonorRepository {
  final CollectionReference<Map<String, dynamic>> _col =
      FirebaseFirestore.instance.collection('organ_donors');

  // The signed-in user's own registration (null if not registered yet)
  Future<Map<String, dynamic>?> getMyRegistration() async {
    final uid = AuthService.currentUserId;
    if (uid == null) return null;

    final snap = await _col.doc(uid).get();
    return snap.data();
  }

  // Creates or updates the signed-in user's registration.
  // The document id is the userId, so each user has at most one.
  Future<void> saveMyRegistration({
    required String fullName,
    required int age,
    required String phone,
    required String address,
    required String gender,
    required List<String> organs,
    required bool consentGiven,
  }) async {
    final uid = AuthService.requireUserId();

    await _col.doc(uid).set({
      'userId': uid,
      'fullName': fullName,
      'age': age,
      'phone': phone,
      'address': address,
      'gender': gender,
      'organs': organs,
      'consentGiven': consentGiven,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Withdraw (delete) the signed-in user's registration
  Future<void> withdrawRegistration() {
    final uid = AuthService.requireUserId();
    return _col.doc(uid).delete();
  }
}