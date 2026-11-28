import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmergencyTransportRequestStore {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Connect to the existing Firestore collection.

  CollectionReference<Map<String, dynamic>> get _collection =>
      _db.collection('emergency_transport_requests');

  // Get the currently logged-in user's UID.

  String get _userId {
    final user = _auth.currentUser;

    if (user == null) {
      throw StateError('You must be logged in.');
    }

    return user.uid;
  }

  // ==========================================
  // VALIDATE REQUEST DETAILS
  // ==========================================

  void _validateRequest({
    required String location,
    required String contact,
    required String details,
  }) {
    if (location.trim().isEmpty || location.trim().length > 500) {
      throw ArgumentError('Invalid pickup location.');
    }

    final phone = contact.trim();

    final validPhone = RegExp(r'^\+?[0-9][0-9\s-]*$').hasMatch(phone);

    final digitCount = phone.replaceAll(RegExp(r'[^0-9]'), '').length;

    if (!validPhone || digitCount < 7 || digitCount > 15 || phone.length > 30) {
      throw ArgumentError('Invalid contact number.');
    }

    if (details.trim().length > 2000) {
      throw ArgumentError('Emergency details are too long.');
    }
  }

  // ==========================================
  // CREATE A DEMO REQUEST
  // ==========================================

  Future<String> addRequest({
    required String location,
    required String contact,
    required String details,
  }) async {
    final userId = _userId;

    _validateRequest(location: location, contact: contact, details: details);

    final doc = await _collection.add({
      'userId': userId,
      'location': location.trim(),
      'contact': contact.trim(),
      'details': details.trim(),
      'status': 'Demo Only',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return doc.id;
  }

  // ==========================================
  // READ REQUEST HISTORY
  // ==========================================

  Stream<QuerySnapshot<Map<String, dynamic>>> getRequests() {
    return _collection.where('userId', isEqualTo: _userId).snapshots();
  }

  // ==========================================
  // UPDATE AN EXISTING REQUEST
  // ==========================================

  Future<void> updateRequest({
    required String requestId,
    required String location,
    required String contact,
    required String details,
  }) async {
    final userId = _userId;

    _validateRequest(location: location, contact: contact, details: details);

    final docRef = _collection.doc(requestId);

    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);

      final data = snapshot.data();

      if (!snapshot.exists || data == null || data['userId'] != userId) {
        throw StateError('Request not accessible.');
      }

      if (_userId != userId) {
        throw StateError('Logged-in user has changed.');
      }

      transaction.update(docRef, {
        'location': location.trim(),
        'contact': contact.trim(),
        'details': details.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  // ==========================================
  // DELETE AN EXISTING REQUEST
  // ==========================================

  Future<void> deleteRequest(String requestId) async {
    final userId = _userId;

    final docRef = _collection.doc(requestId);

    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);

      final data = snapshot.data();

      if (!snapshot.exists || data == null || data['userId'] != userId) {
        throw StateError('Request not accessible.');
      }

      if (_userId != userId) {
        throw StateError('Logged-in user has changed.');
      }

      transaction.delete(docRef);
    });
  }
}
