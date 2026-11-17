import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/product_model.dart';
import '../seeding/product_seed.dart';

/// Model layer for the product catalog (`products/{id}`).
///
/// The catalog is small (~50 demo products), so lists are fetched once and
/// search/sort/filter runs client-side inside the catalog cubit — no Firestore
/// composite indexes needed.
class ProductRepository {
  ProductRepository(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _products =>
      _db.collection('products');

  /// Seeds demo products once, using fixed document ids → idempotent and
  /// safe against concurrent runs. Called on first home load.
  Future<void> ensureSeeded() async {
    final existing = await _products.limit(1).get();
    if (existing.docs.isNotEmpty) return;

    final batch = _db.batch();
    for (final map in kSeedProducts) {
      batch.set(
        _products.doc(map['id'] as String),
        Map<String, dynamic>.from(map),
      );
    }
    await batch.commit();
  }

  Future<List<ProductModel>> fetchAll({int limit = 300}) async {
    final snapshot = await _products.limit(limit).get();
    return snapshot.docs.map((d) => ProductModel.fromMap(d.id, d.data())).toList();
  }

  Future<List<ProductModel>> fetchByGroup(String group) async {
    final snapshot = await _products
        .where('group', isEqualTo: group)
        .limit(300)
        .get();
    return snapshot.docs.map((d) => ProductModel.fromMap(d.id, d.data())).toList();
  }

  Future<ProductModel?> getById(String id) async {
    final doc = await _products.doc(id).get();
    if (!doc.exists) return null;
    return ProductModel.fromMap(doc.id, doc.data()!);
  }
}
