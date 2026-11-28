import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PediatricMedicineRequestStore {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Connect to Firestore collection
  CollectionReference<Map<String, dynamic>> get _collection =>
      _db.collection('pediatric_medicine_requests');

  // Get logged-in user's UID
  String get _userId {
    final user = _auth.currentUser;

    if (user == null) {
      throw StateError('You must be logged in.');
    }

    return user.uid;
  }

  // Validate request details
  void _validateRequest({
    required String childName,
    required String medicine,
    required String notes,
  }) {
    if (childName.trim().isEmpty || childName.trim().length > 100) {
      throw ArgumentError('Invalid child name');
    }

    if (medicine.trim().isEmpty || medicine.trim().length > 200) {
      throw ArgumentError('Invalid medicine name');
    }

    if (notes.trim().length > 2000) {
      throw ArgumentError('Notes are too long');
    }
  }

  // CREATE MEDICINE REQUEST
  Future<String> addRequest({
    required String childName,
    required String medicine,
    required String notes,
  }) async {
    _validateRequest(childName: childName, medicine: medicine, notes: notes);

    final doc = await _collection.add({
      'userId': _userId,
      'childName': childName.trim(),
      'medicine': medicine.trim(),
      'notes': notes.trim(),
      'status': 'Pending',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return doc.id;
  }

  // READ MEDICINE REQUESTS
  Stream<QuerySnapshot<Map<String, dynamic>>> getRequests() {
    return _collection.where('userId', isEqualTo: _userId).snapshots();
  }

  // UPDATE MEDICINE REQUEST
  Future<void> updateRequest({
    required String requestId,
    required String childName,
    required String medicine,
    required String notes,
  }) async {
    _validateRequest(childName: childName, medicine: medicine, notes: notes);

    await _collection.doc(requestId).update({
      'childName': childName.trim(),
      'medicine': medicine.trim(),
      'notes': notes.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // DELETE MEDICINE REQUEST
  Future<void> deleteRequest(String requestId) async {
    await _collection.doc(requestId).delete();
  }
}
