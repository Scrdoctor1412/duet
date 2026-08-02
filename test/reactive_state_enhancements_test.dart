import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:duet/duet.dart';

class CounterData {
  final int count;
  const CounterData({required this.count});

  CounterData copyWith({int? count}) {
    return CounterData(count: count ?? this.count);
  }
}

class TestViewModel extends Duet<CounterData, UiState> {
  TestViewModel({Object? key})
      : super(
          initialData: const CounterData(count: 0),
          initialBehavior: const UiIdle(),
        );

  void safeIncrement() {
    updateData((current) => current.copyWith(count: current.count + 1));
  }

  void forceNotify() {
    notifyDataChanged();
  }
}

class GlobalTestViewModel extends Duet<CounterData, UiState> {
  @override
  bool get isGlobal => true;

  GlobalTestViewModel()
      : super(
          initialData: const CounterData(count: 99),
          initialBehavior: const UiIdle(),
        );
}

void main() {
  tearDown(() {
    DuetRegistry.resetAll();
  });

  test('updateData safely transforms and emits new state', () {
    final vm = TestViewModel(key: 'unit_test_key');
    expect(vm.data.count, equals(0));

    vm.safeIncrement();
    expect(vm.data.count, equals(1));
  });

  test('notifyDataChanged triggers listener without changing reference', () {
    final vm = TestViewModel(key: 'unit_test_key');
    int notifyCount = 0;

    vm.dataNotifier.addListener(() {
      notifyCount++;
    });

    vm.forceNotify();
    expect(notifyCount, equals(1));
  });

  test('isGlobal allow keyless getDuet access', () {
    final globalVm = getDuet(() => GlobalTestViewModel());
    expect(globalVm.data.count, equals(99));
    expect(globalVm.isGlobal, isTrue);
  });

  testWidgets('context.duet creates ViewModel using autoKey',
      (WidgetTester tester) async {
    TestViewModel? retrievedVm;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              retrievedVm = context.duet(() => TestViewModel(key: 'context_key'), key: 'context_key');
              return Text('Count: ${retrievedVm!.data.count}');
            },
          ),
        ),
      ),
    );

    expect(retrievedVm, isNotNull);
    expect(find.text('Count: 0'), findsOneWidget);
  });
}
