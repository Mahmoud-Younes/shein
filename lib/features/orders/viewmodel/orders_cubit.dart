import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../data/models/order_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/order_repository.dart';
import 'orders_state.dart';

/// ViewModel for "My Orders" — auth-driven Firestore subscription
/// (`orders` where uid == current user, newest first).
class OrdersCubit extends Cubit<OrdersState> {
  OrdersCubit(this._auth, this._orders) : super(const OrdersState()) {
    _authSubscription = _auth.authStateChanges.listen(_onUserChanged);
  }

  final AuthRepository _auth;
  final OrderRepository _orders;

  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<List<OrderModel>>? _ordersSubscription;

  void _onUserChanged(User? user) {
    // The auth stream can deliver one last event after close().
    if (isClosed) return;
    _ordersSubscription?.cancel();
    _ordersSubscription = null;
    if (user == null) {
      emit(const OrdersState());
      return;
    }
    emit(const OrdersState(status: OrdersStatus.loading));
    _ordersSubscription = _orders.watchOrders(user.uid).listen(
          (orders) {
            if (isClosed) return;
            emit(OrdersState(status: OrdersStatus.ready, orders: orders));
          },
          onError: (_) {
            if (isClosed) return;
            emit(const OrdersState(status: OrdersStatus.ready));
          },
        );
  }

  @override
  Future<void> close() async {
    await _authSubscription?.cancel();
    await _ordersSubscription?.cancel();
    return super.close();
  }
}
