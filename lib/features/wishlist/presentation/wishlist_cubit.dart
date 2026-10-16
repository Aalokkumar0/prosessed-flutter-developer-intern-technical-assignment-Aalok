import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../products/domain/product.dart';
import '../domain/wishlist_repository.dart';

class WishlistState extends Equatable {
  const WishlistState({this.products = const []});

  final List<Product> products;

  bool contains(int productId) =>
      products.any((product) => product.id == productId);

  @override
  List<Object?> get props => [products];
}

class WishlistCubit extends Cubit<WishlistState> {
  WishlistCubit(this._repository) : super(const WishlistState());

  final WishlistRepository _repository;

  Future<void> load() async =>
      emit(WishlistState(products: await _repository.load()));

  Future<void> toggle(Product product) async {
    final products = [...state.products];
    final index = products.indexWhere((item) => item.id == product.id);
    if (index == -1) {
      products.add(product);
    } else {
      products.removeAt(index);
    }
    await _repository.save(products);
    emit(WishlistState(products: products));
  }
}
