import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/presentation/auth_cubit.dart';
import 'features/auth/presentation/login_page.dart';
import 'features/auth/presentation/splash_page.dart';
import 'features/shell/presentation/app_shell.dart';

class ShopSphereApp extends StatelessWidget {
  const ShopSphereApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShopSphere',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) => switch (state.status) {
          AuthStatus.checking => const SplashPage(),
          AuthStatus.authenticated => const AppShell(),
          AuthStatus.unauthenticated || AuthStatus.failure => const LoginPage(),
        },
      ),
    );
  }
}
