import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/error/app_failure.dart';
import '../../../core/network/api_client.dart';
import '../domain/product.dart';
import 'product_model.dart';

class ProductsRepositoryImpl implements ProductsRepository {
  ProductsRepositoryImpl(this._client, this._preferences);

  final ApiClient _client;
  final SharedPreferences _preferences;
  static const _productsCacheKey = 'cached_product_page';
  static const _categoriesCacheKey = 'cached_categories';

  @override
  Future<ProductPage> getProducts({
    required int skip,
    required int limit,
    String? search,
    String? category,
    String? sortBy,
    String order = 'asc',
  }) async {
    final path = search != null && search.isNotEmpty
        ? '/products/search'
        : category != null && category.isNotEmpty
        ? '/products/category/$category'
        : '/products';
    late Map<String, dynamic> json;
    var isFromCache = false;
    try {
      json = await _client.get(
        path,
        authenticated: false,
        queryParameters: {
          'limit': limit,
          'skip': skip,
          if (search != null && search.isNotEmpty) 'q': search,
          'sortBy': ?sortBy,
          if (sortBy != null) 'order': order,
        },
      );
      if (skip == 0) {
        await _preferences.setString(_productsCacheKey, jsonEncode(json));
      }
    } on AppFailure catch (failure) {
      final cached = _preferences.getString(_productsCacheKey);
      final recoverable =
          failure.type == FailureType.network ||
          failure.type == FailureType.timeout;
      if (cached == null || !recoverable) rethrow;
      json = jsonDecode(cached) as Map<String, dynamic>;
      isFromCache = true;
    }
    final products = (json['products'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(ProductModel.fromJson)
        .toList(growable: false);
    return ProductPage(
      products: products,
      total: (json['total'] as num? ?? products.length).toInt(),
      skip: (json['skip'] as num? ?? skip).toInt(),
      limit: (json['limit'] as num? ?? limit).toInt(),
      isFromCache: isFromCache,
    );
  }

  @override
  Future<List<String>> getCategories() async {
    try {
      final json = await _client.getList('/products/category-list');
      await _preferences.setString(_categoriesCacheKey, jsonEncode(json));
      return json
          .map((category) => category.toString())
          .toList(growable: false);
    } on AppFailure catch (failure) {
      final cached = _preferences.getString(_categoriesCacheKey);
      final recoverable =
          failure.type == FailureType.network ||
          failure.type == FailureType.timeout;
      if (cached == null || !recoverable) rethrow;
      return (jsonDecode(cached) as List<dynamic>)
          .map((category) => category.toString())
          .toList(growable: false);
    }
  }

  @override
  Future<Product> getProduct(int id) async => ProductModel.fromJson(
    await _client.get('/products/$id', authenticated: false),
  );
}
