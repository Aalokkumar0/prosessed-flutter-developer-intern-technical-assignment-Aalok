import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopsphere/features/products/domain/product.dart';
import 'package:shopsphere/features/wishlist/data/wishlist_repository_impl.dart';
import 'package:shopsphere/features/wishlist/presentation/wishlist_cubit.dart';

const product = Product(
  id: 4,
  title: 'Saved item',
  description: 'Description',
  price: 25,
  discountPercentage: 0,
  rating: 4,
  stock: 3,
  thumbnail: 'image',
  images: [],
  reviews: [],
);

void main() {
  test('wishlist persists products across repository instances', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final repository = WishlistRepositoryImpl(preferences);
    await repository.save(const [product]);

    final restored = await WishlistRepositoryImpl(preferences).load();

    expect(restored.single, product);
  });

  test('toggle adds a product to favourites', () async {
    SharedPreferences.setMockInitialValues({});
    final cubit = WishlistCubit(
      WishlistRepositoryImpl(await SharedPreferences.getInstance()),
    );

    await cubit.toggle(product);

    expect(cubit.state.contains(product.id), isTrue);
  });

  test('toggle removes an existing favourite', () async {
    SharedPreferences.setMockInitialValues({});
    final repository = WishlistRepositoryImpl(
      await SharedPreferences.getInstance(),
    );
    final cubit = WishlistCubit(repository);
    await cubit.toggle(product);

    await cubit.toggle(product);

    expect(cubit.state.products, isEmpty);
  });
}
