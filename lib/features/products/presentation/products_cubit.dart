import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/error/app_failure.dart';
import '../domain/product.dart';
import '../domain/product_use_cases.dart';

enum ProductsStatus { initial, loading, success, empty, failure }

enum ProductSort {
  relevance('Relevance', null, 'asc'),
  priceLow('Price: low to high', 'price', 'asc'),
  priceHigh('Price: high to low', 'price', 'desc'),
  rating('Top rated', 'rating', 'desc'),
  title('Title', 'title', 'asc');

  const ProductSort(this.label, this.field, this.order);
  final String label;
  final String? field;
  final String order;
}

class ProductsState extends Equatable {
  const ProductsState({
    this.status = ProductsStatus.initial,
    this.products = const [],
    this.categories = const [],
    this.selectedCategory,
    this.search = '',
    this.sort = ProductSort.relevance,
    this.total = 0,
    this.isLoadingMore = false,
    this.message,
  });

  final ProductsStatus status;
  final List<Product> products;
  final List<String> categories;
  final String? selectedCategory;
  final String search;
  final ProductSort sort;
  final int total;
  final bool isLoadingMore;
  final String? message;

  bool get canLoadMore => products.length < total && !isLoadingMore;

  ProductsState copyWith({
    ProductsStatus? status,
    List<Product>? products,
    List<String>? categories,
    String? selectedCategory,
    bool clearCategory = false,
    String? search,
    ProductSort? sort,
    int? total,
    bool? isLoadingMore,
    String? message,
  }) => ProductsState(
    status: status ?? this.status,
    products: products ?? this.products,
    categories: categories ?? this.categories,
    selectedCategory: clearCategory
        ? null
        : selectedCategory ?? this.selectedCategory,
    search: search ?? this.search,
    sort: sort ?? this.sort,
    total: total ?? this.total,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    message: message,
  );

  @override
  List<Object?> get props => [
    status,
    products,
    categories,
    selectedCategory,
    search,
    sort,
    total,
    isLoadingMore,
    message,
  ];
}

class ProductsCubit extends Cubit<ProductsState> {
  ProductsCubit(this._useCases) : super(const ProductsState());

  static const _pageSize = 20;
  final ProductUseCases _useCases;
  Timer? _searchTimer;

  Future<void> load({bool refresh = false}) async {
    if (state.status == ProductsStatus.loading && !refresh) return;
    emit(
      state.copyWith(
        status: ProductsStatus.loading,
        products: refresh ? const [] : state.products,
      ),
    );
    try {
      final results = await Future.wait([
        _useCases.getProducts(
          skip: 0,
          limit: _pageSize,
          search: state.search,
          category: state.selectedCategory,
          sortBy: state.sort.field,
          order: state.sort.order,
        ),
        if (state.categories.isEmpty) _useCases.getCategories(),
      ]);
      final page = results.first as ProductPage;
      final categories = results.length > 1
          ? results[1] as List<String>
          : state.categories;
      emit(
        state.copyWith(
          status: page.products.isEmpty
              ? ProductsStatus.empty
              : ProductsStatus.success,
          products: page.products,
          total: page.total,
          categories: categories,
        ),
      );
    } on AppFailure catch (failure) {
      emit(
        state.copyWith(
          status: ProductsStatus.failure,
          message: failure.message,
        ),
      );
    }
  }

  Future<void> loadMore() async {
    if (!state.canLoadMore || state.status != ProductsStatus.success) return;
    emit(state.copyWith(isLoadingMore: true));
    try {
      final page = await _useCases.getProducts(
        skip: state.products.length,
        limit: _pageSize,
        search: state.search,
        category: state.selectedCategory,
        sortBy: state.sort.field,
        order: state.sort.order,
      );
      emit(
        state.copyWith(
          products: [...state.products, ...page.products],
          total: page.total,
          isLoadingMore: false,
        ),
      );
    } on AppFailure catch (failure) {
      emit(state.copyWith(isLoadingMore: false, message: failure.message));
    }
  }

  void search(String query) {
    _searchTimer?.cancel();
    _searchTimer = Timer(const Duration(milliseconds: 400), () {
      emit(
        state.copyWith(
          search: query.trim(),
          clearCategory: query.trim().isNotEmpty,
        ),
      );
      load(refresh: true);
    });
  }

  void selectCategory(String? category) {
    emit(
      state.copyWith(
        selectedCategory: category,
        clearCategory: category == null,
        search: '',
      ),
    );
    load(refresh: true);
  }

  void changeSort(ProductSort sort) {
    emit(state.copyWith(sort: sort));
    load(refresh: true);
  }

  @override
  Future<void> close() {
    _searchTimer?.cancel();
    return super.close();
  }
}
