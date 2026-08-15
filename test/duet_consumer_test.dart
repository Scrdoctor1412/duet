import 'package:duet/duet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class ConsumerDuet extends SimpleDuet<int> {
  ConsumerDuet() : super(initialData: 0);
}

class ConsumerHost extends StatefulWidget {
  final List<Listenable> listenables;
  final ConsumerDuet? duet;
  final VoidCallback onBuild;

  const ConsumerHost({
    super.key,
    required this.listenables,
    required this.duet,
    required this.onBuild,
  });

  @override
  State<ConsumerHost> createState() => _ConsumerHostState();
}

class _ConsumerHostState extends State<ConsumerHost>
    with DuetConsumer<ConsumerHost> {
  @override
  List<Listenable> get listenTo => widget.listenables;

  @override
  Duet? get viewModel => widget.duet;

  @override
  Widget build(BuildContext context) {
    widget.onBuild();
    return const SizedBox();
  }
}

void main() {
  testWidgets('DuetConsumer rewires listenables and ViewModel on update', (
    tester,
  ) async {
    final firstListenable = ChangeNotifier();
    final secondListenable = ChangeNotifier();
    final firstDuet = ConsumerDuet();
    final secondDuet = ConsumerDuet();
    var builds = 0;

    Widget host(Listenable listenable, ConsumerDuet duet) {
      return ConsumerHost(
        listenables: [listenable, listenable],
        duet: duet,
        onBuild: () => builds++,
      );
    }

    await tester.pumpWidget(host(firstListenable, firstDuet));
    expect(firstDuet.refCount, 1);

    firstListenable.notifyListeners();
    await tester.pump();
    expect(builds, 2);

    await tester.pumpWidget(host(secondListenable, secondDuet));
    expect(firstDuet.isDisposed, isTrue);
    expect(secondDuet.refCount, 1);

    final buildsAfterSwap = builds;
    firstListenable.notifyListeners();
    await tester.pump();
    expect(builds, buildsAfterSwap);

    secondListenable.notifyListeners();
    await tester.pump();
    expect(builds, buildsAfterSwap + 1);

    await tester.pumpWidget(const SizedBox());
    expect(secondDuet.isDisposed, isTrue);
  });
}
