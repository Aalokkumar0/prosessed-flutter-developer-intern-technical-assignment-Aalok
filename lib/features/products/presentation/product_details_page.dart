import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/error/app_failure.dart';
import '../../../core/widgets/state_views.dart';
import '../../cart/presentation/cart_cubit.dart';
import '../domain/product.dart';

class ProductDetailsPage extends StatefulWidget {
  const ProductDetailsPage({required this.productId, this.preview, super.key});

  final int productId;
  final Product? preview;

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  late Future<Product> _product;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _product = getIt<ProductsRepository>().getProduct(widget.productId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product details')),
      body: FutureBuilder<Product>(
        future: _product,
        initialData: widget.preview,
        builder: (context, snapshot) {
          if (snapshot.hasError && snapshot.data == null) {
            final message = snapshot.error is AppFailure
                ? (snapshot.error! as AppFailure).message
                : 'Unable to load this product.';
            return ErrorStateView(
              message: message,
              onRetry: () => setState(_load),
            );
          }
          final product = snapshot.data;
          if (product == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return _DetailsContent(
            product: product,
            quantity: _quantity,
            onQuantityChanged: (value) => setState(() => _quantity = value),
          );
        },
      ),
    );
  }
}

class _DetailsContent extends StatelessWidget {
  const _DetailsContent({
    required this.product,
    required this.quantity,
    required this.onQuantityChanged,
  });

  final Product product;
  final int quantity;
  final ValueChanged<int> onQuantityChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;
        final gallery = _ProductGallery(product: product);
        final information = _ProductInformation(
          product: product,
          quantity: quantity,
          onQuantityChanged: onQuantityChanged,
        );
        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: gallery),
              const VerticalDivider(width: 1),
              Expanded(child: SingleChildScrollView(child: information)),
            ],
          );
        }
        return ListView(children: [gallery, information]);
      },
    );
  }
}

class _ProductGallery extends StatefulWidget {
  const _ProductGallery({required this.product});

  final Product product;

  @override
  State<_ProductGallery> createState() => _ProductGalleryState();
}

class _ProductGalleryState extends State<_ProductGallery> {
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    final images = widget.product.images.isEmpty
        ? [widget.product.thumbnail]
        : widget.product.images;
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1.05,
          child: PageView.builder(
            itemCount: images.length,
            onPageChanged: (index) => setState(() => _page = index),
            itemBuilder: (_, index) => Hero(
              tag: index == 0
                  ? 'product-${widget.product.id}'
                  : 'product-${widget.product.id}-$index',
              child: CachedNetworkImage(
                imageUrl: images[index],
                fit: BoxFit.contain,
                placeholder: (_, _) =>
                    const ColoredBox(color: Color(0xFFF0ECE7)),
                errorWidget: (_, _, _) =>
                    const Icon(Icons.broken_image_outlined, size: 56),
              ),
            ),
          ),
        ),
        if (images.length > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              images.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: _page == index ? 22 : 7,
                height: 7,
                margin: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: _page == index
                      ? Theme.of(context).colorScheme.primary
                      : Colors.black12,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ProductInformation extends StatelessWidget {
  const _ProductInformation({
    required this.product,
    required this.quantity,
    required this.onQuantityChanged,
  });

  final Product product;
  final int quantity;
  final ValueChanged<int> onQuantityChanged;

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.simpleCurrency(name: 'USD');
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (product.brand?.isNotEmpty ?? false)
            Text(
              product.brand!.toUpperCase(),
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          const SizedBox(height: 8),
          Text(
            product.title,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Text(
                currency.format(product.price),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(width: 12),
              if (product.discountPercentage > 0)
                Text(
                  currency.format(product.originalPrice),
                  style: const TextStyle(
                    decoration: TextDecoration.lineThrough,
                    color: Colors.black45,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.star_rounded, color: Color(0xFFFFB703)),
              Text('${product.rating.toStringAsFixed(1)}  •  '),
              Text(
                product.isInStock
                    ? '${product.stock} in stock'
                    : 'Out of stock',
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            product.description,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              IconButton.filledTonal(
                tooltip: 'Decrease quantity',
                onPressed: quantity > 1
                    ? () => onQuantityChanged(quantity - 1)
                    : null,
                icon: const Icon(Icons.remove),
              ),
              SizedBox(
                width: 48,
                child: Text(
                  '$quantity',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              IconButton.filledTonal(
                tooltip: 'Increase quantity',
                onPressed: quantity < product.stock
                    ? () => onQuantityChanged(quantity + 1)
                    : null,
                icon: const Icon(Icons.add),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FilledButton.icon(
                  onPressed: product.isInStock
                      ? () {
                          context.read<CartCubit>().add(
                            product,
                            quantity: quantity,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Added to your bag')),
                          );
                        }
                      : null,
                  icon: const Icon(Icons.shopping_bag_outlined),
                  label: Text(
                    product.isInStock ? 'Add to cart' : 'Out of stock',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 34),
          Text(
            'Customer reviews',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          if (product.reviews.isEmpty)
            const Text('No reviews yet.')
          else
            ...product.reviews.map(
              (review) => Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  title: Text(review.reviewerName),
                  subtitle: Text(review.comment),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.star,
                        size: 17,
                        color: Color(0xFFFFB703),
                      ),
                      Text('${review.rating}'),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
