import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopsphere/core/network/api_client.dart';
import 'package:shopsphere/features/cart/data/cart_repository_impl.dart';
import 'package:shopsphere/features/cart/domain/cart_item.dart';
import 'package:shopsphere/features/products/domain/product.dart';

class MockApiClient extends Mock implements ApiClient {}

const product = Product(
  id: 1,
  title: 'Phone',
  description: 'Description',
  price: 100,
  discountPercentage: 10,
  rating: 4.5,
  stock: 5,
  thumbnail: 'image',
  images: [],
  reviews: [],
);

void main() {
  late SharedPreferences preferences;
  late MockApiClient client;
  late CartRepositoryImpl repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();
    client = MockApiClient();
    repository = CartRepositoryImpl(preferences, client);
  });

  test('saves and restores cart items across repository instances', () async {
    await repository.save(const [CartItem(product: product, quantity: 2)]);

    final restored = await CartRepositoryImpl(preferences, client).load();

    expect(restored.single.product.title, 'Phone');
    expect(restored.single.quantity, 2);
  });

  test('returns an empty cart when nothing was persisted', () async {
    expect(await repository.load(), isEmpty);
  });

  test('posts the expected checkout payload', () async {
    when(() => client.post('/carts/add', data: any(named: 'data')))
        .thenAnswer((_) async => <String, dynamic>{'id': 1});

    await repository.placeOrder(
      userId: 7,
      items: const [CartItem(product: product, quantity: 2)],
    );

    final captured =
        verify(() => client.post('/carts/add', data: captureAny(named: 'data')))
                .captured
                .single
            as Map<String, dynamic>;
    expect(captured['userId'], 7);
    expect((captured['products'] as List).single, {'id': 1, 'quantity': 2});
  });
}
