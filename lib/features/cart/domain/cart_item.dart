import 'package:equatable/equatable.dart';

import '../../products/domain/product.dart';

class CartItem extends Equatable {
  const CartItem({required this.product, required this.quantity});

  final Product product;
  final int quantity;

  double get subtotal => product.originalPrice * quantity;
  double get total => product.price * quantity;
  double get discount => subtotal - total;

  CartItem copyWith({int? quantity}) =>
      CartItem(product: product, quantity: quantity ?? this.quantity);

  @override
  List<Object?> get props => [product, quantity];
}

abstract interface class CartRepository {
  Future<List<CartItem>> load();
  Future<void> save(List<CartItem> items);
  Future<void> placeOrder({required int userId, required List<CartItem> items});
}
