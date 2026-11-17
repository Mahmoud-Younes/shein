import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/fmt.dart';

/// "$29.99  ~~$34.13~~  [-12%]" — SHEIN-style price row.
class PriceText extends StatelessWidget {
  const PriceText({
    super.key,
    required this.price,
    this.oldPrice,
    this.discount,
    this.priceSize = 16,
  });

  final double price;
  final double? oldPrice;
  final int? discount;
  final double priceSize;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      runSpacing: 4,
      children: [
        Text(
          Fmt.price(price),
          style: TextStyle(
            fontSize: priceSize,
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
          ),
        ),
        if (oldPrice != null && oldPrice! > price)
          Text(
            Fmt.price(oldPrice!),
            style: TextStyle(
              fontSize: priceSize - 3,
              color: AppColors.textGrey,
              decoration: TextDecoration.lineThrough,
            ),
          ),
        if (discount != null && discount! > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            color: AppColors.saleRed,
            child: Text(
              '-$discount%',
              style: TextStyle(
                fontSize: priceSize - 6,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }
}
