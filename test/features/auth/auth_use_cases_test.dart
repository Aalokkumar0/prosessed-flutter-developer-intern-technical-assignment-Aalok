import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/features/auth/domain/auth_use_cases.dart';
import 'package:shopsphere/features/auth/domain/user.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

const user = User(
  id: 1,
  firstName: 'Emily',
  lastName: 'Johnson',
  email: 'emily@example.com',
  phone: '123',
  image: 'avatar',
);

void main() {
  test('login authenticates and then fetches /auth/me profile', () async {
    final repository = MockAuthRepository();
    final useCases = AuthUseCases(repository);
    when(
      () => repository.login(
        username: any(named: 'username'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => user);
    when(repository.getCurrentUser).thenAnswer((_) async => user);

    final result = await useCases.login(
      username: 'emilys',
      password: 'emilyspass',
    );

    expect(result, user);
    verify(repository.getCurrentUser).called(1);
  });
}
