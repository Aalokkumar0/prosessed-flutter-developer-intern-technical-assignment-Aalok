import '../../products/domain/product.dart';

abstract interface class WishlistRepository {
  Future<List<Product>> load();
  Future<void> save(List<Product> products);
}
