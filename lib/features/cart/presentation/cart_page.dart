import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/widgets/state_views.dart';
import '../../auth/presentation/auth_cubit.dart';
import 'cart_cubit.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.simpleCurrency(name: 'USD');
    return BlocConsumer<CartCubit, CartState>(
      listener: (context, state) {
        if (state.status == CartStatus.success) {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const OrderSuccessPage()));
          context.read<CartCubit>().acknowledgeSuccess();
        }
        if (state.status == CartStatus.failure && state.message != null) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.message!)));
        }
      },
      builder: (context, state) {
        if (state.items.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: Text('Your bag')),
            body: EmptyStateView(
              title: 'Your bag is empty',
              message: 'Explore the catalogue and add something you love.',
              icon: Icons.shopping_bag_outlined,
            ),
          );
        }
        return Scaffold(
          appBar: AppBar(title: const Text('Your bag')),
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final list = ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: state.items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (_, index) {
                    final item = state.items[index];
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: CachedNetworkImage(
                                imageUrl: item.product.thumbnail,
                                width: 90,
                                height: 90,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.product.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    currency.format(item.total),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      _QuantityButton(
                                        icon: Icons.remove,
                                        tooltip: 'Decrease quantity',
                                        onPressed: () => context
                                            .read<CartCubit>()
                                            .updateQuantity(
                                              item.product.id,
                                              item.quantity - 1,
                                            ),
                                      ),
                                      SizedBox(
                                        width: 40,
                                        child: Text(
                                          '${item.quantity}',
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      _QuantityButton(
                                        icon: Icons.add,
                                        tooltip: 'Increase quantity',
                                        onPressed:
                                            item.quantity < item.product.stock
                                            ? () => context
                                                  .read<CartCubit>()
                                                  .updateQuantity(
                                                    item.product.id,
                                                    item.quantity + 1,
                                                  )
                                            : null,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              tooltip: 'Remove item',
                              onPressed: () => context.read<CartCubit>().remove(
                                item.product.id,
                              ),
                              icon: const Icon(Icons.delete_outline),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
                final summary = _OrderSummary(state: state, currency: currency);
                if (constraints.maxWidth >= 850) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: list),
                      SizedBox(width: 360, child: summary),
                    ],
                  );
                }
                return Column(
                  children: [
                    Expanded(child: list),
                    summary,
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _QuantityButton extends StatelessWidget {
  const _QuantityButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => IconButton.filledTonal(
    constraints: const BoxConstraints.tightFor(width: 40, height: 40),
    tooltip: tooltip,
    onPressed: onPressed,
    icon: Icon(icon, size: 18),
  );
}

class _OrderSummary extends StatelessWidget {
  const _OrderSummary({required this.state, required this.currency});
  final CartState state;
  final NumberFormat currency;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(20),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _row('Subtotal', currency.format(state.subtotal)),
            const SizedBox(height: 8),
            _row(
              'Discount',
              '-${currency.format(state.discount)}',
              color: Theme.of(context).colorScheme.secondary,
            ),
            const Divider(height: 28),
            _row('Total', currency.format(state.total), bold: true),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: state.status == CartStatus.submitting
                    ? null
                    : () {
                        final userId = context.read<AuthCubit>().state.user?.id;
                        if (userId != null) {
                          context.read<CartCubit>().checkout(userId);
                        }
                      },
                child: state.status == CartStatus.submitting
                    ? const SizedBox.square(
                        dimension: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Place order'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false, Color? color}) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
              fontSize: bold ? 19 : 14,
              color: color,
            ),
          ),
        ],
      );
}

class OrderSuccessPage extends StatelessWidget {
  const OrderSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    size: 56,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Order confirmed!',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Your simulated order was placed successfully.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Continue shopping'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
