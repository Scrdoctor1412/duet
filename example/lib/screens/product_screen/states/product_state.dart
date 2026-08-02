import 'package:flutter/foundation.dart';

@immutable
class ProductItem {
  final String id;
  final String name;
  final double price;
  final String description;
  final String icon;
  final double rating;

  const ProductItem({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.icon,
    this.rating = 4.5,
  });
}

@immutable
class ProductData {
  final List<ProductItem> products;

  const ProductData({
    this.products = const [],
  });
}

sealed class ProductUiBehavior {
  const ProductUiBehavior();

  factory ProductUiBehavior.idle() = ProductUiIdle;
  factory ProductUiBehavior.loading() = ProductUiLoading;
  factory ProductUiBehavior.error(String message) = ProductUiError;
  factory ProductUiBehavior.success() = ProductUiSuccess;
}

class ProductUiIdle extends ProductUiBehavior {
  const ProductUiIdle();
}

class ProductUiLoading extends ProductUiBehavior {
  const ProductUiLoading();
}

class ProductUiError extends ProductUiBehavior {
  final String message;
  const ProductUiError(this.message);
}

class ProductUiSuccess extends ProductUiBehavior {
  const ProductUiSuccess();
}
