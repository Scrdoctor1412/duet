import 'package:flutter/material.dart';
import 'package:duet/duet.dart';
import 'package:duet_example/screens/cart_screen/cart_screen_viewmodel.dart';

class CartSummaryBar extends StatelessWidget {
  final CartViewModel? viewModel;

  const CartSummaryBar({
    super.key,
    this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    //      Selective Listening: Rebuilds ONLY when totalPrice changes
    return DuetSelector<CartViewModel, double>(
      viewModel: viewModel,
      selector: (vm) => vm.data.totalPrice,
      builder: (context, totalPrice) {
        final vm = viewModel ?? context.vm<CartViewModel>();
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "T   ng thanh to  n:",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatPrice(totalPrice),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: vm.checkout,
                    child: const Text(
                      "Thanh To  n Ngay",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
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
