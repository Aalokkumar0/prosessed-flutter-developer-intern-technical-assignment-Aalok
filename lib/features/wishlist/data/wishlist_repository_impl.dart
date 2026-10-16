import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../products/data/product_model.dart';
import '../../products/domain/product.dart';
import '../domain/wishlist_repository.dart';

class WishlistRepositoryImpl implements WishlistRepository {
  WishlistRepositoryImpl(this._preferences);

  static const _key = 'wishlist_products';
  final SharedPreferences _preferences;

  @override
  Future<List<Product>> load() async {
    final encoded = _preferences.getString(_key);
    if (encoded == null) return const [];
    try {
      return (jsonDecode(encoded) as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .map(ProductModel.fromJson)
          .toList(growable: false);
    } on FormatException {
      await _preferences.remove(_key);
      return const [];
    }
  }

  @override
  Future<void> save(List<Product> products) => _preferences.setString(
    _key,
    jsonEncode(products.map(ProductModel.toJson).toList()),
  );
}
