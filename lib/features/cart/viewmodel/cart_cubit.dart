import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../data/models/cart_item_model.dart';
import '../../../data/models/product_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/cart_repository.dart';
import 'cart_state.dart';

/// ViewModel for the shopping bag. Subscribes to auth changes itself and
/// streams the Firestore cart for the signed-in user — no widget wiring needed.
class CartCubit extends Cubit<CartState> {
  CartCubit(this._auth, this._cart) : super(const CartState()) {
    _authSubscription = _auth.authStateChanges.listen(_onUserChanged);
  }

  final AuthRepository _auth;
  final CartRepository _cart;

  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<List<CartItemModel>>? _cartSubscription;
  String? _uid;

  void _onUserChanged(User? user) {
    // The auth stream can deliver one last event after close().
    if (isClosed) return;
    _cartSubscription?.cancel();
    _cartSubscription = null;
    if (user == null) {
      _uid = null;
      emit(const CartState());
      return;
    }
    _uid = user.uid;
    emit(const CartState(status: CartStatus.loading));
    _cartSubscription = _cart.watchItems(user.uid).listen(
          (items) {
            if (isClosed) return;
            emit(CartState(status: CartStatus.ready, items: items));
          },
          onError: (_) {
            if (isClosed) return;
            emit(const CartState(status: CartStatus.ready));
          },
        );
  }

  /// Adds [qty] units of [product] with the chosen [size] and [color].
  /// Throws a friendly [Exception] message on failure (view shows a snackbar).
  Future<void> addToCart(
    ProductModel product, {
    required String size,
    required String color,
    int qty = 1,
  }) async {
    final uid = _requireUid();
    await _cart.add(
      uid,
      CartItemModel(
        productId: product.id,
        size: size,
        color: color,
        title: product.title,
        image: product.mainImage,
        price: product.price,
        qty: qty,
      ),
    );
  }

  Future<void> updateQty(String docId, int qty) async {
    await _cart.updateQty(_requireUid(), docId, qty);
  }

  Future<void> remove(String docId) async {
    await _cart.remove(_requireUid(), docId);
  }

  Future<void> clear() async {
    await _cart.clear(_requireUid());
  }

  String _requireUid() {
    final uid = _uid;
    if (uid == null) {
      throw Exception('Please sign in to use your bag.');
    }
    return uid;
  }

  @override
  Future<void> close() async {
    await _authSubscription?.cancel();
    await _cartSubscription?.cancel();
    return super.close();
  }
}
