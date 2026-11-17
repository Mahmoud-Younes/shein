import 'package:equatable/equatable.dart';

import '../../../data/models/product_model.dart';
import 'catalog_filter.dart';

enum CatalogStatus { loading, ready, error }

class CatalogState extends Equatable {
  const CatalogState({
    this.status = CatalogStatus.loading,
    this.products = const [],
    this.visible = const [],
    this.group = 'all',
    this.query = '',
    this.sort = CatalogSort.featured,
    this.categoryLabel = '',
    this.error,
  });

  final CatalogStatus status;

  /// Everything loaded from Firestore for this group.
  final List<ProductModel> products;

  /// After search/sort/category filtering — what the grid shows.
  final List<ProductModel> visible;
  final String group;
  final String query;
  final CatalogSort sort;
  final String categoryLabel;
  final String? error;

  List<String> get categoryLabels => CatalogFilter.categoryLabels(products);
  String get title => CatalogFilter.titleFor(group);

  CatalogState copyWith({
    CatalogStatus? status,
    List<ProductModel>? products,
    List<ProductModel>? visible,
    String? group,
    String? query,
    CatalogSort? sort,
    String? categoryLabel,
    String? error,
    bool clearCategory = false,
  }) =>
      CatalogState(
        status: status ?? this.status,
        products: products ?? this.products,
        visible: visible ?? this.visible,
        group: group ?? this.group,
        query: query ?? this.query,
        sort: sort ?? this.sort,
        categoryLabel: clearCategory ? '' : (categoryLabel ?? this.categoryLabel),
        error: error,
      );

  @override
  List<Object?> get props =>
      [status, products, visible, group, query, sort, categoryLabel, error];
}
