import 'package:flutter/material.dart';
import 'package:duet/duet.dart';
import 'package:duet_example/screens/cart_screen/cart_screen_viewmodel.dart';
import 'package:duet_example/screens/product_screen/states/product_state.dart';

class ProductCard extends StatelessWidget {
  final ProductItem product;
  final CartViewModel? cartVM;

  const ProductCard({
    super.key,
    required this.product,
    this.cartVM,
  });

  @override
  Widget build(BuildContext context) {
    final vm = cartVM ?? Duets.shared<CartViewModel>(CartViewModel.new);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Icon / Image container
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  product.icon,
                  style: const TextStyle(fontSize: 32),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        _formatPrice(product.price),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 2),
                      Text(
                        "${product.rating}",
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Add to Cart Button
            IconButton.filledTonal(
              icon: const Icon(Icons.add_shopping_cart),
              // tooltip: "Th  m v  o gi   ?,
              onPressed: () {
                vm.addItem(
                  id: product.id,
                  title: product.name,
                  price: product.price,
                  icon: product.icon,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  static String _formatPrice(double price) {
    return "${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}  ";
  }
}
