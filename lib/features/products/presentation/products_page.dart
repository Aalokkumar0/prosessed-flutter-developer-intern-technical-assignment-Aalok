import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/widgets/state_views.dart';
import '../domain/product.dart';
import 'product_card.dart';
import 'product_details_page.dart';
import 'products_cubit.dart';

class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ProductsCubit>()..load(),
      child: const _ProductsView(),
    );
  }
}

class _ProductsView extends StatefulWidget {
  const _ProductsView();

  @override
  State<_ProductsView> createState() => _ProductsViewState();
}

class _ProductsViewState extends State<_ProductsView> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.extentAfter < 500) {
      context.read<ProductsCubit>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductsCubit, ProductsState>(
      builder: (context, state) {
        return CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar.large(
              pinned: true,
              title: const Text('Discover'),
              actions: [
                PopupMenuButton<ProductSort>(
                  tooltip: 'Sort products',
                  initialValue: state.sort,
                  onSelected: context.read<ProductsCubit>().changeSort,
                  itemBuilder: (_) => ProductSort.values
                      .map(
                        (sort) =>
                            PopupMenuItem(value: sort, child: Text(sort.label)),
                      )
                      .toList(),
                  icon: const Icon(Icons.sort_rounded),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                child: TextField(
                  controller: _searchController,
                  onChanged: context.read<ProductsCubit>().search,
                  decoration: const InputDecoration(
                    hintText: 'Search products',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 52,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: const Text('All'),
                        selected: state.selectedCategory == null,
                        onSelected: (_) =>
                            context.read<ProductsCubit>().selectCategory(null),
                      ),
                    ),
                    ...state.categories.map(
                      (category) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(_titleCase(category)),
                          selected: state.selectedCategory == category,
                          onSelected: (_) {
                            _searchController.clear();
                            context.read<ProductsCubit>().selectCategory(
                              category,
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ..._contentSlivers(state),
          ],
        );
      },
    );
  }

  List<Widget> _contentSlivers(ProductsState state) {
    if (state.status == ProductsStatus.loading && state.products.isEmpty) {
      return const [SliverFillRemaining(child: ProductSkeleton())];
    }
    if (state.status == ProductsStatus.failure && state.products.isEmpty) {
      return [
        SliverFillRemaining(
          child: ErrorStateView(
            message: state.message ?? 'Unable to load products.',
            onRetry: context.read<ProductsCubit>().load,
          ),
        ),
      ];
    }
    if (state.status == ProductsStatus.empty) {
      return const [
        SliverFillRemaining(
          child: EmptyStateView(
            title: 'Nothing found',
            message: 'Try a different search or category.',
          ),
        ),
      ];
    }
    return [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        sliver: SliverLayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.crossAxisExtent >= 1024
                ? 5
                : constraints.crossAxisExtent >= 600
                ? 3
                : 2;
            return SliverGrid.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: columns >= 3 ? .72 : .66,
              ),
              itemCount: state.products.length,
              itemBuilder: (_, index) {
                final product = state.products[index];
                return ProductCard(
                  product: product,
                  onTap: () => _openDetails(product),
                );
              },
            );
          },
        ),
      ),
      if (state.isLoadingMore)
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          ),
        ),
    ];
  }

  void _openDetails(Product product) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            ProductDetailsPage(productId: product.id, preview: product),
      ),
    );
  }

  String _titleCase(String value) => value
      .split('-')
      .map(
        (part) => part.isEmpty
            ? part
            : '${part[0].toUpperCase()}${part.substring(1)}',
      )
      .join(' ');
}
