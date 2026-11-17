import 'cart_item_model.dart';

/// Delivery address captured at checkout (`orders/{id}.address`).
class AddressModel {
  const AddressModel({
    required this.fullName,
    required this.phone,
    required this.line1,
    required this.city,
    required this.zip,
    required this.country,
  });

  final String fullName;
  final String phone;
  final String line1;
  final String city;
  final String zip;
  final String country;

  factory AddressModel.fromMap(Map<String, dynamic> map) => AddressModel(
        fullName: (map['fullName'] as String?) ?? '',
        phone: (map['phone'] as String?) ?? '',
        line1: (map['line1'] as String?) ?? '',
        city: (map['city'] as String?) ?? '',
        zip: (map['zip'] as String?) ?? '',
        country: (map['country'] as String?) ?? '',
      );

  Map<String, dynamic> toMap() => {
        'fullName': fullName,
        'phone': phone,
        'line1': line1,
        'city': city,
        'zip': zip,
        'country': country,
      };
}

/// An order document (`orders/{autoId}`), created by [OrderRepository.placeOrder].
class OrderModel {
  const OrderModel({
    required this.id,
    required this.uid,
    required this.items,
    required this.address,
    required this.subtotal,
    required this.shippingFee,
    required this.total,
    required this.status,
    required this.createdAtMs,
  });

  final String id;
  final String uid;
  final List<CartItemModel> items;
  final AddressModel address;
  final double subtotal;
  final double shippingFee;
  final double total;
  final String status;
  final int createdAtMs;

  factory OrderModel.fromMap(String id, Map<String, dynamic> map) => OrderModel(
        id: id,
        uid: (map['uid'] as String?) ?? '',
        items: ((map['items'] as List?) ?? const [])
            .map((e) => CartItemModel.fromMap(
                  (e['productId'] as String?) ?? '',
                  Map<String, dynamic>.from(e as Map),
                ))
            .toList(),
        address: AddressModel.fromMap(Map<String, dynamic>.from((map['address'] as Map?) ?? {})),
        subtotal: (map['subtotal'] as num?)?.toDouble() ?? 0,
        shippingFee: (map['shippingFee'] as num?)?.toDouble() ?? 0,
        total: (map['total'] as num?)?.toDouble() ?? 0,
        status: (map['status'] as String?) ?? 'Placed',
        createdAtMs: ((map['createdAtMs'] as num?) ?? 0).toInt(),
      );

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'items': items.map((e) => e.toMap()).toList(),
        'address': address.toMap(),
        'subtotal': subtotal,
        'shippingFee': shippingFee,
        'total': total,
        'status': status,
        'createdAtMs': createdAtMs,
      };
}

/// Pure pricing rules shared by the cart badge, cart screen and checkout —
/// kept static so unit tests can cover them without Firebase.
class CartTotals {
  static const double freeShippingThreshold = 29;
  static const double shippingFee = 3.99;

  static double subtotal(List<CartItemModel> items) {
    var sum = 0.0;
    for (final item in items) {
      sum += item.lineTotal;
    }
    return sum;
  }

  static int itemCount(List<CartItemModel> items) {
    var count = 0;
    for (final item in items) {
      count += item.qty;
    }
    return count;
  }

  /// Free shipping on orders of $29 or more (SHEIN-like threshold).
  static double shippingFor(double subtotal) {
    if (subtotal <= 0) return 0;
    if (subtotal >= freeShippingThreshold) return 0;
    return shippingFee;
  }

  static double totalOf(double subtotal, double shipping) => subtotal + shipping;
}
