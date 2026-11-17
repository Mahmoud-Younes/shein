import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/firebase_error_mapper.dart';
import '../../../data/models/product_model.dart';
import '../../../data/repositories/product_repository.dart';
import 'catalog_filter.dart';
import 'catalog_state.dart';

/// ViewModel for the catalog page (group browsing + client-side search,
/// category chips and sorting).
class CatalogCubit extends Cubit<CatalogState> {
  CatalogCubit(this._products) : super(const CatalogState());

  final ProductRepository _products;

  Future<void> load(String group, {String query = ''}) async {
    emit(CatalogState(
      status: CatalogStatus.loading,
      group: group,
      query: query,
    ));
    try {
      final products = await _products.fetchAll();
      // The cubit can be closed while awaiting (user navigated away).
      if (isClosed) return;
      _emitFiltered(products, status: CatalogStatus.ready);
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(
        status: CatalogStatus.error,
        error: FirebaseErrorMapper.message(e),
      ));
    }
  }

  void setQuery(String query) {
    emit(state.copyWith(query: query));
    _refilter();
  }

  void setSort(CatalogSort sort) {
    emit(state.copyWith(sort: sort));
    _refilter();
  }

  void setCategory(String label) {
    emit(state.copyWith(
      categoryLabel: state.categoryLabel == label ? '' : label,
    ));
    _refilter();
  }

  void _refilter() => _emitFiltered(state.products);

  void _emitFiltered(
    List<ProductModel> products, {
    CatalogStatus? status,
  }) {
    final visible = CatalogFilter.apply(
      products: products,
      group: state.group,
      query: state.query,
      sort: state.sort,
      categoryLabel: state.categoryLabel,
    );
    emit(state.copyWith(
      status: status,
      products: products,
      visible: visible,
    ));
  }
}
