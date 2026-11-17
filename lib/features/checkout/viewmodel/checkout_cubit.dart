import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/firebase_error_mapper.dart';
import '../../../data/models/cart_item_model.dart';
import '../../../data/models/order_model.dart';
import '../../../data/repositories/order_repository.dart';
import 'checkout_state.dart';

/// ViewModel for checkout: writes the order document and clears the cart.
class CheckoutCubit extends Cubit<CheckoutState> {
  CheckoutCubit(this._orders) : super(const CheckoutState());

  final OrderRepository _orders;

  Future<void> placeOrder({
    required String uid,
    required List<CartItemModel> items,
    required AddressModel address,
  }) async {
    emit(const CheckoutState(status: CheckoutStatus.submitting));
    try {
      final orderId =
          await _orders.placeOrder(uid: uid, items: items, address: address);
      // The cubit can be closed while awaiting (user navigated away).
      if (isClosed) return;
      emit(CheckoutState(status: CheckoutStatus.placed, placedOrderId: orderId));
    } catch (e) {
      if (isClosed) return;
      emit(CheckoutState(
        status: CheckoutStatus.error,
        error: FirebaseErrorMapper.message(e),
      ));
    }
  }

  void reset() => emit(const CheckoutState());
}
