import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChildCareRequestStore {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Connect to the Firestore collection
  CollectionReference<Map<String, dynamic>> get _collection =>
      _db.collection('child_care_requests');

  // Get the current logged-in user's UID
  String get _userId {
    final user = _auth.currentUser;

    if (user == null) {
      throw StateError('You must be logged in.');
    }

    return user.uid;
  }

  // CREATE REQUEST
  Future<String> addRequest({
    required String name,
    required int age,
    required String symptoms,
  }) async {
    if (name.trim().isEmpty || name.trim().length > 100) {
      throw ArgumentError('Invalid child name');
    }

    if (age < 0 || age > 17) {
      throw ArgumentError('Invalid child age');
    }

    if (symptoms.trim().isEmpty || symptoms.trim().length > 2000) {
      throw ArgumentError('Invalid health concern');
    }

    final doc = await _collection.add({
      'userId': _userId,
      'name': name.trim(),
      'age': age,
      'symptoms': symptoms.trim(),
      'status': 'Pending',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return doc.id;
  }

  // READ REQUESTS
  Stream<QuerySnapshot<Map<String, dynamic>>> getRequests() {
    return _collection.where('userId', isEqualTo: _userId).snapshots();
  }

  // UPDATE REQUEST STATUS
  Future<void> updateStatus({
    required String requestId,
    required String status,
  }) async {
    const allowedStatuses = ['Pending', 'In Progress', 'Completed'];

    if (!allowedStatuses.contains(status)) {
      throw ArgumentError('Invalid request status');
    }

    await _collection.doc(requestId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // DELETE REQUEST
  Future<void> deleteRequest(String requestId) async {
    await _collection.doc(requestId).delete();
  }
}
