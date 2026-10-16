import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/data/auth_repository_impl.dart';
import '../../features/auth/domain/user.dart';
import '../../features/auth/domain/auth_use_cases.dart';
import '../../features/auth/presentation/auth_cubit.dart';
import '../../features/cart/data/cart_repository_impl.dart';
import '../../features/cart/domain/cart_item.dart';
import '../../features/cart/presentation/cart_cubit.dart';
import '../../features/products/data/products_repository_impl.dart';
import '../../features/products/domain/product.dart';
import '../../features/products/domain/product_use_cases.dart';
import '../../features/products/presentation/products_cubit.dart';
import '../../features/wishlist/data/wishlist_repository_impl.dart';
import '../../features/wishlist/domain/wishlist_repository.dart';
import '../../features/wishlist/presentation/wishlist_cubit.dart';
import '../network/api_client.dart';
import '../network/session_store.dart';
import '../settings/settings_cubit.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  final preferences = await SharedPreferences.getInstance();
  getIt
    ..registerSingleton<SharedPreferences>(preferences)
    ..registerLazySingleton(() => const FlutterSecureStorage())
    ..registerLazySingleton(() => SessionStore(getIt()))
    ..registerLazySingleton(() => Dio())
    ..registerLazySingleton(() => ApiClient(getIt(), getIt()))
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(getIt(), getIt()),
    )
    ..registerLazySingleton(() => AuthUseCases(getIt()))
    ..registerLazySingleton<ProductsRepository>(
      () => ProductsRepositoryImpl(getIt(), getIt()),
    )
    ..registerLazySingleton(() => ProductUseCases(getIt()))
    ..registerLazySingleton<CartRepository>(
      () => CartRepositoryImpl(getIt(), getIt()),
    )
    ..registerLazySingleton<WishlistRepository>(
      () => WishlistRepositoryImpl(getIt()),
    )
    ..registerFactory(() => AuthCubit(getIt()))
    ..registerFactory(() => ProductsCubit(getIt()))
    ..registerFactory(() => CartCubit(getIt()))
    ..registerFactory(() => SettingsCubit(getIt()));
  getIt.registerFactory(() => WishlistCubit(getIt()));
}
