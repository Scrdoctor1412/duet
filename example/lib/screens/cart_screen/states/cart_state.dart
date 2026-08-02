import 'package:flutter/foundation.dart';

@immutable
class CartItem {
  final String id;
  final String title;
  final double price;
  final int quantity;
  final String icon;

  const CartItem({
    required this.id,
    required this.title,
    required this.price,
    this.quantity = 1,
    this.icon = '    ',
  });

  CartItem copyWith({
    String? id,
    String? title,
    double? price,
    int? quantity,
    String? icon,
  }) {
    return CartItem(
      id: id ?? this.id,
      title: title ?? this.title,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      icon: icon ?? this.icon,
    );
  }
}

@immutable
class CartData {
  final List<CartItem> items;

  const CartData({
    this.items = const [],
  });

  double get totalPrice => items.fold(
        0.0,
        (sum, item) => sum + (item.price * item.quantity),
      );

  int get totalCount => items.fold(
        0,
        (sum, item) => sum + item.quantity,
      );

  CartData copyWith({
    List<CartItem>? items,
  }) {
    return CartData(
      items: items ?? this.items,
    );
  }
}

sealed class CartUiBehavior {
  const CartUiBehavior();

  factory CartUiBehavior.idle() = CartUiIdle;
  factory CartUiBehavior.success(String message) = CartUiSuccess;
  factory CartUiBehavior.error(String message) = CartUiError;
}

class CartUiIdle extends CartUiBehavior {
  const CartUiIdle();
}

class CartUiSuccess extends CartUiBehavior {
  final String message;
  const CartUiSuccess(this.message);
}

class CartUiError extends CartUiBehavior {
  final String message;
  const CartUiError(this.message);
}
