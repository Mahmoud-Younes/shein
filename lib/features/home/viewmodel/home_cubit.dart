import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/firebase_error_mapper.dart';
import '../../../data/repositories/product_repository.dart';
import 'home_state.dart';

/// ViewModel for the home page: seeds the catalog on first run, then loads
/// the product list used by all home sections.
class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._products) : super(const HomeState());

  final ProductRepository _products;

  Future<void> load() async {
    emit(state.copyWith(status: HomeStatus.loading));
    try {
      await _products.ensureSeeded();
      final products = await _products.fetchAll();
      // The cubit can be closed while awaiting (user navigated away).
      if (isClosed) return;
      emit(HomeState(status: HomeStatus.ready, products: products));
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(
        status: HomeStatus.error,
        error: FirebaseErrorMapper.message(e),
      ));
    }
  }

  Future<void> retry() => load();
}
