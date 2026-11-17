import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/cart_item_model.dart';

/// Model layer for the per-user cart in Firestore:
/// `carts/{uid}/items/{productId__size}`.
class CartRepository {
  CartRepository(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _items(String uid) =>
      _db.collection('carts').doc(uid).collection('items');

  /// Real-time cart stream — the UI stays in sync across tabs/devices.
  Stream<List<CartItemModel>> watchItems(String uid) =>
      _items(uid).snapshots().map(
            (s) => s.docs
                .map((d) => CartItemModel.fromMap(d.id, d.data()))
                .toList(),
          );

  /// Adds one unit of [item]. Uses a transaction so concurrent tabs never
  /// lose quantity updates (read → increment → write).
  Future<void> add(String uid, CartItemModel item) async {
    final doc = _items(uid).doc(item.docId);
    await _db.runTransaction((tx) async {
      final snapshot = await tx.get(doc);
      final existing = snapshot.data();
      final newQty = existing == null
          ? item.qty
          : ((existing['qty'] as num?) ?? 0).toInt() + item.qty;
      tx.set(doc, item.copyWith(qty: newQty).toMap());
    });
  }

  Future<void> updateQty(String uid, String docId, int qty) async {
    if (qty <= 0) return remove(uid, docId);
    await _items(uid).doc(docId).update({'qty': qty});
  }

  Future<void> remove(String uid, String docId) =>
      _items(uid).doc(docId).delete();

  /// Empties the whole cart (used right after placing an order).
  Future<void> clear(String uid) async {
    final snapshot = await _items(uid).get();
    final batch = _db.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
