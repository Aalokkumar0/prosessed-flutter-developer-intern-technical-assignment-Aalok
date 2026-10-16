import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/core/error/app_failure.dart';
import 'package:shopsphere/core/network/api_client.dart';
import 'package:shopsphere/core/network/session_store.dart';
import 'package:shopsphere/features/auth/data/auth_repository_impl.dart';

class MockApiClient extends Mock implements ApiClient {}

class MockSessionStore extends Mock implements SessionStore {}

void main() {
  late MockApiClient client;
  late MockSessionStore sessionStore;
  late AuthRepositoryImpl repository;

  const loginJson = <String, dynamic>{
    'id': 1,
    'firstName': 'Emily',
    'lastName': 'Johnson',
    'email': 'emily@example.com',
    'phone': '123',
    'image': 'avatar',
    'accessToken': 'access',
    'refreshToken': 'refresh',
  };

  setUp(() {
    client = MockApiClient();
    sessionStore = MockSessionStore();
    repository = AuthRepositoryImpl(client, sessionStore);
  });

  test('login maps user and stores both tokens', () async {
    when(
      () => client.post(
        '/auth/login',
        authenticated: false,
        data: any(named: 'data'),
      ),
    ).thenAnswer((_) async => loginJson);
    when(
      () => sessionStore.saveTokens(
        accessToken: any(named: 'accessToken'),
        refreshToken: any(named: 'refreshToken'),
      ),
    ).thenAnswer((_) async {});

    final user = await repository.login(
      username: 'emilys',
      password: 'emilyspass',
    );

    expect(user.fullName, 'Emily Johnson');
    verify(
      () => sessionStore.saveTokens(
        accessToken: 'access',
        refreshToken: 'refresh',
      ),
    ).called(1);
  });

  test('login propagates a typed invalid-credentials failure', () async {
    when(
      () => client.post(
        '/auth/login',
        authenticated: false,
        data: any(named: 'data'),
      ),
    ).thenThrow(const AppFailure('Invalid credentials'));

    expect(
      () => repository.login(username: 'wrong', password: 'password'),
      throwsA(isA<AppFailure>()),
    );
  });

  test('getCurrentUser maps the protected profile response', () async {
    when(() => client.get('/auth/me')).thenAnswer((_) async => loginJson);

    final user = await repository.getCurrentUser();

    expect(user.email, 'emily@example.com');
    verify(() => client.get('/auth/me')).called(1);
  });
}
