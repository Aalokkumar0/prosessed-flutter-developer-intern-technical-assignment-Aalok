import '../domain/product.dart';

class ProductModel {
  const ProductModel._();

  static Product fromJson(Map<String, dynamic> json) {
    final reviews = (json['reviews'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(
          (review) => ProductReview(
            rating: (review['rating'] as num? ?? 0).toInt(),
            comment: review['comment']?.toString() ?? '',
            reviewerName: review['reviewerName']?.toString() ?? 'Anonymous',
          ),
        )
        .toList(growable: false);

    return Product(
      id: (json['id'] as num).toInt(),
      title: json['title']?.toString() ?? 'Untitled product',
      description: json['description']?.toString() ?? '',
      price: (json['price'] as num? ?? 0).toDouble(),
      discountPercentage: (json['discountPercentage'] as num? ?? 0).toDouble(),
      rating: (json['rating'] as num? ?? 0).toDouble(),
      stock: (json['stock'] as num? ?? 0).toInt(),
      thumbnail: json['thumbnail']?.toString() ?? '',
      images: (json['images'] as List<dynamic>? ?? const [])
          .map((image) => image.toString())
          .toList(growable: false),
      reviews: reviews,
      brand: json['brand']?.toString(),
    );
  }

  static Map<String, dynamic> toJson(Product product) => {
    'id': product.id,
    'title': product.title,
    'description': product.description,
    'price': product.price,
    'discountPercentage': product.discountPercentage,
    'rating': product.rating,
    'stock': product.stock,
    'thumbnail': product.thumbnail,
    'images': product.images,
    'brand': product.brand,
    'reviews': product.reviews
        .map(
          (review) => {
            'rating': review.rating,
            'comment': review.comment,
            'reviewerName': review.reviewerName,
          },
        )
        .toList(),
  };
}
