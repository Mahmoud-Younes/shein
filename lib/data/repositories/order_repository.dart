import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/cart_item_model.dart';
import '../models/order_model.dart';

/// Model layer for orders: `orders/{autoId}` (one document per order,
/// queried by `uid`), plus cart clearing as part of the checkout transaction.
class OrderRepository {
  OrderRepository(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _orders =>
      _db.collection('orders');

  /// Places an order from the given cart items, then empties the cart.
  /// Pricing is recomputed server-side-of-the-client (from the cart items)
  /// inside [OrderRepository] so the UI cannot inflate totals.
  Future<String> placeOrder({
    required String uid,
    required List<CartItemModel> items,
    required AddressModel address,
  }) async {
    final subtotal = CartTotals.subtotal(items);
    final shipping = CartTotals.shippingFor(subtotal);
    final order = OrderModel(
      id: '',
      uid: uid,
      items: items,
      address: address,
      subtotal: subtotal,
      shippingFee: shipping,
      total: CartTotals.totalOf(subtotal, shipping),
      status: 'Placed',
      createdAtMs: DateTime.now().millisecondsSinceEpoch,
    );

    final docRef = await _orders.add(order.toMap());
    // Clear the user's cart after the order document is written.
    final cartSnapshot =
        await _db.collection('carts').doc(uid).collection('items').get();
    final batch = _db.batch();
    for (final doc in cartSnapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
    return docRef.id;
  }

  /// Live orders stream for one user, newest first (sorted client-side to
  /// avoid a Firestore composite index).
  Stream<List<OrderModel>> watchOrders(String uid) => _orders
      .where('uid', isEqualTo: uid)
      .snapshots()
      .map((s) {
        final orders = s.docs
            .map((d) => OrderModel.fromMap(d.id, d.data()))
            .toList();
        orders.sort((a, b) => b.createdAtMs.compareTo(a.createdAtMs));
        return orders;
      });
}
