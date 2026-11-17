import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../data/models/product_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/wishlist_repository.dart';
import 'wishlist_state.dart';

/// ViewModel for the wishlist — same lifecycle pattern as [CartCubit]:
/// auth-driven Firestore subscription (`wishlists/{uid}/items`).
class WishlistCubit extends Cubit<WishlistState> {
  WishlistCubit(this._auth, this._wishlist) : super(const WishlistState()) {
    _authSubscription = _auth.authStateChanges.listen(_onUserChanged);
  }

  final AuthRepository _auth;
  final WishlistRepository _wishlist;

  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<List<WishlistItemModel>>? _itemsSubscription;
  String? _uid;

  void _onUserChanged(User? user) {
    // The auth stream can deliver one last event after close().
    if (isClosed) return;
    _itemsSubscription?.cancel();
    _itemsSubscription = null;
    if (user == null) {
      _uid = null;
      emit(const WishlistState());
      return;
    }
    _uid = user.uid;
    emit(const WishlistState(status: WishlistStatus.loading));
    _itemsSubscription = _wishlist.watchItems(user.uid).listen(
          (items) {
            if (isClosed) return;
            emit(WishlistState(status: WishlistStatus.ready, items: items));
          },
          onError: (_) {
            if (isClosed) return;
            emit(const WishlistState(status: WishlistStatus.ready));
          },
        );
  }

  /// Adds/removes [product]; returns true when it was added (for feedback).
  Future<bool> toggle(ProductModel product) async {
    final uid = _requireUid();
    return _wishlist.toggle(uid, product);
  }

  Future<void> remove(String productId) async {
    await _wishlist.remove(_requireUid(), productId);
  }

  String _requireUid() {
    final uid = _uid;
    if (uid == null) {
      throw Exception('Please sign in to use your wishlist.');
    }
    return uid;
  }

  @override
  Future<void> close() async {
    await _authSubscription?.cancel();
    await _itemsSubscription?.cancel();
    return super.close();
  }
}
