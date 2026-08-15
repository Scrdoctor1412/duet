import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:duet/duet.dart';
import 'package:duet_example/screens/cart_screen/cart_screen.dart';
import 'package:duet_example/screens/cart_screen/cart_screen_viewmodel.dart';

void main() {
  tearDown(() {
    DuetRegistry.resetAll();
  });

  testWidgets(
      'Global CartViewModel preserves items added from ProductScreen when CartScreen opens',
      (WidgetTester tester) async {
    final cartVM = getDuet(() => CartViewModel());
    cartVM.addItem(
      id: 'p1',
      title: 'Ao thun Flutter',
      price: 199000,
      icon: 'shirt',
    );

    expect(cartVM.data.items.length, equals(1));

    await tester.pumpWidget(
      const MaterialApp(
        home: CartScreen(),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.byType(CartScreen), findsOneWidget);
  });
}
