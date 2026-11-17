import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_theme.dart';
import 'page_states.dart';

/// Shown on member-only pages (bag, wishlist, orders) when signed out.
class SignInPrompt extends StatelessWidget {
  const SignInPrompt({
    super.key,
    required this.title,
    required this.subtitle,
    this.redirect,
  });

  final String title;
  final String subtitle;
  final String? redirect;

  @override
  Widget build(BuildContext context) {
    return EmptyView(
      icon: Icons.lock_outline_rounded,
      title: title,
      subtitle: subtitle,
      actionLabel: 'SIGN IN',
      onAction: () => context.go(Uri(
            path: '/login',
            queryParameters: {'redirect': ?redirect},
          ).toString()),
    );
  }
}

/// Small grey hint shown at the bottom of guest prompts.
class GuestHint extends StatelessWidget {
  const GuestHint({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
    );
  }
}
