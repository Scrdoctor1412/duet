import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:duet/duet.dart';

class SampleData {
  final int count;
  const SampleData({required this.count});
}

class SampleViewModel extends Duet<SampleData, String> {
  SampleViewModel()
      : super(
          initialData: const SampleData(count: 0),
          initialBehavior: 'Idle',
        );

  void increment() {
    emitData(SampleData(count: data.count + 1));
  }

  void setBehavior(String newBehavior) {
    emitBehavior(newBehavior);
  }
}

class EqualViewModel extends Duet<int, String> {
  EqualViewModel(int value)
      : super(initialData: value, initialBehavior: 'Idle');

  @override
  bool operator ==(Object other) => other is EqualViewModel;

  @override
  int get hashCode => 1;
}

void main() {
  testWidgets('DuetBuilder automatically binds viewModel and listens to data',
      (WidgetTester tester) async {
    final viewModel = SampleViewModel();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DuetBuilder(
            viewModel: viewModel,
            builder: (context, data) {
              return Text('Count: ${data.count}');
            },
          ),
        ),
      ),
    );

    expect(find.text('Count: 0'), findsOneWidget);

    // Update data triggers rebuild
    viewModel.increment();
    await tester.pump();
    expect(find.text('Count: 1'), findsOneWidget);

    // Unmounted releases refCount and disposes automatically
    await tester.pumpWidget(const SizedBox());
    expect(viewModel.isDisposed, isTrue);
  });

  testWidgets('DuetBuilder.ui listens to behavior state',
      (WidgetTester tester) async {
    final viewModel = SampleViewModel();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DuetBuilder.ui(
            viewModel: viewModel,
            builder: (context, ui) {
              return Text('Status: $ui');
            },
          ),
        ),
      ),
    );

    expect(find.text('Status: Idle'), findsOneWidget);

    viewModel.setBehavior('Loading');
    await tester.pump();
    expect(find.text('Status: Loading'), findsOneWidget);
  });

  testWidgets('DuetBuilder swaps equal but non-identical ViewModels',
      (WidgetTester tester) async {
    final first = EqualViewModel(1);
    final second = EqualViewModel(2);

    Widget host(EqualViewModel viewModel) {
      return MaterialApp(
        home: DuetBuilder<int, String>(
          viewModel: viewModel,
          builder: (_, data) => Text('$data'),
        ),
      );
    }

    await tester.pumpWidget(host(first));
    expect(find.text('1'), findsOneWidget);
    expect(first.refCount, 1);

    await tester.pumpWidget(host(second));
    expect(find.text('2'), findsOneWidget);
    expect(first.isDisposed, isTrue);
    expect(second.refCount, 1);
  });
}
