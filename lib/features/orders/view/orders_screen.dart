import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/fmt.dart';
import '../../../core/widgets/page_states.dart';
import '../../../core/widgets/sign_in_prompt.dart';
import '../../../data/models/order_model.dart';
import '../viewmodel/orders_cubit.dart';
import '../viewmodel/orders_state.dart';

/// My Orders — reads `orders` for the signed-in user, newest first.
class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key, this.justPlaced = false});

  final bool justPlaced;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrdersCubit, OrdersState>(
      builder: (context, orders) {
        return switch (orders.status) {
          OrdersStatus.guest => const SignInPrompt(
              title: 'Sign in to view your orders',
              subtitle: 'Track your order history and statuses.',
              redirect: '/orders',
            ),
          OrdersStatus.loading => const LoadingView(label: 'Loading your orders…'),
          OrdersStatus.ready when orders.isEmpty => EmptyView(
              icon: Icons.receipt_long_outlined,
              title: justPlaced ? 'Order placed!' : 'No orders yet',
              subtitle: justPlaced
                  ? 'Your order will appear here shortly.'
                  : 'Your placed orders will show up here.',
              actionLabel: 'START SHOPPING',
              onAction: () => context.go('/'),
            ),
          OrdersStatus.ready => _OrdersList(
              orders: orders.orders,
              justPlaced: justPlaced,
            ),
        };
      },
    );
  }
}

class _OrdersList extends StatelessWidget {
  const _OrdersList({required this.orders, required this.justPlaced});

  final List<OrderModel> orders;
  final bool justPlaced;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 860),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'My Orders',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              if (justPlaced)
                Container(
                  key: const Key('order-success-banner'),
                  padding: const EdgeInsets.all(14),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    border: Border.all(color: Colors.green),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.check_circle_outline_rounded, color: Colors.green),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Order placed successfully! Thank you for shopping with SHEIN.',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [for (final order in orders) _OrderCard(order: order)],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final shortId = order.id.length > 8 ? order.id.substring(0, 8).toUpperCase() : order.id.toUpperCase();
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.lineGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Order #$shortId',
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.green),
                  color: const Color(0xFFE8F5E9),
                ),
                child: Text(
                  order.status,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.green,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                Fmt.date(order.createdAtMs),
                style: const TextStyle(color: AppColors.textGrey, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (final item in order.items.take(3))
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () => context.go('/product/${item.productId}'),
                    child: SizedBox(
                      width: 54,
                      height: 68,
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
                ),
              if (order.items.length > 3)
                Text(
                  '+${order.items.length - 3} more',
                  style: const TextStyle(color: AppColors.textGrey, fontSize: 13),
                ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Total: ${Fmt.price(order.total)}',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${order.items.length} item(s) · ${order.address.city}, ${order.address.country}',
                    style: const TextStyle(color: AppColors.textGrey, fontSize: 12.5),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
