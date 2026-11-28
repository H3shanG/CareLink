import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BabyHealthRecordStore {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _db.collection('baby_health_records');

  // GET LOGGED-IN USER ID

  String get _userId {
    final user = _auth.currentUser;

    if (user == null) {
      throw StateError('You must be logged in.');
    }

    return user.uid;
  }

  // ==========================================
  // CREATE BABY HEALTH RECORD
  // ==========================================

  Future<String> addRecord({
    required String name,
    required DateTime dob,
    required String bloodGroup,
    required double weight,
    required double height,
  }) async {
    final doc = await _collection.add({
      'userId': _userId,
      'name': name.trim(),
      'dob': Timestamp.fromDate(dob),
      'bloodGroup': bloodGroup,
      'weight': weight,
      'height': height,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return doc.id;
  }

  // ==========================================
  // READ BABY HEALTH RECORDS
  // ==========================================

  Stream<QuerySnapshot<Map<String, dynamic>>> getRecords() {
    return _collection.where('userId', isEqualTo: _userId).snapshots();
  }

  // ==========================================
  // UPDATE BABY HEALTH RECORD
  // ==========================================

  Future<void> updateRecord({
    required String recordId,
    required String name,
    required DateTime dob,
    required String bloodGroup,
    required double weight,
    required double height,
  }) async {
    await _collection.doc(recordId).update({
      'name': name.trim(),
      'dob': Timestamp.fromDate(dob),
      'bloodGroup': bloodGroup,
      'weight': weight,
      'height': height,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ==========================================
  // DELETE BABY HEALTH RECORD
  // ==========================================

  Future<void> deleteRecord(String recordId) async {
    await _collection.doc(recordId).delete();
  }
}
