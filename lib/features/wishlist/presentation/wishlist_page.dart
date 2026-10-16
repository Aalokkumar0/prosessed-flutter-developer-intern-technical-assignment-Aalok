import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/widgets/state_views.dart';
import '../../products/presentation/product_card.dart';
import '../../products/presentation/product_details_page.dart';
import 'wishlist_cubit.dart';

class WishlistPage extends StatelessWidget {
  const WishlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    final products = context.watch<WishlistCubit>().state.products;
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.text('saved'))),
      body: products.isEmpty
          ? EmptyStateView(
              title: context.l10n.text('savedEmpty'),
              message: context.l10n.text('savedEmptyMessage'),
              icon: Icons.favorite_border_rounded,
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 1024
                    ? 5
                    : constraints.maxWidth >= 600
                    ? 3
                    : 2;
                return GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: columns >= 3 ? .72 : .66,
                  ),
                  itemCount: products.length,
                  itemBuilder: (_, index) {
                    final product = products[index];
                    return ProductCard(
                      product: product,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ProductDetailsPage(
                            productId: product.id,
                            preview: product,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
