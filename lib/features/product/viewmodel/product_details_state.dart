import 'package:equatable/equatable.dart';

import '../../../data/models/product_model.dart';

enum ProductDetailsStatus { loading, ready, error }

class ProductDetailsState extends Equatable {
  const ProductDetailsState({
    this.status = ProductDetailsStatus.loading,
    this.product,
    this.selectedSize,
    this.selectedColor,
    this.qty = 1,
    this.error,
  });

  final ProductDetailsStatus status;
  final ProductModel? product;
  final String? selectedSize;
  final String? selectedColor;
  final int qty;
  final String? error;

  ProductDetailsState copyWith({
    ProductDetailsStatus? status,
    String? selectedSize,
    String? selectedColor,
    int? qty,
    String? error,
  }) {
    return ProductDetailsState(
      status: status ?? this.status,
      product: product,
      selectedSize: selectedSize ?? this.selectedSize,
      selectedColor: selectedColor ?? this.selectedColor,
      qty: qty ?? this.qty,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, product, selectedSize, selectedColor, qty, error];
}
