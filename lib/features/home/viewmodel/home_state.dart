import 'package:equatable/equatable.dart';

import '../../../data/models/product_model.dart';

enum HomeStatus { loading, ready, error }

class HomeState extends Equatable {
  const HomeState({
    this.status = HomeStatus.loading,
    this.products = const [],
    this.error,
  });

  final HomeStatus status;
  final List<ProductModel> products;
  final String? error;

  HomeState copyWith({
    HomeStatus? status,
    List<ProductModel>? products,
    String? error,
  }) {
    return HomeState(
      status: status ?? this.status,
      products: products ?? this.products,
      error: error ?? this.error,
    );
  }

  /// Newest first.
  List<ProductModel> get newArrivals {
    final list = [...products]..sort((a, b) => b.createdAtMs.compareTo(a.createdAtMs));
    return list.take(8).toList();
  }

  /// Most-rated first (a decent stand-in for "Best Sellers").
  List<ProductModel> get bestSellers {
    final list = [...products]..sort((a, b) => b.ratingCount.compareTo(a.ratingCount));
    return list.take(8).toList();
  }

  /// Biggest discounts first.
  List<ProductModel> get deals {
    final list = [...products]..sort((a, b) => b.discount.compareTo(a.discount));
    return list.where((p) => p.hasDiscount).take(8).toList();
  }

  @override
  List<Object?> get props => [status, products, error];
}
