import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/core/error/app_failure.dart';
import 'package:shopsphere/core/network/api_client.dart';
import 'package:shopsphere/features/products/data/products_repository_impl.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late MockApiClient client;
  late ProductsRepositoryImpl repository;

  const productJson = <String, dynamic>{
    'id': 1,
    'title': 'Phone',
    'description': 'Description',
    'price': 499,
    'discountPercentage': 5,
    'rating': 4.5,
    'stock': 8,
    'thumbnail': 'image',
    'images': <dynamic>[],
    'reviews': <dynamic>[],
  };

  setUp(() {
    client = MockApiClient();
    repository = ProductsRepositoryImpl(client);
  });

  test('maps a successful paginated response', () async {
    when(
      () => client.get(
        '/products',
        authenticated: false,
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenAnswer(
      (_) async => {
        'products': [productJson],
        'total': 1,
        'skip': 0,
        'limit': 20,
      },
    );

    final page = await repository.getProducts(skip: 0, limit: 20);

    expect(page.products.single.title, 'Phone');
    expect(page.total, 1);
  });

  test('uses the search endpoint for a non-empty query', () async {
    when(
      () => client.get(
        '/products/search',
        authenticated: false,
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenAnswer(
      (_) async => {
        'products': <dynamic>[],
        'total': 0,
        'skip': 0,
        'limit': 20,
      },
    );

    await repository.getProducts(skip: 0, limit: 20, search: 'phone');

    verify(
      () => client.get(
        '/products/search',
        authenticated: false,
        queryParameters: any(named: 'queryParameters'),
      ),
    ).called(1);
  });

  test('propagates a typed server failure', () async {
    when(
      () => client.get(
        '/products',
        authenticated: false,
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenThrow(
      const AppFailure('Server unavailable', type: FailureType.server),
    );

    expect(
      () => repository.getProducts(skip: 0, limit: 20),
      throwsA(
        isA<AppFailure>().having(
          (failure) => failure.type,
          'type',
          FailureType.server,
        ),
      ),
    );
  });

  test('propagates a typed network failure', () async {
    when(
      () => client.get(
        '/products',
        authenticated: false,
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenThrow(const AppFailure('Offline', type: FailureType.network));

    expect(
      () => repository.getProducts(skip: 0, limit: 20),
      throwsA(
        isA<AppFailure>().having(
          (failure) => failure.type,
          'type',
          FailureType.network,
        ),
      ),
    );
  });
}
