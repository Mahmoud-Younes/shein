import '../../../data/models/product_model.dart';

enum CatalogSort { featured, newest, priceAsc, priceDesc, rating }

extension CatalogSortLabel on CatalogSort {
  String get label => switch (this) {
        CatalogSort.featured => 'Featured',
        CatalogSort.newest => 'Newest',
        CatalogSort.priceAsc => 'Price: Low to High',
        CatalogSort.priceDesc => 'Price: High to Low',
        CatalogSort.rating => 'Best Rating',
      };
}

/// Pure catalog filtering/sorting logic — static so unit tests can cover it
/// without Firebase or widgets.
class CatalogFilter {
  /// Valid top-level nav groups. `all`, `new` and `sale` are pseudo groups.
  static const groups = ['all', 'new', 'women', 'men', 'beauty', 'accessories', 'sale'];

  static String titleFor(String group) => switch (group) {
        'all' => 'All Products',
        'new' => 'New In',
        'sale' => 'Sale',
        'women' => 'Women',
        'men' => 'Men',
        'beauty' => 'Beauty',
        'accessories' => 'Accessories',
        _ => 'Shop',
      };

  static List<ProductModel> apply({
    required List<ProductModel> products,
    required String group,
    required String query,
    CatalogSort sort = CatalogSort.featured,
    String categoryLabel = '',
  }) {
    var result = products;

    switch (group) {
      case 'sale':
        result = result.where((p) => p.hasDiscount).toList();
      case 'all' || 'new':
        break;
      default:
        result = result.where((p) => p.group == group).toList();
    }

    if (categoryLabel.isNotEmpty) {
      result = result.where((p) => p.categoryLabel == categoryLabel).toList();
    }

    final q = query.trim().toLowerCase();
    if (q.isNotEmpty) {
      result = result.where((p) => p.title.toLowerCase().contains(q)).toList();
    }

    switch (sort) {
      case CatalogSort.featured:
        break;
      case CatalogSort.newest:
        result = [...result]..sort((a, b) => b.createdAtMs.compareTo(a.createdAtMs));
      case CatalogSort.priceAsc:
        result = [...result]..sort((a, b) => a.price.compareTo(b.price));
      case CatalogSort.priceDesc:
        result = [...result]..sort((a, b) => b.price.compareTo(a.price));
      case CatalogSort.rating:
        result = [...result]..sort((a, b) => b.rating.compareTo(a.rating));
    }
    return result;
  }

  /// Distinct sub-category labels present in [products] (for the chip row).
  static List<String> categoryLabels(List<ProductModel> products) {
    final seen = <String>{};
    final labels = <String>[];
    for (final p in products) {
      if (p.categoryLabel.isNotEmpty && seen.add(p.categoryLabel)) {
        labels.add(p.categoryLabel);
      }
    }
    return labels;
  }
}
