import 'package:flutter_test/flutter_test.dart';

import 'package:shein/data/models/cart_item_model.dart';
import 'package:shein/data/models/order_model.dart';
import 'package:shein/data/models/product_model.dart';

/// Shared fixtures for unit/widget tests.
ProductModel productFixture({
  String id = 'womens-dresses-blue-frock',
  String title = 'Blue Frock',
  String group = 'women',
  String category = 'womens-dresses',
  String categoryLabel = 'Dresses',
  double price = 29.99,
  double oldPrice = 34.13,
  int discount = 12,
  double rating = 4.2,
  int ratingCount = 177,
  int stock = 52,
  List<String>? images,
  List<String>? sizes,
  List<String>? colors,
  int createdAtMs = 1760000000000,
}) {
  return ProductModel(
    id: id,
    title: title,
    description: 'A charming and stylish dress.',
    group: group,
    category: category,
    categoryLabel: categoryLabel,
    price: price,
    oldPrice: oldPrice,
    discount: discount,
    rating: rating,
    ratingCount: ratingCount,
    stock: stock,
    images: images ?? const [],
    sizes: sizes ?? const ['XS', 'S', 'M'],
    colors: colors ?? const ['Blue', 'Black'],
    createdAtMs: createdAtMs,
  );
}

CartItemModel cartItemFixture({
  String productId = 'womens-dresses-blue-frock',
  String size = 'M',
  double price = 29.99,
  int qty = 2,
}) {
  return CartItemModel(
    productId: productId,
    size: size,
    color: 'Blue',
    title: 'Blue Frock',
    image: '',
    price: price,
    qty: qty,
  );
}

OrderModel orderFixture() {
  return OrderModel(
    id: 'abc123',
    uid: 'user-1',
    items: [cartItemFixture()],
    address: const AddressModel(
      fullName: 'Mahmoud Younes',
      phone: '0100000000',
      line1: '12 Nile St',
      city: 'Cairo',
      zip: '11511',
      country: 'Egypt',
    ),
    subtotal: 59.98,
    shippingFee: 0,
    total: 59.98,
    status: 'Placed',
    createdAtMs: 1760000000000,
  );
}

void main() {
  group('ProductModel', () {
    test('round-trips through a map', () {
      final product = productFixture();
      final restored = ProductModel.fromMap(product.id, product.toMap());
      expect(restored.id, product.id);
      expect(restored.title, product.title);
      expect(restored.group, product.group);
      expect(restored.price, product.price);
      expect(restored.oldPrice, product.oldPrice);
      expect(restored.discount, product.discount);
      expect(restored.rating, product.rating);
      expect(restored.sizes, product.sizes);
      expect(restored.createdAtMs, product.createdAtMs);
    });

    test('derives discount / stock / variant helpers', () {
      final product = productFixture();
      expect(product.hasDiscount, isTrue);
      expect(product.inStock, isTrue);
      expect(product.firstSize, 'XS');
      expect(product.firstColor, 'Blue');

      final soldOut = productFixture(stock: 0, discount: 0, sizes: [], colors: []);
      expect(soldOut.inStock, isFalse);
      expect(soldOut.hasDiscount, isFalse);
      expect(soldOut.firstSize, 'One Size');
      expect(soldOut.firstColor, 'Default');
    });

    test('tolerates missing fields (null-safe defaults)', () {
      final product = ProductModel.fromMap('x', {});
      expect(product.title, '');
      expect(product.price, 0);
      expect(product.images, isEmpty);
    });
  });

  group('CartItemModel', () {
    test('docId separates same product in different sizes', () {
      final m = cartItemFixture(size: 'M');
      final l = cartItemFixture(size: 'L');
      expect(m.docId, 'womens-dresses-blue-frock__M');
      expect(l.docId, 'womens-dresses-blue-frock__L');
      expect(m.docId, isNot(l.docId));
    });

    test('lineTotal is price × qty', () {
      expect(cartItemFixture(price: 29.99, qty: 2).lineTotal, closeTo(59.98, 1e-9));
    });

    test('round-trips through a map', () {
      final item = cartItemFixture(qty: 3);
      final restored = CartItemModel.fromMap(item.docId, item.toMap());
      expect(restored.productId, item.productId);
      expect(restored.size, item.size);
      expect(restored.qty, 3);
    });
  });

  group('OrderModel', () {
    test('round-trips through a map', () {
      final order = orderFixture();
      final restored = OrderModel.fromMap(order.id, order.toMap());
      expect(restored.uid, 'user-1');
      expect(restored.items.length, 1);
      expect(restored.items.first.qty, 2);
      expect(restored.address.city, 'Cairo');
      expect(restored.total, 59.98);
      expect(restored.status, 'Placed');
    });
  });

  group('CartTotals', () {
    test('subtotal sums line totals', () {
      final items = [cartItemFixture(qty: 2), cartItemFixture(price: 10, qty: 1)];
      expect(CartTotals.subtotal(items), closeTo(69.98, 1e-9));
    });

    test('itemCount sums quantities', () {
      final items = [cartItemFixture(qty: 2), cartItemFixture(qty: 3)];
      expect(CartTotals.itemCount(items), 5);
      expect(CartTotals.itemCount(const []), 0);
    });

    test('shipping is free at/over \$29 or empty cart, else \$3.99', () {
      expect(CartTotals.shippingFor(0), 0);
      expect(CartTotals.shippingFor(10), CartTotals.shippingFee);
      expect(CartTotals.shippingFor(28.99), CartTotals.shippingFee);
      expect(CartTotals.shippingFor(29), 0);
      expect(CartTotals.shippingFor(120), 0);
    });

    test('total is subtotal + shipping', () {
      expect(CartTotals.totalOf(10, 3.99), closeTo(13.99, 1e-9));
    });
  });
}
