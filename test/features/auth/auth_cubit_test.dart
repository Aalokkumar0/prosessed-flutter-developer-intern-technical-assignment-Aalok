import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/core/error/app_failure.dart';
import 'package:shopsphere/features/auth/domain/user.dart';
import 'package:shopsphere/features/auth/presentation/auth_cubit.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

const user = User(
  id: 1,
  firstName: 'Emily',
  lastName: 'Johnson',
  email: 'emily@example.com',
  phone: '1234567890',
  image: 'avatar',
);

void main() {
  late MockAuthRepository repository;

  setUp(() {
    repository = MockAuthRepository();
  });

  blocTest<AuthCubit, AuthState>(
    'routes to login when no session is stored',
    build: () {
      when(repository.hasSession).thenAnswer((_) async => false);
      return AuthCubit(repository);
    },
    act: (cubit) => cubit.restoreSession(),
    expect: () => [const AuthState(status: AuthStatus.unauthenticated)],
  );

  blocTest<AuthCubit, AuthState>(
    'restores a valid session',
    build: () {
      when(repository.hasSession).thenAnswer((_) async => true);
      when(repository.getCurrentUser).thenAnswer((_) async => user);
      return AuthCubit(repository);
    },
    act: (cubit) => cubit.restoreSession(),
    expect: () => [
      const AuthState(status: AuthStatus.authenticated, user: user),
    ],
  );

  blocTest<AuthCubit, AuthState>(
    'emits authenticated state after login',
    build: () {
      when(
        () => repository.login(
          username: any(named: 'username'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => user);
      return AuthCubit(repository);
    },
    act: (cubit) => cubit.login(username: ' emilys ', password: 'emilyspass'),
    expect: () => [
      const AuthState(status: AuthStatus.checking),
      const AuthState(status: AuthStatus.authenticated, user: user),
    ],
    verify: (_) => verify(
      () => repository.login(username: 'emilys', password: 'emilyspass'),
    ).called(1),
  );

  blocTest<AuthCubit, AuthState>(
    'shows friendly copy for invalid credentials',
    build: () {
      when(
        () => repository.login(
          username: any(named: 'username'),
          password: any(named: 'password'),
        ),
      ).thenThrow(const AppFailure('Invalid credentials'));
      return AuthCubit(repository);
    },
    act: (cubit) => cubit.login(username: 'wrong', password: 'password'),
    expect: () => [
      const AuthState(status: AuthStatus.checking),
      const AuthState(
        status: AuthStatus.failure,
        message: 'Invalid username or password.',
      ),
    ],
  );

  blocTest<AuthCubit, AuthState>(
    'clears the stored session on logout',
    build: () {
      when(repository.logout).thenAnswer((_) async {});
      return AuthCubit(repository);
    },
    seed: () => const AuthState(status: AuthStatus.authenticated, user: user),
    act: (cubit) => cubit.logout(),
    expect: () => [const AuthState(status: AuthStatus.unauthenticated)],
    verify: (_) => verify(repository.logout).called(1),
  );
}
