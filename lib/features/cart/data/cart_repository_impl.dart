import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/network/api_client.dart';
import '../../products/data/product_model.dart';
import '../domain/cart_item.dart';

class CartRepositoryImpl implements CartRepository {
  CartRepositoryImpl(this._preferences, this._client);

  static const _cartKey = 'persisted_cart';
  final SharedPreferences _preferences;
  final ApiClient _client;

  @override
  Future<List<CartItem>> load() async {
    final encoded = _preferences.getString(_cartKey);
    if (encoded == null || encoded.isEmpty) return const [];
    try {
      final list = jsonDecode(encoded) as List<dynamic>;
      return list
          .whereType<Map<String, dynamic>>()
          .map((entry) {
            return CartItem(
              product: ProductModel.fromJson(
                entry['product'] as Map<String, dynamic>,
              ),
              quantity: (entry['quantity'] as num).toInt(),
            );
          })
          .toList(growable: false);
    } on FormatException {
      await _preferences.remove(_cartKey);
      return const [];
    }
  }

  @override
  Future<void> save(List<CartItem> items) async {
    final encoded = items
        .map(
          (item) => {
            'quantity': item.quantity,
            'product': {
              'id': item.product.id,
              'title': item.product.title,
              'description': item.product.description,
              'price': item.product.price,
              'discountPercentage': item.product.discountPercentage,
              'rating': item.product.rating,
              'stock': item.product.stock,
              'thumbnail': item.product.thumbnail,
              'images': item.product.images,
              'brand': item.product.brand,
              'reviews': item.product.reviews
                  .map(
                    (review) => {
                      'rating': review.rating,
                      'comment': review.comment,
                      'reviewerName': review.reviewerName,
                    },
                  )
                  .toList(),
            },
          },
        )
        .toList();
    await _preferences.setString(_cartKey, jsonEncode(encoded));
  }

  @override
  Future<void> placeOrder({
    required int userId,
    required List<CartItem> items,
  }) async {
    await _client.post(
      '/carts/add',
      data: {
        'userId': userId,
        'products': items
            .map((item) => {'id': item.product.id, 'quantity': item.quantity})
            .toList(),
      },
    );
  }
}
