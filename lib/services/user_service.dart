import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Create anonymous user or register with email/password
  Future<UserCredential> signInOrRegister({
    required String email,
    String? password,
  }) async {
    if (email.isNotEmpty && password != null && password.isNotEmpty) {
      try {
        return await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          return await _auth.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
        }
        rethrow;
      }
    } else {
      // Fallback to anonymous sign in if no password provided (e.g. quick onboarding)
      return await _auth.signInAnonymously();
    }
  }

  /// Save user profile to Firestore `users/{uid}`
  Future<void> saveUserProfile(UserModel user) async {
    await _firestore.collection('users').doc(user.uid).set(
          user.toMap(),
          SetOptions(merge: true),
        );
  }

  /// Get user profile by UID
  Future<UserModel?> getUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists || doc.data() == null) return null;
    return UserModel.fromMap(doc.data()!, doc.id);
  }

  /// Stream of user profile
  Stream<UserModel?> streamUserProfile(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) return null;
      return UserModel.fromMap(snapshot.data()!, snapshot.id);
    });
  }

  /// Update individual fields
  Future<void> updateUserField(String uid, String field, dynamic value) async {
    await _firestore.collection('users').doc(uid).update({field: value});
  }

  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
