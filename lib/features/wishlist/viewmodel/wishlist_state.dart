import 'package:equatable/equatable.dart';

import '../../../data/repositories/wishlist_repository.dart';

enum WishlistStatus { guest, loading, ready }

class WishlistState extends Equatable {
  const WishlistState({
    this.status = WishlistStatus.guest,
    this.items = const [],
  });

  final WishlistStatus status;
  final List<WishlistItemModel> items;

  bool get isGuest => status == WishlistStatus.guest;
  bool get isEmpty => status == WishlistStatus.ready && items.isEmpty;
  Set<String> get productIds => items.map((e) => e.productId).toSet();

  @override
  List<Object?> get props => [status, items];
}
