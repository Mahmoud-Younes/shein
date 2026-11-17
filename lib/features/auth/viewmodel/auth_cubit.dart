import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/utils/firebase_error_mapper.dart';
import '../../../data/repositories/auth_repository.dart';
import 'auth_state.dart';

/// ViewModel for authentication. Owns the global auth lifecycle: it mirrors
/// [FirebaseAuth.authStateChanges] into [AuthState] so the whole app
/// (header, cart, wishlist) reacts to sign-in / sign-out.
class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repo) : super(const AuthState()) {
    _subscription = _repo.authStateChanges.listen((user) {
      // The auth stream can deliver one last event after close().
      if (isClosed) return;
      // Right after sign-up the stream can still deliver a snapshot taken
      // before updateDisplayName — prefer the repo's fresher currentUser.
      User? effective = user;
      if (user != null && user.displayName == null) {
        final fresh = _repo.currentUser;
        if (fresh?.displayName != null) effective = fresh;
      }
      emit(AuthState(
        status: effective == null
            ? AuthStatus.unauthenticated
            : AuthStatus.authenticated,
        user: effective,
      ));
    });
  }

  final AuthRepository _repo;
  late final StreamSubscription<User?> _subscription;

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    _setBusy();
    try {
      final user = await _repo.signUp(name: name, email: email, password: password);
      // updateDisplayName doesn't re-emit authStateChanges on web, so the
      // stream may still hold the pre-profile user (displayName null → the
      // header greets by email). Emit the refreshed user directly.
      if (isClosed) return;
      emit(AuthState(status: AuthStatus.authenticated, user: user));
    } on FirebaseAuthException catch (e) {
      _emitError(FirebaseErrorMapper.auth(e));
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    _setBusy();
    try {
      await _repo.signIn(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      _emitError(FirebaseErrorMapper.auth(e));
    }
  }

  Future<void> signOut() async {
    try {
      await _repo.signOut();
    } on FirebaseAuthException catch (e) {
      _emitError(FirebaseErrorMapper.auth(e));
    }
  }

  void clearError() => emit(state.copyWith(clearError: true));

  void _setBusy() => emit(state.copyWith(busy: true, clearError: true));

  void _emitError(String message) =>
      emit(state.copyWith(busy: false, error: message));

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
