import '../../../core/network/api_client.dart';
import '../domain/product.dart';
import 'product_model.dart';

class ProductsRepositoryImpl implements ProductsRepository {
  ProductsRepositoryImpl(this._client);

  final ApiClient _client;

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
    final json = await _client.get(
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
    final products = (json['products'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(ProductModel.fromJson)
        .toList(growable: false);
    return ProductPage(
      products: products,
      total: (json['total'] as num? ?? products.length).toInt(),
      skip: (json['skip'] as num? ?? skip).toInt(),
      limit: (json['limit'] as num? ?? limit).toInt(),
    );
  }

  @override
  Future<List<String>> getCategories() async {
    final json = await _client.getList('/products/category-list');
    return json.map((category) => category.toString()).toList(growable: false);
  }

  @override
  Future<Product> getProduct(int id) async => ProductModel.fromJson(
    await _client.get('/products/$id', authenticated: false),
  );
}
