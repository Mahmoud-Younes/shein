/// A line in the user's cart (`carts/{uid}/items/{docId}`).
/// Product fields are denormalized on purpose: the cart must keep showing
/// title/price/image even if the product is later edited or removed.
class CartItemModel {
  const CartItemModel({
    required this.productId,
    required this.size,
    required this.color,
    required this.title,
    required this.image,
    required this.price,
    required this.qty,
  });

  final String productId;
  final String size;
  final String color;
  final String title;
  final String image;
  final double price;
  final int qty;

  /// Same product in different sizes are separate cart lines.
  String get docId => '${productId}__$size';
  double get lineTotal => price * qty;

  CartItemModel copyWith({int? qty}) => CartItemModel(
        productId: productId,
        size: size,
        color: color,
        title: title,
        image: image,
        price: price,
        qty: qty ?? this.qty,
      );

  factory CartItemModel.fromMap(String docId, Map<String, dynamic> map) {
    return CartItemModel(
      productId: (map['productId'] as String?) ?? '',
      size: (map['size'] as String?) ?? '',
      color: (map['color'] as String?) ?? '',
      title: (map['title'] as String?) ?? '',
      image: (map['image'] as String?) ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0,
      qty: ((map['qty'] as num?) ?? 0).toInt(),
    );
  }

  Map<String, dynamic> toMap() => {
        'productId': productId,
        'size': size,
        'color': color,
        'title': title,
        'image': image,
        'price': price,
        'qty': qty,
      };
}
