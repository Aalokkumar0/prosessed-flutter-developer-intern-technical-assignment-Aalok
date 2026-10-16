import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/core/error/app_failure.dart';
import 'package:shopsphere/features/products/domain/product.dart';
import 'package:shopsphere/features/products/domain/product_use_cases.dart';
import 'package:shopsphere/features/products/presentation/products_cubit.dart';

class MockProductUseCases extends Mock implements ProductUseCases {}

const item = Product(
  id: 7,
  title: 'Phone',
  description: 'Description',
  price: 499,
  discountPercentage: 5,
  rating: 4.4,
  stock: 8,
  thumbnail: 'image',
  images: [],
  reviews: [],
);

void main() {
  late MockProductUseCases useCases;

  setUp(() {
    useCases = MockProductUseCases();
    when(useCases.getCategories)
        .thenAnswer((_) async => ['beauty', 'smartphones']);
  });

  void stubPage(ProductPage page) {
    when(
      () => useCases.getProducts(
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
        search: any(named: 'search'),
        category: any(named: 'category'),
        sortBy: any(named: 'sortBy'),
        order: any(named: 'order'),
      ),
    ).thenAnswer((_) async => page);
  }

  blocTest<ProductsCubit, ProductsState>(
    'loads first page and categories',
    build: () {
      stubPage(
        const ProductPage(products: [item], total: 1, skip: 0, limit: 20),
      );
      return ProductsCubit(useCases);
    },
    act: (cubit) => cubit.load(),
    verify: (cubit) {
      expect(cubit.state.status, ProductsStatus.success);
      expect(cubit.state.products, [item]);
      expect(cubit.state.categories, ['beauty', 'smartphones']);
    },
  );

  blocTest<ProductsCubit, ProductsState>(
    'emits dedicated empty state',
    build: () {
      stubPage(const ProductPage(products: [], total: 0, skip: 0, limit: 20));
      return ProductsCubit(useCases);
    },
    act: (cubit) => cubit.load(),
    verify: (cubit) => expect(cubit.state.status, ProductsStatus.empty),
  );

  blocTest<ProductsCubit, ProductsState>(
    'maps repository failure to failure state',
    build: () {
      when(
        () => useCases.getProducts(
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
          search: any(named: 'search'),
          category: any(named: 'category'),
          sortBy: any(named: 'sortBy'),
          order: any(named: 'order'),
        ),
      ).thenThrow(const AppFailure('Server unavailable'));
      return ProductsCubit(useCases);
    },
    act: (cubit) => cubit.load(),
    verify: (cubit) {
      expect(cubit.state.status, ProductsStatus.failure);
      expect(cubit.state.message, 'Server unavailable');
    },
  );

  blocTest<ProductsCubit, ProductsState>(
    'appends the next page',
    build: () {
      stubPage(
        const ProductPage(products: [item], total: 2, skip: 1, limit: 20),
      );
      return ProductsCubit(useCases);
    },
    seed: () => const ProductsState(
      status: ProductsStatus.success,
      products: [item],
      total: 2,
      categories: ['beauty'],
    ),
    act: (cubit) => cubit.loadMore(),
    verify: (cubit) => expect(cubit.state.products.length, 2),
  );

  blocTest<ProductsCubit, ProductsState>(
    'changes the selected sort',
    build: () {
      stubPage(
        const ProductPage(products: [item], total: 1, skip: 0, limit: 20),
      );
      return ProductsCubit(useCases);
    },
    act: (cubit) => cubit.changeSort(ProductSort.priceHigh),
    verify: (cubit) => expect(cubit.state.sort, ProductSort.priceHigh),
  );
}
