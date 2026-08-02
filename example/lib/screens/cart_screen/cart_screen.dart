      import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:duet/duet.dart';
import 'package:duet_example/screens/cart_screen/cart_screen_viewmodel.dart';
import 'package:duet_example/screens/cart_screen/states/cart_state.dart';
import 'package:duet_example/screens/cart_screen/widgets/cart_item_card.dart';
import 'package:duet_example/screens/cart_screen/widgets/cart_summary_bar.dart';
import 'package:duet_example/screens/cart_screen/widgets/empty_cart_view.dart';

class CartScreen extends DuetView<CartViewModel> {
  const CartScreen({super.key});

  @override
  CartViewModel bindDuet() => CartViewModel();

  @override
  Widget build(BuildContext context, CartViewModel duet) {
    return DuetBehaviorListener<CartData, CartUiBehavior>(
      listener: (context, behavior) {
        switch (behavior) {
          case CartUiSuccess(message: final msg):
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(msg),
                backgroundColor: Colors.green.shade700,
                duration: const Duration(seconds: 2),
              ),
            );
            duet.resetBehavior();
          case CartUiError(message: final msg):
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(msg),
                backgroundColor: Colors.red.shade700,
                duration: const Duration(seconds: 2),
              ),
            );
            duet.resetBehavior();
          default:
            break;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Gi    H  ng C   a B   n",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          actions: [
            //      Selective Listening: Clear button only shows when cart is NOT empty
            DuetSelector<CartViewModel, bool>(
              selector: (vm) => vm.data.items.isNotEmpty,
              builder: (context, hasItems) {
                if (!hasItems) return const SizedBox.shrink();

                return IconButton(
                  icon: const Icon(Icons.delete_sweep_outlined),
                  tooltip: "X  a to  n b    gi   ",
                  onPressed: () => _confirmClearCart(context, duet),
                );
              },
            ),
          ],
        ),
        body: DuetSelector<CartViewModel, List<String>>(
          selector: (vm) => vm.data.items.map((e) => e.id).toList(),
          shouldRebuild: (prev, curr) => !listEquals(prev, curr),
          builder: (context, itemIds) {
            if (itemIds.isEmpty) {
              return const EmptyCartView();
            }

            return Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: itemIds.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return CartItemCard(
                        key: ValueKey(itemIds[index]),
                        itemId: itemIds[index],
                      );
                    },
                  ),
                ),

                //      Selective Cart Summary Bar
                const CartSummaryBar(),
              ],
            );
          },
        ),
      ),
    );
  }

  void _confirmClearCart(BuildContext context, CartViewModel cartVM) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("X  c nh   n"),
        content: const Text("B   n c   ch   c ch   n mu   n x  a to  n b   ?gi   ?h  ng?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("H   y"),
          ),
          TextButton(
            onPressed: () {
              cartVM.clearCart();
              Navigator.pop(ctx);
            },
            child: const Text("X  a", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
