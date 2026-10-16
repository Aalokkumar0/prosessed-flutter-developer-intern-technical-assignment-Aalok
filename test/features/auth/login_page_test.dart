import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/features/auth/domain/auth_use_cases.dart';
import 'package:shopsphere/features/auth/presentation/auth_cubit.dart';
import 'package:shopsphere/features/auth/presentation/login_page.dart';

class MockAuthUseCases extends Mock implements AuthUseCases {}

void main() {
  late MockAuthUseCases useCases;
  late AuthCubit cubit;

  setUp(() async {
    useCases = MockAuthUseCases();
    when(useCases.logout).thenAnswer((_) async {});
    cubit = AuthCubit(useCases);
    await cubit.logout();
  });

  Widget subject() => MaterialApp(
    home: BlocProvider.value(value: cubit, child: const LoginPage()),
  );

  testWidgets('shows the required login controls', (tester) async {
    await tester.pumpWidget(subject());

    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.text('Sign in'), findsOneWidget);
    expect(find.byTooltip('Show password'), findsOneWidget);
  });

  testWidgets('shows inline validation for empty credentials', (tester) async {
    await tester.pumpWidget(subject());
    await tester.enterText(find.byType(TextFormField).first, '');
    await tester.enterText(find.byType(TextFormField).last, '');
    await tester.tap(find.text('Sign in'));
    await tester.pump();

    expect(find.text('Enter your username'), findsOneWidget);
    expect(find.text('Enter your password'), findsOneWidget);
  });
}
