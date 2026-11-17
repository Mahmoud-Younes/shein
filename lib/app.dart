import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/cart_repository.dart';
import 'data/repositories/order_repository.dart';
import 'data/repositories/product_repository.dart';
import 'data/repositories/wishlist_repository.dart';
import 'features/auth/viewmodel/auth_cubit.dart';
import 'features/cart/viewmodel/cart_cubit.dart';
import 'features/orders/viewmodel/orders_cubit.dart';
import 'features/wishlist/viewmodel/wishlist_cubit.dart';

/// App root — DI composition: repositories (Model) are provided once,
/// global cubits (ViewModels) subscribe to auth, router drives the views.
class SheinApp extends StatelessWidget {
  SheinApp({super.key});

  final GoRouter _router = buildRouter();

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => AuthRepository(FirebaseAuth.instance)),
        RepositoryProvider(create: (_) => ProductRepository(FirebaseFirestore.instance)),
        RepositoryProvider(create: (_) => CartRepository(FirebaseFirestore.instance)),
        RepositoryProvider(create: (_) => WishlistRepository(FirebaseFirestore.instance)),
        RepositoryProvider(create: (_) => OrderRepository(FirebaseFirestore.instance)),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => AuthCubit(context.read<AuthRepository>())),
          BlocProvider(
            create: (context) => CartCubit(
              context.read<AuthRepository>(),
              context.read<CartRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => WishlistCubit(
              context.read<AuthRepository>(),
              context.read<WishlistRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => OrdersCubit(
              context.read<AuthRepository>(),
              context.read<OrderRepository>(),
            ),
          ),
        ],
        child: MaterialApp.router(
          title: 'SHEIN — Online Fashion Store',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          routerConfig: _router,
        ),
      ),
    );
  }
}
