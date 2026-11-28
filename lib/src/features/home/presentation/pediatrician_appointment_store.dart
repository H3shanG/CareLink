import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PediatricianAppointmentStore {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Connect to pediatricians collection
  CollectionReference<Map<String, dynamic>> get _pediatricians =>
      _db.collection('pediatricians');

  // Connect to appointments collection
  CollectionReference<Map<String, dynamic>> get _appointments =>
      _db.collection('pediatrician_appointments');

  // Get logged-in user's UID
  String get _userId {
    final user = _auth.currentUser;

    if (user == null) {
      throw StateError('You must be logged in.');
    }

    return user.uid;
  }

  // ==========================================
  // READ PEDIATRICIAN DIRECTORY
  // ==========================================

  Stream<QuerySnapshot<Map<String, dynamic>>> getPediatricians() {
    return _pediatricians
        .where('isActive', isEqualTo: true)
        .where('isDemo', isEqualTo: true)
        .snapshots();
  }

  // ==========================================
  // VALIDATE APPOINTMENT DETAILS
  // ==========================================

  void _validateAppointment({
    required String childName,
    required DateTime appointmentAt,
  }) {
    if (childName.trim().isEmpty || childName.trim().length > 100) {
      throw ArgumentError('Invalid child name');
    }

    final now = DateTime.now();

    if (!appointmentAt.isAfter(now)) {
      throw ArgumentError('Appointment must be in the future');
    }

    if (appointmentAt.isAfter(now.add(const Duration(days: 365)))) {
      throw ArgumentError('Appointment must be within one year');
    }
  }

  // ==========================================
  // CREATE APPOINTMENT REQUEST
  // ==========================================

  Future<String> addAppointment({
    required String doctorId,
    required String childName,
    required DateTime appointmentAt,
  }) async {
    final userId = _userId;

    _validateAppointment(childName: childName, appointmentAt: appointmentAt);

    if (doctorId.trim().isEmpty) {
      throw ArgumentError('Invalid doctor ID');
    }

    // Retrieve doctor details from Firestore
    final doctorDoc = await _pediatricians.doc(doctorId).get();

    final doctorData = doctorDoc.data();

    if (!doctorDoc.exists ||
        doctorData == null ||
        doctorData['isActive'] != true ||
        doctorData['isDemo'] != true) {
      throw StateError('Selected pediatrician is unavailable.');
    }

    final doctorName = doctorData['name'];

    if (doctorName is! String || doctorName.trim().isEmpty) {
      throw StateError('Invalid pediatrician profile.');
    }

    if (_userId != userId) {
      throw StateError('Logged-in user has changed.');
    }

    final doc = await _appointments.add({
      'userId': userId,
      'doctorId': doctorId,
      'doctor': doctorName.trim(),
      'childName': childName.trim(),
      'appointmentAt': Timestamp.fromDate(appointmentAt),
      'status': 'Pending',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return doc.id;
  }

  // ==========================================
  // READ USER'S APPOINTMENTS
  // ==========================================

  Stream<QuerySnapshot<Map<String, dynamic>>> getAppointments() {
    return _appointments.where('userId', isEqualTo: _userId).snapshots();
  }

  // ==========================================
  // UPDATE APPOINTMENT REQUEST
  // ==========================================

  Future<void> updateAppointment({
    required String appointmentId,
    required String childName,
    required DateTime appointmentAt,
  }) async {
    final userId = _userId;

    _validateAppointment(childName: childName, appointmentAt: appointmentAt);

    final docRef = _appointments.doc(appointmentId);

    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      final data = snapshot.data();

      if (!snapshot.exists || data == null || data['userId'] != userId) {
        throw StateError('Appointment not accessible.');
      }

      if (_userId != userId) {
        throw StateError('Logged-in user has changed.');
      }

      transaction.update(docRef, {
        'childName': childName.trim(),
        'appointmentAt': Timestamp.fromDate(appointmentAt),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  // ==========================================
  // DELETE APPOINTMENT REQUEST
  // ==========================================

  Future<void> deleteAppointment(String appointmentId) async {
    final userId = _userId;

    final docRef = _appointments.doc(appointmentId);

    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      final data = snapshot.data();

      if (!snapshot.exists || data == null || data['userId'] != userId) {
        throw StateError('Appointment not accessible.');
      }

      if (_userId != userId) {
        throw StateError('Logged-in user has changed.');
      }

      transaction.delete(docRef);
    });
  }
}
