import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Compact "★★★★☆ 4.5 (177)" rating display.
class RatingStars extends StatelessWidget {
  const RatingStars({
    super.key,
    required this.rating,
    this.ratingCount,
    this.size = 14,
  });

  final double rating;
  final int? ratingCount;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < 5; i++)
          Icon(
            _starIcon(i),
            size: size,
            color: AppColors.starGold,
          ),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(fontSize: size - 1, fontWeight: FontWeight.w600),
        ),
        if (ratingCount != null)
          Text(
            ' ($ratingCount)',
            style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
          ),
      ],
    );
  }

  IconData _starIcon(int index) {
    if (rating >= index + 1) return Icons.star_rounded;
    if (rating >= index + 0.5) return Icons.star_half_rounded;
    return Icons.star_border_rounded;
  }
}
