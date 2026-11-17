import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/product_repository.dart';
import 'product_details_state.dart';

/// ViewModel for the product details page: loads one product by id and keeps
/// the variant selection (size / color / quantity) shown in the UI.
class ProductDetailsCubit extends Cubit<ProductDetailsState> {
  ProductDetailsCubit(this._products) : super(const ProductDetailsState());

  final ProductRepository _products;

  Future<void> load(String id) async {
    emit(const ProductDetailsState());
    try {
      final product = await _products.getById(id);
      if (isClosed) return;
      if (product == null) {
        emit(const ProductDetailsState(
          status: ProductDetailsStatus.error,
          error: 'Product not found.',
        ));
        return;
      }
      // The cubit can be closed while awaiting (user navigated away).
      if (isClosed) return;
      emit(ProductDetailsState(
        status: ProductDetailsStatus.ready,
        product: product,
        selectedSize: product.firstSize,
        selectedColor: product.firstColor,
      ));
    } catch (_) {
      if (isClosed) return;
      emit(const ProductDetailsState(
        status: ProductDetailsStatus.error,
        error: 'Something went wrong. Please try again.',
      ));
    }
  }

  void selectSize(String size) => emit(state.copyWith(selectedSize: size));
  void selectColor(String color) => emit(state.copyWith(selectedColor: color));
  void increaseQty() => emit(state.copyWith(qty: state.qty + 1));
  void decreaseQty() {
    if (state.qty > 1) emit(state.copyWith(qty: state.qty - 1));
  }
}
