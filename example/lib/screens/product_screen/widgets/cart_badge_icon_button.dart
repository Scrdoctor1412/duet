import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:duet/duet.dart';
import 'package:duet_example/screens/cart_screen/cart_screen_viewmodel.dart';

class CartBadgeIconButton extends StatelessWidget {
  final CartViewModel? cartVM;

  const CartBadgeIconButton({
    super.key,
    this.cartVM,
  });

  @override
  Widget build(BuildContext context) {
    final vm = cartVM ?? getDuet(() => CartViewModel());
    //      Selective Listening: Rebuilds ONLY when total cart count changes
    return DuetSelector<CartViewModel, int>(
      viewModel: vm,
      selector: (vm) => vm.data.totalCount,
      builder: (context, count) {
        return Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.shopping_cart_outlined),
              tooltip: "Xem Gi   ?h  ng",
              onPressed: () => context.push('/cart'),
            ),
            if (count > 0)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Text(
                    '$count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
