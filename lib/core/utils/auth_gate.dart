import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/viewmodel/auth_cubit.dart';

/// Guards actions that need an account: when the user is a guest, shows a
/// snackbar with a "Sign In" shortcut and returns false.
bool requireAuth(BuildContext context, {String? redirect}) {
  final authenticated = context.read<AuthCubit>().state.isAuthenticated;
  if (authenticated) return true;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: const Text('Please sign in to continue.'),
      action: SnackBarAction(
        label: 'Sign In',
        onPressed: () => context.go(Uri(
              path: '/login',
              queryParameters: {'redirect': ?redirect},
            ).toString()),
      ),
    ),
  );
  return false;
}
