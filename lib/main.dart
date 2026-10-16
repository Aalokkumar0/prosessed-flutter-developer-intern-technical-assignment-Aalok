import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app.dart';
import 'core/di/service_locator.dart';
import 'features/auth/presentation/auth_cubit.dart';
import 'features/cart/presentation/cart_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<AuthCubit>()..restoreSession()),
        BlocProvider(create: (_) => getIt<CartCubit>()..load()),
      ],
      child: const ShopSphereApp(),
    ),
  );
}
