import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/fmt.dart';
import '../../../core/widgets/page_states.dart';
import '../../../core/widgets/sign_in_prompt.dart';
import '../../../data/models/cart_item_model.dart';
import '../../../data/models/order_model.dart' show CartTotals;
import '../viewmodel/cart_cubit.dart';
import '../viewmodel/cart_state.dart';

/// Shopping bag — Firestore-backed, live-updating.
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, cart) {
        return switch (cart.status) {
          CartStatus.guest => const SignInPrompt(
              title: 'Sign in to view your bag',
              subtitle: 'Your bag is saved to your account — items stay synced across devices.',
              redirect: '/cart',
            ),
          CartStatus.loading => const LoadingView(label: 'Loading your bag…'),
          CartStatus.ready when cart.isEmpty => EmptyView(
              icon: Icons.shopping_bag_outlined,
              title: 'Your bag is empty',
              subtitle: 'Fill it with something good.',
              actionLabel: 'SHOP NOW',
              onAction: () => context.go('/'),
            ),
          CartStatus.ready => _CartBody(cart: cart),
        };
      },
    );
  }
}

class _CartBody extends StatelessWidget {
  const _CartBody({required this.cart});

  final CartState cart;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final summary = _OrderSummary(cart: cart);
              final lines = _CartLines(items: cart.items);
              return constraints.maxWidth > 900
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: lines),
                        const SizedBox(width: 28),
                        SizedBox(width: 320, child: summary),
                      ],
                    )
                  : Column(
                      children: [lines, const SizedBox(height: 24), summary],
                    );
            },
          ),
        ),
      ),
    );
  }
}

class _CartLines extends StatelessWidget {
  const _CartLines({required this.items});

  final List<CartItemModel> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final item in items) _CartLine(item: item),
      ],
    );
  }
}

class _CartLine extends StatelessWidget {
  const _CartLine({required this.item});

  final CartItemModel item;

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartCubit>();
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.lineGrey)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => context.go('/product/${item.productId}'),
            child: SizedBox(
              width: 88,
              height: 110,
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
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5),
                ),
                const SizedBox(height: 4),
                Text(
                  'Size: ${item.size}  ·  Color: ${item.color}',
                  style: const TextStyle(color: AppColors.textGrey, fontSize: 12.5),
                ),
                const SizedBox(height: 4),
                Text(Fmt.price(item.price), style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text('Qty', style: TextStyle(fontSize: 13, color: AppColors.textGrey)),
                    const SizedBox(width: 8),
                    _StepButton(
                      label: '−',
                      tooltip: 'Decrease quantity',
                      onPressed: () => _updateQty(context, cart, item.qty - 1),
                    ),
                    SizedBox(
                      width: 36,
                      child: Text(
                        '${item.qty}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    _StepButton(
                      label: '+',
                      tooltip: 'Increase quantity',
                      onPressed: () => _updateQty(context, cart, item.qty + 1),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                Fmt.price(item.lineTotal),
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
              ),
              TextButton(
                key: Key('remove-${item.productId}'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.saleRed,
                  minimumSize: const Size(0, 32),
                ),
                onPressed: () => _remove(context, cart),
                child: const Text('Remove'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _updateQty(BuildContext context, CartCubit cart, int qty) async {
    try {
      await cart.updateQty(item.docId, qty);
    } catch (e) {
      if (context.mounted) _showError(context, e);
    }
  }

  Future<void> _remove(BuildContext context, CartCubit cart) async {
    try {
      await cart.remove(item.docId);
      if (context.mounted) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(const SnackBar(content: Text('Item removed from bag.')));
      }
    } catch (e) {
      if (context.mounted) _showError(context, e);
    }
  }

  void _showError(BuildContext context, Object e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_friendly(e))));
  }

  String _friendly(Object e) =>
      e.toString().replaceFirst('Exception: ', '').replaceFirst('Bad state: ', '');
}

class _StepButton extends StatelessWidget {
  const _StepButton({
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
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.lineGrey),
          ),
          child: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}

class _OrderSummary extends StatelessWidget {
  const _OrderSummary({required this.cart});

  final CartState cart;

  @override
  Widget build(BuildContext context) {
    final canGetFreeShipping = cart.subtotal > 0 && cart.subtotal < CartTotals.freeShippingThreshold;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.lineGrey),
        color: AppColors.softGrey,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Order Summary', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          _row('Subtotal (${cart.itemCount} items)', Fmt.price(cart.subtotal)),
          const SizedBox(height: 8),
          _row(
            'Shipping',
            cart.shipping == 0 ? 'FREE' : Fmt.price(cart.shipping),
            valueColor: cart.shipping == 0 ? Colors.green : null,
          ),
          if (canGetFreeShipping)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                'Add ${Fmt.price(CartTotals.freeShippingThreshold - cart.subtotal)} more for FREE shipping',
                style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
              ),
            ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
              Text(
                Fmt.price(cart.total),
                style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            key: const Key('proceed-checkout'),
            onPressed: () => context.go('/checkout'),
            child: const Text('PROCEED TO CHECKOUT'),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14)),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.ink,
          ),
        ),
      ],
    );
  }
}
