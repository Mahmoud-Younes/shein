import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Model layer for authentication (Firebase Auth + a `users/{uid}` profile doc).
class AuthRepository {
  AuthRepository(this._auth);

  final FirebaseAuth _auth;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  /// Creates the Auth account and a matching Firestore profile document.
  Future<User> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user!;
    await user.updateDisplayName(name);
    // On web, updateProfile doesn't refresh the Dart-side user snapshot —
    // reload so the in-memory user (and the greeting in the header) carries
    // the new displayName immediately.
    await user.reload();
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'name': name,
      'email': email,
      'createdAtMs': DateTime.now().millisecondsSinceEpoch,
    });
    return _auth.currentUser!;
  }

  Future<User> signIn({required String email, required String password}) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user!;
  }

  Future<void> signOut() => _auth.signOut();
}
