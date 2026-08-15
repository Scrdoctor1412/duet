import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:duet/duet.dart';
import 'package:duet_example/screens/auth_screen/auth_viewmodel.dart';
import 'package:duet_example/screens/my_test_screen/my_test_screen.dart';
import 'package:duet_example/screens/product_screen/product_viewmodel.dart';
import 'package:duet_example/screens/product_screen/states/product_state.dart';
import 'package:duet_example/screens/product_screen/widgets/cart_badge_icon_button.dart';
import 'package:duet_example/screens/product_screen/widgets/product_card.dart';
import 'package:duet_example/screens/product_screen/widgets/user_greeting_widget.dart';

class ProductScreen extends DuetView<ProductViewModel> {
  const ProductScreen({super.key});

  @override
  ProductViewModel bindDuet() => ProductViewModel();

  @override
  Widget build(BuildContext context, ProductViewModel duet) {
    return Scaffold(
      appBar: AppBar(
        //      Selective User Greeting Widget
        title: const UserGreetingWidget(),
        actions: [
          // Stress Test Screen Button
          IconButton(
            icon: const Icon(Icons.speed_rounded, color: Colors.amber),
            tooltip: "Stress Test Duet",
            onPressed: () => context.push('/stress-test'),
          ),

          // Profile Button (Local ViewModel Screen)
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: "Trang c   nh  n (Local VM)",
            onPressed: () => context.push('/profile'),
          ),

          //      Selective Cart Badge Icon Button
          const CartBadgeIconButton(),

          IconButton(
            onPressed: () {
              context.push(MyTestScreen.route);
            },
            icon: const Icon(Icons.text_fields_sharp),
          ),

          // Logout Button
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: "    ng xu   t",
            onPressed: () => _confirmLogout(context),
          ),
        ],
      ),
      body: Stack(
        children: [
          //      Selective Product List Widget
          DuetSelector<ProductViewModel, List<ProductItem>>(
            selector: (vm) => vm.data.products,
            builder: (context, products) {
              if (products.isEmpty) {
                return const Center(
                  child: Text("Ch  a c   s   n ph   m n  o trong c   a h  ng."),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  return ProductCard(
                    key: ValueKey(products[index].id),
                    product: products[index],
                  );
                },
              );
            },
          ),

          //      Selective Loading Overlay
          DuetSelector<ProductViewModel, bool>.ui(
            selector: (vm) => vm.ui is ProductUiLoading,
            builder: (context, isLoading) {
              if (isLoading) {
                return Container(
                  color: Colors.black26,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: duet.addRandomProduct,
        icon: const Icon(Icons.add),
        label: const Text("Th  m s   n ph   m"),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    final authVM = getDuet(() => AuthViewModel());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("    ng xu   t"),
        content: const Text("B   n c   ch   c ch   n mu   n     ng xu   t?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("H   y"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              authVM.logout();
            },
            child: const Text("    ng xu   t"),
          ),
        ],
      ),
    );
  }
}
