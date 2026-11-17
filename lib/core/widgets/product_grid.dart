import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/product_model.dart';
import '../../features/cart/viewmodel/cart_cubit.dart';
import '../../features/wishlist/viewmodel/wishlist_cubit.dart';
import '../../features/wishlist/viewmodel/wishlist_state.dart';
import '../utils/auth_gate.dart';
import '../utils/fmt.dart';
import 'product_card.dart';

/// Responsive product grid with shared cart/wishlist wiring.
/// Used by the home page and the catalog page.
class ProductGrid extends StatelessWidget {
  const ProductGrid({super.key, required this.products});

  final List<ProductModel> products;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = (constraints.maxWidth ~/ 230).clamp(2, 7);
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.62,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) => BlocBuilder<WishlistCubit, WishlistState>(
            builder: (context, wishlist) {
              final product = products[index];
              return ProductCard(
                product: product,
                isWishlisted: wishlist.productIds.contains(product.id),
                onToggleWishlist: () => _toggleWishlist(context, product),
                onAddToBag: () => _addToBag(context, product),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _toggleWishlist(BuildContext context, ProductModel product) async {
    if (!requireAuth(context)) return;
    final added = await context.read<WishlistCubit>().toggle(product);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        content: Text(added ? 'Added to your wishlist.' : 'Removed from your wishlist.'),
      ));
  }

  Future<void> _addToBag(BuildContext context, ProductModel product) async {
    if (!requireAuth(context)) return;
    try {
      await context.read<CartCubit>().addToCart(
            product,
            size: product.firstSize,
            color: product.firstColor,
          );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(
          content: Text('Added to bag — ${Fmt.price(product.price)} · ${product.title}'),
          action: SnackBarAction(
            label: 'View Bag',
            onPressed: () => context.go('/cart'),
          ),
        ));
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_friendly(e))),
      );
    }
  }

  String _friendly(Object e) =>
      e.toString().replaceFirst('Exception: ', '').replaceFirst('Bad state: ', '');
}
