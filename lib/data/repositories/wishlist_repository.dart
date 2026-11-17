import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/product_model.dart';

/// A wishlisted product — denormalized snapshot of the essentials.
class WishlistItemModel {
  const WishlistItemModel({
    required this.productId,
    required this.title,
    required this.image,
    required this.price,
    required this.oldPrice,
    required this.discount,
    required this.addedAtMs,
  });

  final String productId;
  final String title;
  final String image;
  final double price;
  final double oldPrice;
  final int discount;
  final int addedAtMs;

  factory WishlistItemModel.fromMap(String docId, Map<String, dynamic> map) =>
      WishlistItemModel(
        productId: (map['productId'] as String?) ?? docId,
        title: (map['title'] as String?) ?? '',
        image: (map['image'] as String?) ?? '',
        price: (map['price'] as num?)?.toDouble() ?? 0,
        oldPrice: (map['oldPrice'] as num?)?.toDouble() ?? 0,
        discount: ((map['discount'] as num?) ?? 0).toInt(),
        addedAtMs: ((map['addedAtMs'] as num?) ?? 0).toInt(),
      );

  factory WishlistItemModel.fromProduct(ProductModel p) => WishlistItemModel(
        productId: p.id,
        title: p.title,
        image: p.mainImage,
        price: p.price,
        oldPrice: p.oldPrice,
        discount: p.discount,
        addedAtMs: DateTime.now().millisecondsSinceEpoch,
      );

  Map<String, dynamic> toMap() => {
        'productId': productId,
        'title': title,
        'image': image,
        'price': price,
        'oldPrice': oldPrice,
        'discount': discount,
        'addedAtMs': addedAtMs,
      };
}

/// Model layer for the per-user wishlist: `wishlists/{uid}/items/{productId}`.
class WishlistRepository {
  WishlistRepository(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _items(String uid) =>
      _db.collection('wishlists').doc(uid).collection('items');

  Stream<List<WishlistItemModel>> watchItems(String uid) =>
      _items(uid).snapshots().map(
            (s) => s.docs
                .map((d) => WishlistItemModel.fromMap(d.id, d.data()))
                .toList(),
          );

  /// Toggles a product in/out of the wishlist; returns true when added.
  Future<bool> toggle(String uid, ProductModel product) async {
    final doc = _items(uid).doc(product.id);
    return _db.runTransaction<bool>((tx) async {
      final snapshot = await tx.get(doc);
      if (snapshot.exists) {
        tx.delete(doc);
        return false;
      }
      tx.set(doc, WishlistItemModel.fromProduct(product).toMap());
      return true;
    });
  }

  Future<void> remove(String uid, String productId) =>
      _items(uid).doc(productId).delete();
}
