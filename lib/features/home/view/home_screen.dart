import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/page_states.dart';
import '../../../core/widgets/product_grid.dart';
import '../../../core/widgets/section_header.dart';
import '../../../data/models/product_model.dart';
import '../viewmodel/home_cubit.dart';
import '../viewmodel/home_state.dart';

/// Store front: hero banner, category strip, New In / Best Sellers / Deals.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HomeCubit>(
      create: (context) => HomeCubit(context.read())..load(),
      child: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) => switch (state.status) {
          HomeStatus.loading => const LoadingView(label: 'Loading the store…'),
          HomeStatus.error => ErrorView(message: state.error ?? '', onRetry: () => context.read<HomeCubit>().retry()),
          HomeStatus.ready => _HomePageView(state: state),
        },
      ),
    );
  }
}

class _HomePageView extends StatelessWidget {
  const _HomePageView({required this.state});

  final HomeState state;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        const _HeroBanner(),
        const SizedBox(height: 8),
        const _CategoryStrip(),
        _section(
          context,
          title: 'New In',
          titleColor: AppColors.ink,
          viewAllGroup: 'new',
          products: state.newArrivals,
        ),
        _section(
          context,
          title: 'Best Sellers',
          viewAllGroup: 'all',
          products: state.bestSellers,
        ),
        _section(
          context,
          title: 'Sale — up to 70% off',
          titleColor: AppColors.saleRed,
          viewAllGroup: 'sale',
          products: state.deals,
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _section(
    BuildContext context, {
    required String title,
    required String viewAllGroup,
    required List<ProductModel> products,
    Color titleColor = AppColors.ink,
  }) {
    if (products.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1440),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                SectionHeader(
                  title: title,
                  titleColor: titleColor,
                  onViewAll: () => context.go('/catalog/$viewAllGroup'),
                ),
                const SizedBox(height: 14),
                ProductGrid(products: products),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 320,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF111111), Color(0xFF3A3A3A)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'NEW SEASON',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 6,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'BIG SALE',
              style: TextStyle(
                color: Colors.white,
                fontSize: 58,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
                height: 1,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Up to 70% off on fashion, beauty & accessories',
              style: TextStyle(color: Colors.white70, fontSize: 15),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  key: const Key('hero-shop-now'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.ink,
                  ),
                  onPressed: () => context.go('/catalog/sale'),
                  child: const Text('SHOP THE SALE'),
                ),
                const SizedBox(width: 14),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white, width: 1.4),
                  ),
                  onPressed: () => context.go('/catalog/new'),
                  child: const Text('NEW IN'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryStrip extends StatelessWidget {
  const _CategoryStrip();

  @override
  Widget build(BuildContext context) {
    const categories = [
      (Icons.checkroom_rounded, 'Women', 'women'),
      (Icons.man_rounded, 'Men', 'men'),
      (Icons.face_retouching_natural_rounded, 'Beauty', 'beauty'),
      (Icons.watch_rounded, 'Accessories', 'accessories'),
    ];

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        child: Wrap(
          spacing: 36,
          runSpacing: 16,
          alignment: WrapAlignment.center,
          children: [
            for (final (icon, label, group) in categories)
              _CategoryCircle(icon: icon, label: label, group: group),
            const _CategoryCircle(
              icon: Icons.local_offer_rounded,
              label: 'Sale',
              group: 'sale',
              highlight: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryCircle extends StatelessWidget {
  const _CategoryCircle({
    required this.icon,
    required this.label,
    required this.group,
    this.highlight = false,
  });

  final IconData icon;
  final String label;
  final String group;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.go('/catalog/$group'),
      borderRadius: BorderRadius.circular(48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: highlight ? AppColors.saleRed : AppColors.softGrey,
              border: Border.all(
                color: highlight ? AppColors.saleRed : AppColors.lineGrey,
              ),
            ),
            child: Icon(
              icon,
              size: 32,
              color: highlight ? Colors.white : AppColors.ink,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
