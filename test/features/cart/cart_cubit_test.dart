import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/features/cart/domain/cart_item.dart';
import 'package:shopsphere/features/cart/presentation/cart_cubit.dart';
import 'package:shopsphere/features/products/domain/product.dart';

class MockCartRepository extends Mock implements CartRepository {}

const product = Product(
  id: 1,
  title: 'Test product',
  description: 'Description',
  price: 80,
  discountPercentage: 20,
  rating: 4.5,
  stock: 3,
  thumbnail: 'image',
  images: [],
  reviews: [],
);

void main() {
  late MockCartRepository repository;

  setUp(() {
    repository = MockCartRepository();
    when(() => repository.save(any())).thenAnswer((_) async {});
  });

  blocTest<CartCubit, CartState>(
    'loads persisted cart items',
    build: () {
      when(repository.load).thenAnswer(
        (_) async => const [CartItem(product: product, quantity: 2)],
      );
      return CartCubit(repository);
    },
    act: (cubit) => cubit.load(),
    expect: () => [
      const CartState(
        status: CartStatus.ready,
        items: [CartItem(product: product, quantity: 2)],
      ),
    ],
  );

  blocTest<CartCubit, CartState>(
    'adds a new product',
    build: () => CartCubit(repository),
    act: (cubit) => cubit.add(product),
    verify: (cubit) => expect(cubit.state.itemCount, 1),
  );

  blocTest<CartCubit, CartState>(
    'merges quantity for an existing product',
    build: () => CartCubit(repository),
    seed: () => const CartState(
      status: CartStatus.ready,
      items: [CartItem(product: product, quantity: 1)],
    ),
    act: (cubit) => cubit.add(product, quantity: 2),
    verify: (cubit) => expect(cubit.state.itemCount, 3),
  );

  blocTest<CartCubit, CartState>(
    'clamps quantity to available stock',
    build: () => CartCubit(repository),
    act: (cubit) => cubit.add(product, quantity: 20),
    verify: (cubit) => expect(cubit.state.itemCount, 3),
  );

  blocTest<CartCubit, CartState>(
    'removes a cart item',
    build: () => CartCubit(repository),
    seed: () => const CartState(
      status: CartStatus.ready,
      items: [CartItem(product: product, quantity: 1)],
    ),
    act: (cubit) => cubit.remove(product.id),
    verify: (cubit) => expect(cubit.state.items, isEmpty),
  );

  test('calculates subtotal, discount and total', () {
    const state = CartState(
      status: CartStatus.ready,
      items: [CartItem(product: product, quantity: 2)],
    );
    expect(state.subtotal, 200);
    expect(state.discount, 40);
    expect(state.total, 160);
  });

  blocTest<CartCubit, CartState>(
    'clears local cart after successful checkout',
    build: () {
      when(
        () => repository.placeOrder(
          userId: any(named: 'userId'),
          items: any(named: 'items'),
        ),
      ).thenAnswer((_) async {});
      return CartCubit(repository);
    },
    seed: () => const CartState(
      status: CartStatus.ready,
      items: [CartItem(product: product, quantity: 1)],
    ),
    act: (cubit) => cubit.checkout(1),
    expect: () => [
      const CartState(
        status: CartStatus.submitting,
        items: [CartItem(product: product, quantity: 1)],
      ),
      const CartState(
        status: CartStatus.success,
        message: 'Your order has been placed.',
      ),
    ],
  );
}
