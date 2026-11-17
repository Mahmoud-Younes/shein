import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/page_states.dart';
import '../../../core/widgets/sign_in_prompt.dart';
import '../../../data/repositories/wishlist_repository.dart';
import '../viewmodel/wishlist_cubit.dart';
import '../viewmodel/wishlist_state.dart';

/// Wishlist — Firestore-backed, live-updating.
class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WishlistCubit, WishlistState>(
      builder: (context, wishlist) {
        return switch (wishlist.status) {
          WishlistStatus.guest => const SignInPrompt(
              title: 'Sign in to view your wishlist',
              subtitle: 'Save products you love and find them on any device.',
              redirect: '/wishlist',
            ),
          WishlistStatus.loading => const LoadingView(label: 'Loading your wishlist…'),
          WishlistStatus.ready when wishlist.isEmpty => EmptyView(
              icon: Icons.favorite_border_rounded,
              title: 'Your wishlist is empty',
              subtitle: 'Tap the heart on any product to save it here.',
              actionLabel: 'DISCOVER PRODUCTS',
              onAction: () => context.go('/'),
            ),
          WishlistStatus.ready => _WishlistGrid(items: wishlist.items),
        };
      },
    );
  }
}

class _WishlistGrid extends StatelessWidget {
  const _WishlistGrid({required this.items});

  final List<WishlistItemModel> items;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1440),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Wishlist (${items.length} items)',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = (constraints.maxWidth ~/ 230).clamp(2, 7);
                    return GridView.builder(
                      padding: EdgeInsets.zero,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.62,
                      ),
                      itemCount: items.length,
                      itemBuilder: (context, index) =>
                          _WishlistCard(item: items[index]),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WishlistCard extends StatelessWidget {
  const _WishlistCard({required this.item});

  final WishlistItemModel item;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.lineGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 3 / 4,
                child: InkWell(
                  onTap: () => context.go('/product/${item.productId}'),
                  child: item.image.isEmpty
                      ? const ColoredBox(color: AppColors.softGrey)
                      : Image.network(
                          item.image,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) =>
                              const ColoredBox(color: AppColors.softGrey),
                        ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Material(
                  color: Colors.white,
                  shape: const CircleBorder(),
                  elevation: 1,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => _remove(context),
                    child: Tooltip(
                      message: 'Remove from wishlist',
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: const Icon(
                          Icons.favorite_rounded,
                          size: 20,
                          color: AppColors.saleRed,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13.5, height: 1.25),
                ),
                const SizedBox(height: 6),
                Text(
                  '\$${item.price.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 36,
                  child: OutlinedButton(
                    onPressed: () => context.go('/product/${item.productId}'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 36),
                      padding: EdgeInsets.zero,
                      textStyle: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                    child: const Text('VIEW PRODUCT'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _remove(BuildContext context) async {
    try {
      await context.read<WishlistCubit>().remove(item.productId);
      if (context.mounted) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(SnackBar(content: Text('${item.title} removed from wishlist.')));
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not remove the item. Please try again.')),
        );
      }
    }
  }
}
