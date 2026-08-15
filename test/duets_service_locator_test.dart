import 'package:duet/duet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class SharedCounterDuet extends SimpleDuet<int> {
  SharedCounterDuet() : super(initialData: 0);

  void increment() => emitData(data + 1);
}

class PersistentSharedDuet extends SharedCounterDuet {
  @override
  bool get autoDispose => false;
}

void main() {
  tearDown(Duets.resetAll);

  test('shared lazily creates one instance and find does not create', () {
    var creations = 0;

    expect(Duets.find<SharedCounterDuet>(), isNull);

    final first = Duets.shared(() {
      creations++;
      return SharedCounterDuet();
    });
    final second = Duets.shared(() {
      creations++;
      return SharedCounterDuet();
    });

    expect(second, same(first));
    expect(creations, 1);
    expect(Duets.contains<SharedCounterDuet>(), isTrue);
  });

  test('shared keys create independent instances', () {
    final first = Duets.shared(SharedCounterDuet.new, key: 'first');
    final second = Duets.shared(SharedCounterDuet.new, key: 'second');

    first.increment();

    expect(first.data, 1);
    expect(second.data, 0);
  });

  testWidgets('shared state survives a gap between screens', (tester) async {
    final shared = Duets.shared(SharedCounterDuet.new);

    await tester.pumpWidget(
      MaterialApp(
        home: shared.watchData(
          builder: (context, count) => Text('$count'),
        ),
      ),
    );
    shared.increment();
    await tester.pump();
    expect(find.text('1'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    expect(shared.isDisposed, isFalse);

    final reopened = Duets.shared(SharedCounterDuet.new);
    expect(reopened, same(shared));
    expect(reopened.data, 1);

    Duets.reset<SharedCounterDuet>();
    expect(shared.isDisposed, isTrue);
    expect(Duets.find<SharedCounterDuet>(), isNull);
  });

  testWidgets('reset unregisters shared state without disposing mounted users',
      (
    tester,
  ) async {
    final shared = Duets.shared(SharedCounterDuet.new);

    await tester.pumpWidget(
      MaterialApp(
        home: shared.watchData(
          builder: (context, count) => Text('$count'),
        ),
      ),
    );

    Duets.reset<SharedCounterDuet>();
    expect(Duets.find<SharedCounterDuet>(), isNull);
    expect(shared.isDisposed, isFalse);

    shared.increment();
    await tester.pump();
    expect(find.text('1'), findsOneWidget);

    final replacement = Duets.shared(SharedCounterDuet.new);
    expect(replacement, isNot(same(shared)));

    await tester.pumpWidget(const SizedBox());
    expect(shared.isDisposed, isTrue);
    expect(replacement.isDisposed, isFalse);
  });

  testWidgets('reset eventually disposes non-autoDispose shared state', (
    tester,
  ) async {
    final shared = Duets.shared(PersistentSharedDuet.new);

    await tester.pumpWidget(
      MaterialApp(
          home: shared.watchData(builder: (_, count) => Text('$count'))),
    );
    Duets.reset<PersistentSharedDuet>();

    expect(shared.isDisposed, isFalse);
    await tester.pumpWidget(const SizedBox());
    expect(shared.isDisposed, isTrue);
  });
}
