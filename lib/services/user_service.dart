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
    if (user.email.isNotEmpty) {
      await checkAndApplyPendingRole(user.email, user.uid);
    }
  }

  /// Get user profile by UID
  Future<UserModel?> getUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists || doc.data() == null) return null;
    final user = UserModel.fromMap(doc.data()!, doc.id);
    if (user.email.isNotEmpty && user.role == 'user') {
      await checkAndApplyPendingRole(user.email, user.uid);
    }
    return user;
  }

  /// Check and apply any pending role assignment for this user's email (Path A)
  Future<void> checkAndApplyPendingRole(String email, String uid) async {
    if (email.isEmpty) return;
    try {
      final key = email.toLowerCase().trim();
      final pendingDoc = await _firestore.collection('pending_role_assignments').doc(key).get();
      if (pendingDoc.exists && pendingDoc.data() != null) {
        final data = pendingDoc.data()!;
        final role = data['role'] as String? ?? 'scholar';
        final venueId = data['venueId'] as String?;
        await _firestore.collection('users').doc(uid).update({
          'role': role,
          'venueId': ?venueId,
          'can_upload_reel': true,
        });
        // Remove pending assignment once claimed
        await _firestore.collection('pending_role_assignments').doc(key).delete();
      }
    } catch (_) {}
  }

  /// Assign role directly (for Superadmin Path A)
  Future<bool> assignUserRole({
    required String emailOrUid,
    required String role,
    String? venueId,
    required String adminUid,
  }) async {
    final query = emailOrUid.trim();
    final isEmail = query.contains('@');

    if (isEmail) {
      final emailKey = query.toLowerCase();
      // Check if user already exists
      final userSnap = await _firestore
          .collection('users')
          .where('email', isEqualTo: emailKey)
          .limit(1)
          .get();

      if (userSnap.docs.isNotEmpty) {
        final targetUid = userSnap.docs.first.id;
        await _firestore.collection('users').doc(targetUid).update({
          'role': role,
          'venueId': ?venueId,
          'can_upload_reel': true,
        });
        return true; // Applied immediately
      } else {
        // Store as pending role assignment
        await _firestore.collection('pending_role_assignments').doc(emailKey).set({
          'email': emailKey,
          'role': role,
          'venueId': venueId,
          'assigned_by': adminUid,
          'assigned_at': FieldValue.serverTimestamp(),
        });
        return false; // Stored as pending
      }
    } else {
      // By UID
      await _firestore.collection('users').doc(query).update({
        'role': role,
        'venueId': ?venueId,
        'can_upload_reel': true,
      });
      return true;
    }
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
