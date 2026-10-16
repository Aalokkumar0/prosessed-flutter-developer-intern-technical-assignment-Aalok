import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/features/products/data/product_model.dart';

void main() {
  late Map<String, dynamic> fixture;

  setUpAll(() {
    fixture = jsonDecode(
      File('test/fixtures/product.json').readAsStringSync(),
    ) as Map<String, dynamic>;
  });

  test('parses required product fields from JSON fixture', () {
    final product = ProductModel.fromJson(fixture);
    expect(product.id, 1);
    expect(product.title, 'Essence Mascara Lash Princess');
    expect(product.price, 9.99);
  });

  test('parses nullable brand when present', () {
    expect(ProductModel.fromJson(fixture).brand, 'Essence');
  });

  test('accepts a missing brand', () {
    final json = Map<String, dynamic>.from(fixture)..remove('brand');
    expect(ProductModel.fromJson(json).brand, isNull);
  });

  test('parses product images', () {
    expect(ProductModel.fromJson(fixture).images, [
      'https://example.com/one.png',
    ]);
  });

  test('parses customer reviews', () {
    final review = ProductModel.fromJson(fixture).reviews.single;
    expect(review.reviewerName, 'Emily');
    expect(review.rating, 5);
  });

  test('computes original price from discount', () {
    final product = ProductModel.fromJson(fixture);
    expect(product.originalPrice, closeTo(11.1, .01));
  });

  test('reports stock availability', () {
    expect(ProductModel.fromJson(fixture).isInStock, isTrue);
  });
}
