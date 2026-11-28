import 'package:cloud_firestore/cloud_firestore.dart';

import '../../auth/services/auth_service.dart';
import '../models/blood_request.dart';

class BloodRequestRepository {
  final CollectionReference<Map<String, dynamic>> _col =
      FirebaseFirestore.instance.collection('blood_requests');

  // Live list of all blood requests (newest first)
  Stream<List<BloodRequest>> watchRequests() {
    return _col
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(BloodRequest.fromDoc).toList());
  }

  // Only the signed-in user's own requests
  Stream<List<BloodRequest>> watchMyRequests() {
    final uid = AuthService.requireUserId();
    return _col
        .where('userId', isEqualTo: uid)
        .snapshots()
        .map((snap) => snap.docs.map(BloodRequest.fromDoc).toList());
  }

  // Creates a new blood request. userId is added here, not by the UI.
  Future<void> createRequest(BloodRequest request) async {
    final uid = AuthService.requireUserId();

    await _col.add({
      ...request.toMap(),
      'userId': uid,
    });
  }

  // Change status: 'open' | 'fulfilled' | 'cancelled'
  Future<void> updateStatus(String requestId, String status) {
    return _col.doc(requestId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}