import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> login({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await _db.collection('users').doc(cred.user!.uid).set({
      'name': name,
      'email': email,
      'phone': phone,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> sendPasswordReset(String email) {
    return _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> logout() => _auth.signOut();

  // Current signed-in user (null if nobody is signed in)
  static User? get currentUser => FirebaseAuth.instance.currentUser;

  // Current user's uid (null if nobody is signed in)
  static String? get currentUserId => FirebaseAuth.instance.currentUser?.uid;

  // Use this when a screen requires a signed-in user
  static String requireUserId() {
    final uid = currentUserId;
    if (uid == null) {
      throw StateError('No signed-in user');
    }
    return uid;
  }

  // Emits a value whenever the user signs in or out
  static Stream<User?> get authStateChanges =>
      FirebaseAuth.instance.authStateChanges();

  // Reads the profile document from the users collection
  Future<Map<String, dynamic>?> getUserProfile() async {
    final uid = currentUserId;
    if (uid == null) return null;
    final snap = await _db.collection('users').doc(uid).get();
    return snap.data();
  }

  // Updates profile fields (creates the document if it does not exist)
  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    final uid = requireUserId();
    await _db.collection('users').doc(uid).set(data, SetOptions(merge: true));
  }

  static String messageFromCode(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Please enter a valid email address';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      case 'network-request-failed':
        return 'No internet connection';
      case 'email-already-in-use':
        return 'An account already exists for this email';
      case 'weak-password':
        return 'Password is too weak';
      default:
        return 'Something went wrong. Please try again';
    }
  }
}