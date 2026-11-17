import 'package:go_router/go_router.dart';

import '../../features/auth/view/login_screen.dart';
import '../../features/auth/view/signup_screen.dart';
import '../../features/cart/view/cart_screen.dart';
import '../../features/catalog/view/catalog_screen.dart';
import '../../features/checkout/view/checkout_screen.dart';
import '../../features/home/view/home_screen.dart';
import '../../features/orders/view/orders_screen.dart';
import '../../features/product/view/product_details_screen.dart';
import '../../features/shell/view/app_shell.dart';
import '../../features/wishlist/view/wishlist_screen.dart';

/// App routes — path URLs (works on Firebase Hosting rewrites and `serve -s`).
GoRouter buildRouter() {
  return GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) => AppShell(
          location: state.matchedLocation,
          child: child,
        ),
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => const HomeScreen(),
          ),
          GoRoute(
            path: '/login',
            builder: (_, state) => LoginScreen(
              redirect: state.uri.queryParameters['redirect'],
            ),
          ),
          GoRoute(
            path: '/signup',
            builder: (_, state) => SignupScreen(
              redirect: state.uri.queryParameters['redirect'],
            ),
          ),
          GoRoute(
            path: '/catalog/:group',
            builder: (_, state) => CatalogScreen(
              group: state.pathParameters['group']!,
              query: state.uri.queryParameters['q'] ?? '',
            ),
          ),
          GoRoute(
            path: '/product/:id',
            builder: (_, state) =>
                ProductDetailsScreen(id: state.pathParameters['id']!),
          ),
          GoRoute(
            path: '/cart',
            builder: (_, _) => const CartScreen(),
          ),
          GoRoute(
            path: '/wishlist',
            builder: (_, _) => const WishlistScreen(),
          ),
          GoRoute(
            path: '/checkout',
            builder: (_, _) => const CheckoutScreen(),
          ),
          GoRoute(
            path: '/orders',
            builder: (_, state) =>
                OrdersScreen(justPlaced: state.uri.queryParameters['placed'] == '1'),
          ),
        ],
      ),
    ],
  );
}
