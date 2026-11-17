import 'package:firebase_auth/firebase_auth.dart';

/// Maps Firebase exceptions to short, user-friendly English messages.
class FirebaseErrorMapper {
  static String auth(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password is too weak — use at least 6 characters.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Wrong email or password.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error — check your connection.';
      default:
        return 'Sign-in failed. Please try again.';
    }
  }

  static String firestore(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return 'You do not have permission for this action.';
      case 'unavailable':
        return 'Service unavailable — check your connection.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }

  /// Single entry point for any Firebase-related error object.
  static String message(Object error) {
    if (error is FirebaseAuthException) return auth(error);
    if (error is FirebaseException) return firestore(error);
    return 'Something went wrong. Please try again.';
  }
}
