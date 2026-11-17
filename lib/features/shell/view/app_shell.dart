import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/badge_icon_button.dart';
import '../../auth/viewmodel/auth_cubit.dart';
import '../../auth/viewmodel/auth_state.dart';
import '../../cart/viewmodel/cart_cubit.dart';
import '../../cart/viewmodel/cart_state.dart';
import '../../wishlist/viewmodel/wishlist_cubit.dart';
import '../../wishlist/viewmodel/wishlist_state.dart';

/// Site chrome shared by all pages: announcement bar, header (logo, search,
/// account, wishlist, bag), category nav and footer.
class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.child,
    required this.location,
  });

  final Widget child;
  final String location;

  static const List<(String, String)> navGroups = [
    ('all', 'Shop All'),
    ('new', 'New In'),
    ('women', 'Women'),
    ('men', 'Men'),
    ('beauty', 'Beauty'),
    ('accessories', 'Accessories'),
    ('sale', 'Sale'),
  ];

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthCubit, AuthState>(
          listenWhen: (prev, curr) =>
              curr.error != null && prev.error != curr.error,
          listener: (context, state) {
            ScaffoldMessenger.of(context)
              ..clearSnackBars()
              ..showSnackBar(SnackBar(content: Text(state.error!)));
          },
        ),
        BlocListener<AuthCubit, AuthState>(
          listenWhen: (prev, curr) =>
              prev.isAuthenticated && curr.status == AuthStatus.unauthenticated,
          listener: (context, state) {
            ScaffoldMessenger.of(context)
              ..clearSnackBars()
              ..showSnackBar(
                const SnackBar(content: Text('You have been signed out.')),
              );
            if (location == '/orders' ||
                location.startsWith('/checkout')) {
              context.go('/');
            }
          },
        ),
      ],
      child: Scaffold(
        body: Column(
          children: [
            _announcementBar(),
            _header(context),
            _navRow(context),
            Expanded(child: child),
            _footer(),
          ],
        ),
      ),
    );
  }

  Widget _announcementBar() {
    return const ColoredBox(
      color: AppColors.ink,
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 7, horizontal: 16),
          child: Text(
            'FREE SHIPPING ON ORDERS OVER \$29  ·  30-DAY RETURNS  ·  NEW DEALS DAILY',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.1,
            ),
          ),
        ),
      ),
    );
  }

  bool _isActive(String group) {
    if (group == 'all') return location == '/catalog/all';
    return location.startsWith('/catalog/$group');
  }

  Widget _header(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.lineGrey)),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1440),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: Row(
              children: [
                InkWell(
                  onTap: () => context.go('/'),
                  child: const Text(
                    'SHEIN',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.5,
                    ),
                  ),
                ),
                const SizedBox(width: 36),
                Expanded(child: Center(child: _searchField(context))),
                const SizedBox(width: 16),
                _accountArea(context),
                BlocBuilder<WishlistCubit, WishlistState>(
                  builder: (context, wishlist) => BadgeIconButton(
                    icon: Icons.favorite_border_rounded,
                    tooltip: 'Wishlist',
                    count: wishlist.status == WishlistStatus.guest
                        ? 0
                        : wishlist.items.length,
                    onTap: () => context.go('/wishlist'),
                  ),
                ),
                BlocBuilder<CartCubit, CartState>(
                  builder: (context, cart) => BadgeIconButton(
                    icon: Icons.shopping_bag_outlined,
                    tooltip: 'Shopping Bag',
                    count: cart.isGuest ? 0 : cart.itemCount,
                    onTap: () => context.go('/cart'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _searchField(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 560),
      child: TextField(
        key: const Key('search-field'),
        textInputAction: TextInputAction.search,
        decoration: const InputDecoration(
          hintText: 'Search for products',
          prefixIcon: Icon(Icons.search_rounded, size: 22),
        ),
        onSubmitted: (value) {
          final query = value.trim();
          final encoded = Uri.encodeComponent(query);
          context.go('/catalog/all?q=$encoded');
        },
      ),
    );
  }

  Widget _accountArea(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, auth) {
        return switch (auth.status) {
          AuthStatus.unknown => const SizedBox(width: 24),
          AuthStatus.unauthenticated => TextButton.icon(
              onPressed: () => context.go('/login'),
              icon: const Icon(Icons.person_outline_rounded, size: 20),
              label: const Text('Sign In'),
            ),
          AuthStatus.authenticated => PopupMenuButton<String>(
              tooltip: 'Account',
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: AppColors.ink,
                      child: Text(
                        auth.displayName.isNotEmpty
                            ? auth.displayName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Hi, ${auth.displayName.split(' ').first}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down_rounded),
                  ],
                ),
              ),
              onSelected: (value) {
                switch (value) {
                  case 'orders':
                    context.go('/orders');
                  case 'wishlist':
                    context.go('/wishlist');
                  case 'logout':
                    context.read<AuthCubit>().signOut();
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'orders', child: Text('My Orders')),
                PopupMenuItem(value: 'wishlist', child: Text('Wishlist')),
                PopupMenuItem(value: 'logout', child: Text('Sign Out')),
              ],
            ),
        };
      },
    );
  }

  Widget _navRow(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1440),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final (group, label) in navGroups)
                _navItem(context, group, label),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(BuildContext context, String group, String label) {
    final active = _isActive(group);
    final isSale = group == 'sale';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: InkWell(
        onTap: () => context.go('/catalog/$group'),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: active ? AppColors.ink : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: active ? FontWeight.w800 : FontWeight.w500,
              letterSpacing: 0.4,
              color: isSale ? AppColors.saleRed : AppColors.ink,
            ),
          ),
        ),
      ),
    );
  }

  Widget _footer() {
    return const ColoredBox(
      color: AppColors.softGrey,
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          child: Text(
            '© 2026 SHEIN clone — Flutter Web + Firebase · built as a DEPI training task',
            style: TextStyle(fontSize: 12, color: AppColors.textGrey),
          ),
        ),
      ),
    );
  }
}
