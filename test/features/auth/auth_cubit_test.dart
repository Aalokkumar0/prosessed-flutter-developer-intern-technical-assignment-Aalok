import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/core/error/app_failure.dart';
import 'package:shopsphere/features/auth/domain/auth_use_cases.dart';
import 'package:shopsphere/features/auth/domain/user.dart';
import 'package:shopsphere/features/auth/presentation/auth_cubit.dart';

class MockAuthUseCases extends Mock implements AuthUseCases {}

const user = User(
  id: 1,
  firstName: 'Aalok',
  lastName: 'kumar',
  email: 'emily@example.com',
  phone: '1234567890',
  image: 'avatar',
);

void main() {
  late MockAuthUseCases useCases;

  setUp(() {
    useCases = MockAuthUseCases();
  });

  blocTest<AuthCubit, AuthState>(
    'routes to login when no session is stored',
    build: () {
      when(useCases.hasSession).thenAnswer((_) async => false);
      return AuthCubit(useCases);
    },
    act: (cubit) => cubit.restoreSession(),
    expect: () => [const AuthState(status: AuthStatus.unauthenticated)],
  );

  blocTest<AuthCubit, AuthState>(
    'restores a valid session',
    build: () {
      when(useCases.hasSession).thenAnswer((_) async => true);
      when(useCases.restoreSession).thenAnswer((_) async => user);
      return AuthCubit(useCases);
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
        () => useCases.login(
          username: any(named: 'username'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => user);
      return AuthCubit(useCases);
    },
    act: (cubit) => cubit.login(username: ' emilys ', password: 'emilyspass'),
    expect: () => [
      const AuthState(status: AuthStatus.checking),
      const AuthState(status: AuthStatus.authenticated, user: user),
    ],
    verify: (_) =>
        verify(() => useCases.login(username: 'emilys', password: 'emilyspass'))
            .called(1),
  );

  blocTest<AuthCubit, AuthState>(
    'shows friendly copy for invalid credentials',
    build: () {
      when(
        () => useCases.login(
          username: any(named: 'username'),
          password: any(named: 'password'),
        ),
      ).thenThrow(const AppFailure('Invalid credentials'));
      return AuthCubit(useCases);
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
      when(useCases.logout).thenAnswer((_) async {});
      return AuthCubit(useCases);
    },
    seed: () => const AuthState(status: AuthStatus.authenticated, user: user),
    act: (cubit) => cubit.logout(),
    expect: () => [const AuthState(status: AuthStatus.unauthenticated)],
    verify: (_) => verify(useCases.logout).called(1),
  );
}
