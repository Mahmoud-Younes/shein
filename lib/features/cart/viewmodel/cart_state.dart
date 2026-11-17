import 'package:equatable/equatable.dart';

import '../../../data/models/cart_item_model.dart';
import '../../../data/models/order_model.dart';

enum CartStatus { guest, loading, ready }

class CartState extends Equatable {
  const CartState({this.status = CartStatus.guest, this.items = const []});

  final CartStatus status;
  final List<CartItemModel> items;

  bool get isGuest => status == CartStatus.guest;
  bool get isLoading => status == CartStatus.loading;
  bool get isEmpty => status == CartStatus.ready && items.isEmpty;

  int get itemCount => CartTotals.itemCount(items);
  double get subtotal => CartTotals.subtotal(items);
  double get shipping => CartTotals.shippingFor(subtotal);
  double get total => CartTotals.totalOf(subtotal, shipping);

  CartItemModel? itemFor(String productId, String size) {
    for (final item in items) {
      if (item.productId == productId && item.size == size) return item;
    }
    return null;
  }

  @override
  List<Object?> get props => [status, items];
}
