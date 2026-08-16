import 'package:duet/duet.dart';
import 'package:duet_example/screens/cart_screen/states/cart_state.dart';

class CartViewModel extends Duet<CartData, CartUiBehavior> {
  CartViewModel()
      : super(
          initialData: const CartData(),
          initialBehavior: const CartUiIdle(),
        );

  @override
  bool get autoDispose => false;

  void addItem({
    required String id,
    required String title,
    required double price,
    String icon = '    ',
  }) {
    final existingIndex = dataState.items.indexWhere((item) => item.id == id);
    final updatedList = List<CartItem>.from(dataState.items);

    if (existingIndex >= 0) {
      final existing = updatedList[existingIndex];
      updatedList[existingIndex] = existing.copyWith(
        quantity: existing.quantity + 1,
      );
    } else {
      updatedList.add(CartItem(
        id: id,
        title: title,
        price: price,
        quantity: 1,
        icon: icon,
      ));
    }

    emit(
      data: CartData(items: updatedList),
      ui: CartUiSuccess("     th  m '$title' v  o gi   ?h  ng!"),
    );
  }

  void incrementItem(String id) {
    final updatedList = dataState.items.map((item) {
      if (item.id == id) {
        return item.copyWith(quantity: item.quantity + 1);
      }
      return item;
    }).toList();

    emitData(CartData(items: updatedList));
  }

  void decrementItem(String id) {
    final updatedList = <CartItem>[];
    for (final item in dataState.items) {
      if (item.id == id) {
        if (item.quantity > 1) {
          updatedList.add(item.copyWith(quantity: item.quantity - 1));
        }
      } else {
        updatedList.add(item);
      }
    }

    emitData(CartData(items: updatedList));
  }

  void removeItem(String id) {
    final updatedList = dataState.items.where((item) => item.id != id).toList();
    emit(
      data: CartData(items: updatedList),
      ui: const CartUiSuccess("     x  a s   n ph   m kh   i gi   ?"),
    );
  }

  void clearCart() {
    emitData(const CartData(items: []));
  }

  void checkout() {
    if (dataState.items.isEmpty) {
      emitBehavior(const CartUiError("Gi   ?h  ng c   a b   n   ang tr   ng!"));
      return;
    }

    emit(
      data: const CartData(items: []),
      ui: const CartUiSuccess(
          "Thanh to  n th  nh c  ng! C   m   n b   n      mua h  ng."),
    );
  }

  void resetBehavior() {
    emitBehavior(const CartUiIdle());
  }
}
