/// Model layer — a catalog product. Mirrors the `products/{id}` Firestore
/// document and the generated seed entries 1:1 (same map keys).
class ProductModel {
  const ProductModel({
    required this.id,
    required this.title,
    required this.description,
    required this.group,
    required this.category,
    required this.categoryLabel,
    required this.price,
    required this.oldPrice,
    required this.discount,
    required this.rating,
    required this.ratingCount,
    required this.stock,
    required this.images,
    required this.sizes,
    required this.colors,
    required this.createdAtMs,
  });

  final String id;
  final String title;
  final String description;

  /// Top-level nav group: women | men | beauty | accessories.
  final String group;

  /// Sub-category slug, e.g. "womens-dresses".
  final String category;
  final String categoryLabel;
  final double price;
  final double oldPrice;
  final int discount;
  final double rating;
  final int ratingCount;
  final int stock;
  final List<String> images;
  final List<String> sizes;
  final List<String> colors;

  /// Used for "New In" sorting.
  final int createdAtMs;

  bool get hasDiscount => discount > 0;
  bool get inStock => stock > 0;
  String get mainImage => images.isNotEmpty ? images.first : '';
  String get firstSize => sizes.isNotEmpty ? sizes.first : 'One Size';
  String get firstColor => colors.isNotEmpty ? colors.first : 'Default';

  factory ProductModel.fromMap(String id, Map<String, dynamic> map) {
    final price = (map['price'] as num?)?.toDouble() ?? 0;
    final oldPrice = (map['oldPrice'] as num?)?.toDouble() ?? price;
    return ProductModel(
      id: id,
      title: (map['title'] as String?) ?? '',
      description: (map['description'] as String?) ?? '',
      group: (map['group'] as String?) ?? 'women',
      category: (map['category'] as String?) ?? '',
      categoryLabel: (map['categoryLabel'] as String?) ?? '',
      price: price,
      oldPrice: oldPrice,
      discount: ((map['discount'] as num?) ?? 0).toInt(),
      rating: (map['rating'] as num?)?.toDouble() ?? 0,
      ratingCount: ((map['ratingCount'] as num?) ?? 0).toInt(),
      stock: ((map['stock'] as num?) ?? 0).toInt(),
      images: List<String>.from((map['images'] as List?) ?? const []),
      sizes: List<String>.from((map['sizes'] as List?) ?? const []),
      colors: List<String>.from((map['colors'] as List?) ?? const []),
      createdAtMs: ((map['createdAtMs'] as num?) ?? 0).toInt(),
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'description': description,
        'group': group,
        'category': category,
        'categoryLabel': categoryLabel,
        'price': price,
        'oldPrice': oldPrice,
        'discount': discount,
        'rating': rating,
        'ratingCount': ratingCount,
        'stock': stock,
        'images': images,
        'sizes': sizes,
        'colors': colors,
        'createdAtMs': createdAtMs,
      };
}
