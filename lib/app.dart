import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/di/service_locator.dart';
import 'core/network/api_client.dart';
import 'core/localization/app_localizations.dart';
import 'core/settings/settings_cubit.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/auth_cubit.dart';
import 'features/auth/presentation/login_page.dart';
import 'features/auth/presentation/splash_page.dart';
import 'features/shell/presentation/app_shell.dart';

class ShopSphereApp extends StatefulWidget {
  const ShopSphereApp({super.key});

  @override
  State<ShopSphereApp> createState() => _ShopSphereAppState();
}

class _ShopSphereAppState extends State<ShopSphereApp> {
  late final StreamSubscription<void> _sessionSubscription;

  @override
  void initState() {
    super.initState();
    // A single listener keeps expired-session behavior consistent on every screen.
    _sessionSubscription = getIt<ApiClient>().sessionExpired.listen((_) {
      if (mounted) {
        context.read<AuthCubit>().logout(
          message: 'Your session expired. Please sign in again.',
        );
      }
    });
  }

  @override
  void dispose() {
    _sessionSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settings) => MaterialApp(
        title: 'ShopSphere',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: settings.themeMode,
        locale: settings.locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) => switch (state.status) {
            AuthStatus.checking => const SplashPage(),
            AuthStatus.authenticated => const AppShell(),
            AuthStatus.unauthenticated ||
            AuthStatus.failure => const LoginPage(),
          },
        ),
      ),
    );
  }
}
