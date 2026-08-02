import 'package:flutter/material.dart';
import 'package:duet/duet.dart';
import 'package:duet_example/screens/cart_screen/cart_screen_viewmodel.dart';
import 'package:duet_example/screens/cart_screen/states/cart_state.dart';

class CartItemCard extends StatelessWidget {
  final String itemId;
  final CartViewModel? viewModel;

  const CartItemCard({
    super.key,
    required this.itemId,
    this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    //      Selective Listening: Rebuilds ONLY when this specific item's data changes
    return DuetSelector<CartViewModel, CartItem?>(
      viewModel: viewModel,
      selector: (vm) {
        final index = vm.data.items.indexWhere((item) => item.id == itemId);
        return index >= 0 ? vm.data.items[index] : null;
      },
      builder: (context, item) {
        if (item == null) return const SizedBox.shrink();

        final vm = viewModel ?? context.vm<CartViewModel>();
        final itemTotal = item.price * item.quantity;

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primaryContainer
                        .withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      item.icon,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${_formatPrice(item.price)} x ${item.quantity} = ${_formatPrice(itemTotal)}",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, size: 22),
                      onPressed: () => vm.decrementItem(item.id),
                    ),
                    Text(
                      "${item.quantity}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline, size: 22),
                      onPressed: () => vm.incrementItem(item.id),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline,
                          color: Colors.redAccent, size: 22),
                      onPressed: () => vm.removeItem(item.id),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static String _formatPrice(double price) {
    return "${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}  ";
  }
}
