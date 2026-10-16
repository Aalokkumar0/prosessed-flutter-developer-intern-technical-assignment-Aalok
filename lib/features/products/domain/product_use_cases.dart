import 'product.dart';

/// Groups the catalogue actions consumed by presentation state.
class ProductUseCases {
  const ProductUseCases(this._repository);

  final ProductsRepository _repository;

  Future<ProductPage> getProducts({
    required int skip,
    required int limit,
    String? search,
    String? category,
    String? sortBy,
    String order = 'asc',
  }) => _repository.getProducts(
    skip: skip,
    limit: limit,
    search: search,
    category: category,
    sortBy: sortBy,
    order: order,
  );

  Future<List<String>> getCategories() => _repository.getCategories();

  Future<Product> getProduct(int id) => _repository.getProduct(id);
}
