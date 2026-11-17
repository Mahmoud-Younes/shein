import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/page_states.dart';
import '../../../core/widgets/product_grid.dart';
import '../viewmodel/catalog_cubit.dart';
import '../viewmodel/catalog_filter.dart';
import '../viewmodel/catalog_state.dart';

/// Category / search results page, e.g. `/catalog/women?q=dress`.
class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key, required this.group, this.query = ''});

  final String group;
  final String query;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CatalogCubit>(
      key: ValueKey('catalog-$group-$query'),
      create: (context) => CatalogCubit(context.read())..load(group, query: query),
      child: BlocBuilder<CatalogCubit, CatalogState>(
        builder: (context, state) => switch (state.status) {
          CatalogStatus.loading => const LoadingView(label: 'Loading products…'),
          CatalogStatus.error => ErrorView(
              message: state.error ?? '',
              onRetry: () => context.read<CatalogCubit>().load(group, query: query),
            ),
          CatalogStatus.ready => _CatalogView(state: state),
        },
      ),
    );
  }
}

class _CatalogView extends StatelessWidget {
  const _CatalogView({required this.state});

  final CatalogState state;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1440),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _header(context),
              if (state.categoryLabels.isNotEmpty) ...[
                const SizedBox(height: 6),
                _categoryChips(context),
              ],
              const SizedBox(height: 12),
              Expanded(
                child: state.visible.isEmpty
                    ? const EmptyView(
                        icon: Icons.search_off_rounded,
                        title: 'No products found',
                        subtitle: 'Try a different search term or category.',
                      )
                    : SingleChildScrollView(
                        child: ProductGrid(products: state.visible),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              state.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 2),
            Text(
              state.query.isNotEmpty
                  ? '${state.visible.length} results for "${state.query}"'
                  : '${state.visible.length} items',
              style: const TextStyle(color: AppColors.textGrey, fontSize: 13),
            ),
          ],
        ),
        const Spacer(),
        const Text('Sort by', style: TextStyle(color: AppColors.textGrey, fontSize: 13)),
        const SizedBox(width: 8),
        DropdownButton<CatalogSort>(
          value: state.sort,
          underline: const SizedBox.shrink(),
          borderRadius: BorderRadius.zero,
          items: [
            for (final sort in CatalogSort.values)
              DropdownMenuItem(value: sort, child: Text(sort.label)),
          ],
          onChanged: (sort) {
            if (sort != null) context.read<CatalogCubit>().setSort(sort);
          },
        ),
      ],
    );
  }

  Widget _categoryChips(BuildContext context) {
    final cubit = context.read<CatalogCubit>();
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (final label in state.categoryLabels)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(label),
                selected: state.categoryLabel == label,
                onSelected: (_) => cubit.setCategory(label),
              ),
            ),
        ],
      ),
    );
  }
}
