import 'package:duet/duet.dart';
import 'package:duet_example/screens/product_screen/states/product_state.dart';

class ProductViewModel extends Duet<ProductData, ProductUiBehavior> {
  ProductViewModel()
      : super(
          initialData: ProductData(products: _initialProducts),
          initialBehavior: const ProductUiIdle(),
        );

  @override
  bool get autoDispose => false;

  @override
  bool get isGlobal => true;

  static final List<ProductItem> _initialProducts = [
    const ProductItem(
      id: 'p1',
      name: 'iPhone 16 Pro Max',
      price: 34990000,
      description: 'Titan Sa m   c, Chip A18 Pro si  u m   nh m   ?',
      icon: '    ',
      rating: 4.9,
    ),
    const ProductItem(
      id: 'p2',
      name: 'MacBook Pro M3',
      price: 45990000,
      description: 'M  n h  nh Liquid Retina XDR 16 inch, RAM 18GB.',
      icon: '    ',
      rating: 4.8,
    ),
    const ProductItem(
      id: 'p3',
      name: 'AirPods Max 2',
      price: 13990000,
      description: 'Ch   ng    n ch   ?     ng      nh cao, c   ng s   c USB-C.',
      icon: '    ',
      rating: 4.7,
    ),
    const ProductItem(
      id: 'p4',
      name: 'Apple Watch Ultra 2',
      price: 21990000,
      description: 'V   ?Titan   en 49mm, pin s   ?d   ng 36 gi   ?',
      icon: '   ?,
      rating: 4.9,
    ),
    const ProductItem(
      id: 'p5',
      name: 'iPad Pro M4',
      price: 28990000,
      description: 'M  n h  nh Ultra Retina XDR Tandem OLED si  u m   ng.',
      icon: '    ',
      rating: 4.8,
    ),
  ];

  @override
  void invalidate() async {
    super.invalidate();
    emitBehavior(const ProductUiLoading());
    await Future.delayed(const Duration(seconds: 1));
    emit(
      data: ProductData(products: _initialProducts),
      ui: const ProductUiSuccess(),
    );
  }

  Future<void> addRandomProduct() async {
    if (behaviorState is ProductUiLoading) return;

    emitBehavior(const ProductUiLoading());
    await Future.delayed(const Duration(milliseconds: 600));

    final count = dataState.products.length + 1;
    final newProduct = ProductItem(
      id: 'p_$count',
      name: 'S   n ph   m C  ng ngh   ?#$count',
      price: (count * 1500000).toDouble(),
      description: 'Phi  n b   n m   i b   ?sung v  o c   a h  ng.',
      icon: '    ',
      rating: 4.5,
    );

    emit(
      data: ProductData(products: [...dataState.products, newProduct]),
      ui: const ProductUiSuccess(),
    );
  }
}
