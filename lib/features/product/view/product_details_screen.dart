import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/auth_gate.dart';
import '../../../core/utils/fmt.dart';
import '../../../core/widgets/page_states.dart';
import '../../../core/widgets/rating_stars.dart';
import '../../../data/models/product_model.dart';
import '../../cart/viewmodel/cart_cubit.dart';
import '../../wishlist/viewmodel/wishlist_cubit.dart';
import '../../wishlist/viewmodel/wishlist_state.dart';
import '../viewmodel/product_details_cubit.dart';
import '../viewmodel/product_details_state.dart';

/// Product details page — gallery + variant selection + add to bag/wishlist.
class ProductDetailsScreen extends StatelessWidget {
  const ProductDetailsScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProductDetailsCubit>(
      key: ValueKey('product-$id'),
      create: (context) => ProductDetailsCubit(context.read())..load(id),
      child: BlocBuilder<ProductDetailsCubit, ProductDetailsState>(
        builder: (context, state) => switch (state.status) {
          ProductDetailsStatus.loading => const LoadingView(label: 'Loading product…'),
          ProductDetailsStatus.error => ErrorView(
              message: state.error ?? '',
              onRetry: () => context.read<ProductDetailsCubit>().load(id),
            ),
          ProductDetailsStatus.ready => _DetailsView(
              product: state.product!,
              details: state,
            ),
        },
      ),
    );
  }
}

class _DetailsView extends StatelessWidget {
  const _DetailsView({required this.product, required this.details});

  final ProductModel product;
  final ProductDetailsState details;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1240),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final sideBySide = constraints.maxWidth > 860;
              final gallery = _Gallery(images: product.images);
              final info = SizedBox(
                width: sideBySide ? 400 : double.infinity,
                child: _InfoPanel(product: product, details: details),
              );
              return sideBySide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: gallery),
                        const SizedBox(width: 36),
                        info,
                      ],
                    )
                  : Column(children: [gallery, const SizedBox(height: 24), info]);
            },
          ),
        ),
      ),
    );
  }
}

class _Gallery extends StatefulWidget {
  const _Gallery({required this.images});

  final List<String> images;

  @override
  State<_Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<_Gallery> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final images = widget.images;
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 3 / 4,
          child: images.isEmpty
              ? const ColoredBox(color: AppColors.softGrey)
              : Image.network(
                  images[_index.clamp(0, images.length - 1)],
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const ColoredBox(
                    color: AppColors.softGrey,
                    child: Icon(Icons.image_outlined, color: AppColors.textGrey),
                  ),
                ),
        ),
        if (images.length > 1) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: [
              for (var i = 0; i < images.length; i++)
                InkWell(
                  onTap: () => setState(() => _index = i),
                  child: Container(
                    width: 58,
                    height: 74,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _index == i ? AppColors.ink : AppColors.lineGrey,
                        width: _index == i ? 2 : 1,
                      ),
                    ),
                    child: Image.network(
                      images[i],
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) =>
                          const ColoredBox(color: AppColors.softGrey),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({required this.product, required this.details});

  final ProductModel product;
  final ProductDetailsState details;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          product.categoryLabel.toUpperCase(),
          style: const TextStyle(
            color: AppColors.textGrey,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          product.title,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, height: 1.25),
        ),
        const SizedBox(height: 8),
        RatingStars(rating: product.rating, ratingCount: product.ratingCount, size: 16),
        const SizedBox(height: 14),
        _PriceRow(product: product),
        const SizedBox(height: 18),
        _ColorSelector(product: product, selected: details.selectedColor),
        const SizedBox(height: 14),
        _SizeSelector(product: product, selected: details.selectedSize),
        const SizedBox(height: 14),
        _QtyRow(qty: details.qty),
        const SizedBox(height: 20),
        ElevatedButton(
          key: const Key('add-to-bag'),
          onPressed: () => _addToBag(context),
          child: const Text('ADD TO BAG'),
        ),
        const SizedBox(height: 10),
        BlocBuilder<WishlistCubit, WishlistState>(
          builder: (context, wishlist) {
            final wishlisted = wishlist.productIds.contains(product.id);
            return OutlinedButton.icon(
              onPressed: () => _toggleWishlist(context),
              icon: Icon(
                wishlisted ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                size: 18,
                color: wishlisted ? AppColors.saleRed : AppColors.ink,
              ),
              label: Text(wishlisted ? 'IN YOUR WISHLIST' : 'ADD TO WISHLIST'),
            );
          },
        ),
        const SizedBox(height: 22),
        const _InfoRow(icon: Icons.local_shipping_outlined, text: 'Free shipping on orders over \$29'),
        const _InfoRow(icon: Icons.autorenew_rounded, text: '30-day free returns'),
        const _InfoRow(icon: Icons.verified_outlined, text: 'SHEIN clone · demo store'),
        const SizedBox(height: 18),
        const Divider(),
        const SizedBox(height: 8),
        const Text('Description', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        Text(
          product.description,
          style: const TextStyle(height: 1.5, color: AppColors.textGrey, fontSize: 14),
        ),
      ],
    );
  }

  Future<void> _addToBag(BuildContext context) async {
    if (!requireAuth(context, redirect: '/product/${product.id}')) return;
    try {
      await context.read<CartCubit>().addToCart(
            product,
            size: details.selectedSize ?? product.firstSize,
            color: details.selectedColor ?? product.firstColor,
            qty: details.qty,
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

  Future<void> _toggleWishlist(BuildContext context) async {
    if (!requireAuth(context, redirect: '/product/${product.id}')) return;
    try {
      final added = await context.read<WishlistCubit>().toggle(product);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(
          content: Text(added ? 'Added to your wishlist.' : 'Removed from your wishlist.'),
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

class _PriceRow extends StatelessWidget {
  const _PriceRow({required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          Fmt.price(product.price),
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
        ),
        if (product.oldPrice > product.price) ...[
          const SizedBox(width: 10),
          Text(
            Fmt.price(product.oldPrice),
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textGrey,
              decoration: TextDecoration.lineThrough,
            ),
          ),
        ],
        if (product.hasDiscount) ...[
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            color: AppColors.saleRed,
            child: Text(
              '-${product.discount}%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _ColorSelector extends StatelessWidget {
  const _ColorSelector({required this.product, required this.selected});

  final ProductModel product;
  final String? selected;

  static const _palette = {
    'Black': Color(0xFF222222),
    'White': Color(0xFFF4F4F4),
    'Beige': Color(0xFFD9C7A7),
    'Pink': Color(0xFFE79CB1),
    'Blue': Color(0xFF5A7BD0),
    'Green': Color(0xFF679F7B),
    'Brown': Color(0xFF7B5B45),
    'Gold': Color(0xFFC9A227),
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Color: ${selected ?? '-'}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            for (final color in product.colors)
              Tooltip(
                message: color,
                child: InkWell(
                  onTap: () => context.read<ProductDetailsCubit>().selectColor(color),
                  child: Container(
                    width: 30,
                    height: 30,
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: color == selected ? AppColors.ink : AppColors.lineGrey,
                        width: color == selected ? 2 : 1,
                      ),
                    ),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _palette[color] ?? AppColors.softGrey,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _SizeSelector extends StatelessWidget {
  const _SizeSelector({required this.product, required this.selected});

  final ProductModel product;
  final String? selected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Size: ${selected ?? '-'}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final size in product.sizes)
              InkWell(
                onTap: () => context.read<ProductDetailsCubit>().selectSize(size),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: size == selected ? AppColors.ink : AppColors.lineGrey,
                      width: size == selected ? 2 : 1,
                    ),
                  ),
                  child: Text(
                    size,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: size == selected ? FontWeight.w800 : FontWeight.w400,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _QtyRow extends StatelessWidget {
  const _QtyRow({required this.qty});

  final int qty;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ProductDetailsCubit>();
    return Row(
      children: [
        const Text('Qty', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
        const SizedBox(width: 12),
        _StepperButton(
          label: '−',
          tooltip: 'Decrease quantity',
          onPressed: () => cubit.decreaseQty(),
        ),
        SizedBox(
          width: 44,
          child: Text(
            '$qty',
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
        ),
        _StepperButton(
          label: '+',
          tooltip: 'Increase quantity',
          onPressed: () => cubit.increaseQty(),
        ),
      ],
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.label,
    required this.tooltip,
    required this.onPressed,
  });

  final String label;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        child: Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.lineGrey),
          ),
          child: Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textGrey),
          const SizedBox(width: 10),
          Text(text, style: const TextStyle(fontSize: 13.5, color: AppColors.textGrey)),
        ],
      ),
    );
  }
}
