import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:shein/core/utils/firebase_error_mapper.dart';

void main() {
  group('FirebaseErrorMapper.message', () {
    test('maps common auth codes to friendly text', () {
      expect(
        FirebaseErrorMapper.message(FirebaseAuthException(code: 'email-already-in-use')),
        contains('already exists'),
      );
      expect(
        FirebaseErrorMapper.message(FirebaseAuthException(code: 'invalid-credential')),
        contains('Wrong email or password'),
      );
      expect(
        FirebaseErrorMapper.message(FirebaseAuthException(code: 'weak-password')),
        contains('at least 6 characters'),
      );
      expect(
        FirebaseErrorMapper.message(FirebaseAuthException(code: 'too-many-requests')),
        contains('Too many attempts'),
      );
    });

    test('maps firestore codes', () {
      expect(
        FirebaseErrorMapper.message(FirebaseException(plugin: 'firestore', code: 'permission-denied')),
        contains('permission'),
      );
      expect(
        FirebaseErrorMapper.message(FirebaseException(plugin: 'firestore', code: 'unavailable')),
        contains('connection'),
      );
    });

    test('falls back to generic message for unknown errors', () {
      expect(
        FirebaseErrorMapper.message(StateError('boom')),
        'Something went wrong. Please try again.',
      );
    });
  });
}
