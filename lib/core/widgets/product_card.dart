import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/product_model.dart';
import '../theme/app_theme.dart';
import '../utils/fmt.dart';
import 'price_text.dart';
import 'rating_stars.dart';

/// Catalog tile — image, wishlist heart, title, price row, rating and a
/// quick "Add to Bag" button. Action handling stays with the parent screen.
class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.isWishlisted,
    required this.onToggleWishlist,
    required this.onAddToBag,
    this.width = 240,
  });

  final ProductModel product;
  final bool isWishlisted;
  final VoidCallback onToggleWishlist;
  final VoidCallback onAddToBag;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Card(
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: const BorderSide(color: AppColors.lineGrey),
        ),
        margin: EdgeInsets.zero,
        child: InkWell(
          onTap: () => context.go('/product/${product.id}'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Flexible so the card never overflows a fixed-height grid cell:
              // the image yields space to the (fixed) text block and gets
              // cover-cropped instead.
              Flexible(
                child: Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 3 / 4,
                      child: product.mainImage.isEmpty
                          ? const ColoredBox(color: AppColors.softGrey)
                          : Image.network(
                              product.mainImage,
                              fit: BoxFit.cover,
                              loadingBuilder: _loadingBuilder,
                              errorBuilder: (_, _, _) => const ColoredBox(
                                color: AppColors.softGrey,
                                child: Icon(
                                  Icons.image_outlined,
                                  color: AppColors.textGrey,
                                ),
                              ),
                            ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: _HeartButton(
                        wishlisted: isWishlisted,
                        onTap: onToggleWishlist,
                      ),
                    ),
                    if (!product.inStock)
                      const Positioned(
                        left: 0,
                        bottom: 0,
                        child: ColoredBox(
                          color: AppColors.ink,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            child: Text(
                              'SOLD OUT',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13.5, height: 1.25),
                    ),
                    const SizedBox(height: 6),
                    PriceText(
                      price: product.price,
                      oldPrice: product.oldPrice,
                      discount: product.hasDiscount ? product.discount : null,
                    ),
                    const SizedBox(height: 6),
                    RatingStars(
                      rating: product.rating,
                      ratingCount: product.ratingCount,
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 36,
                      child: OutlinedButton(
                        onPressed: product.inStock ? onAddToBag : null,
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 36),
                          padding: EdgeInsets.zero,
                          textStyle: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                        child: const Text('ADD TO BAG'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _loadingBuilder(
    BuildContext context,
    Widget child,
    ImageChunkEvent? progress,
  ) {
    if (progress == null) return child;
    return const ColoredBox(
      color: AppColors.softGrey,
      child: Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.textGrey,
          ),
        ),
      ),
    );
  }
}

class _HeartButton extends StatelessWidget {
  const _HeartButton({required this.wishlisted, required this.onTap});

  final bool wishlisted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 1,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Tooltip(
          message: wishlisted ? 'Remove from wishlist' : 'Add to wishlist',
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Icon(
              wishlisted
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              size: 20,
              color: wishlisted ? AppColors.saleRed : AppColors.ink,
            ),
          ),
        ),
      ),
    );
  }
}

/// Price for wishlist cards (kept in core for reuse).
class WishlistPriceText extends StatelessWidget {
  const WishlistPriceText({super.key, required this.price});

  final double price;

  @override
  Widget build(BuildContext context) {
    return Text(
      Fmt.price(price),
      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
    );
  }
}
