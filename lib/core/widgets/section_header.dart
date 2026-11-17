import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// "New In ---------- View all →" section header used on the home page.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.onViewAll,
    this.titleColor = AppColors.ink,
  });

  final String title;
  final VoidCallback? onViewAll;
  final Color titleColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            color: titleColor,
          ),
        ),
        const SizedBox(width: 16),
        const Expanded(child: Divider()),
        if (onViewAll != null)
          TextButton(
            onPressed: onViewAll,
            child: const Text('View all'),
          ),
      ],
    );
  }
}
