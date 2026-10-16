import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/error/app_failure.dart';
import '../../products/domain/product.dart';
import '../domain/cart_item.dart';

enum CartStatus { initial, ready, submitting, success, failure }

class CartState extends Equatable {
  const CartState({
    this.status = CartStatus.initial,
    this.items = const [],
    this.message,
  });

  final CartStatus status;
  final List<CartItem> items;
  final String? message;

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
  double get subtotal => items.fold(0, (sum, item) => sum + item.subtotal);
  double get discount => items.fold(0, (sum, item) => sum + item.discount);
  double get total => items.fold(0, (sum, item) => sum + item.total);

  @override
  List<Object?> get props => [status, items, message];
}

class CartCubit extends Cubit<CartState> {
  CartCubit(this._repository) : super(const CartState());

  final CartRepository _repository;

  Future<void> load() async {
    final items = await _repository.load();
    emit(CartState(status: CartStatus.ready, items: items));
  }

  Future<void> add(Product product, {int quantity = 1}) async {
    final items = [...state.items];
    final index = items.indexWhere((item) => item.product.id == product.id);
    if (index == -1) {
      items.add(
        CartItem(product: product, quantity: quantity.clamp(1, product.stock)),
      );
    } else {
      final next = (items[index].quantity + quantity).clamp(1, product.stock);
      items[index] = items[index].copyWith(quantity: next);
    }
    await _commit(items);
  }

  Future<void> updateQuantity(int productId, int quantity) async {
    if (quantity < 1) return remove(productId);
    final items = state.items
        .map((item) {
          if (item.product.id != productId) return item;
          return item.copyWith(quantity: quantity.clamp(1, item.product.stock));
        })
        .toList(growable: false);
    await _commit(items);
  }

  Future<void> remove(int productId) => _commit(
    state.items
        .where((item) => item.product.id != productId)
        .toList(growable: false),
  );

  Future<void> checkout(int userId) async {
    if (state.items.isEmpty) return;
    emit(CartState(status: CartStatus.submitting, items: state.items));
    try {
      await _repository.placeOrder(userId: userId, items: state.items);
      await _repository.save(const []);
      emit(
        const CartState(
          status: CartStatus.success,
          message: 'Your order has been placed.',
        ),
      );
    } on AppFailure catch (failure) {
      emit(
        CartState(
          status: CartStatus.failure,
          items: state.items,
          message: failure.message,
        ),
      );
    }
  }

  void acknowledgeSuccess() => emit(const CartState(status: CartStatus.ready));

  Future<void> _commit(List<CartItem> items) async {
    await _repository.save(items);
    emit(CartState(status: CartStatus.ready, items: items));
  }
}
