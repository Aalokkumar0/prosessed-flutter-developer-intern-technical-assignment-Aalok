import 'package:equatable/equatable.dart';

class ProductReview extends Equatable {
  const ProductReview({
    required this.rating,
    required this.comment,
    required this.reviewerName,
  });

  final int rating;
  final String comment;
  final String reviewerName;

  @override
  List<Object?> get props => [rating, comment, reviewerName];
}

class Product extends Equatable {
  const Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.discountPercentage,
    required this.rating,
    required this.stock,
    required this.thumbnail,
    required this.images,
    required this.reviews,
    this.brand,
  });

  final int id;
  final String title;
  final String description;
  final double price;
  final double discountPercentage;
  final double rating;
  final int stock;
  final String thumbnail;
  final List<String> images;
  final List<ProductReview> reviews;
  final String? brand;

  bool get isInStock => stock > 0;
  double get originalPrice =>
      discountPercentage <= 0 ? price : price / (1 - discountPercentage / 100);

  @override
  List<Object?> get props => [id, title, price, stock, thumbnail];
}

class ProductPage {
  const ProductPage({
    required this.products,
    required this.total,
    required this.skip,
    required this.limit,
  });

  final List<Product> products;
  final int total;
  final int skip;
  final int limit;
}

abstract interface class ProductsRepository {
  Future<ProductPage> getProducts({
    required int skip,
    required int limit,
    String? search,
    String? category,
    String? sortBy,
    String order = 'asc',
  });
  Future<List<String>> getCategories();
  Future<Product> getProduct(int id);
}
