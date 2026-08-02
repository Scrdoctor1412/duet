import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:duet/duet.dart';

class TestData {
  final int count;
  final String title;

  const TestData({required this.count, required this.title});
}

class TestViewModel extends Duet<TestData, String> {
  TestViewModel()
      : super(
          initialData: const TestData(count: 0, title: 'Hello'),
          initialBehavior: 'Idle',
        );

  void updateCount(int newCount) {
    emitData(TestData(count: newCount, title: data.title));
  }

  void updateTitle(String newTitle) {
    emitData(TestData(count: data.count, title: newTitle));
  }

  void updateBehavior(String newBehavior) {
    emitBehavior(newBehavior);
  }
}

void main() {
  testWidgets('DuetSelector only rebuilds when selected data changes',
      (WidgetTester tester) async {
    final viewModel = TestViewModel();
    int buildCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DuetSelector<TestViewModel, int>(
            viewModel: viewModel,
            selector: (vm) => vm.data.count,
            builder: (context, count) {
              buildCount++;
              return Text('Count: $count');
            },
          ),
        ),
      ),
    );

    expect(find.text('Count: 0'), findsOneWidget);
    expect(buildCount, equals(1));

    // Changing title should NOT trigger rebuild for count selector
    viewModel.updateTitle('World');
    await tester.pump();

    expect(find.text('Count: 0'), findsOneWidget);
    expect(buildCount, equals(1)); // Build count remains 1!

    // Changing count SHOULD trigger rebuild
    viewModel.updateCount(5);
    await tester.pump();

    expect(find.text('Count: 5'), findsOneWidget);
    expect(buildCount, equals(2)); // Build count increased to 2!
  });

  testWidgets('DuetSelector.ui only rebuilds when selected UI behavior changes',
      (WidgetTester tester) async {
    final viewModel = TestViewModel();
    int buildCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DuetSelector<TestViewModel, String>.ui(
            viewModel: viewModel,
            selector: (vm) => vm.ui,
            builder: (context, uiState) {
              buildCount++;
              return Text('UI: $uiState');
            },
          ),
        ),
      ),
    );

    expect(find.text('UI: Idle'), findsOneWidget);
    expect(buildCount, equals(1));

    // Changing data should NOT trigger rebuild for UI selector
    viewModel.updateCount(10);
    await tester.pump();

    expect(buildCount, equals(1));

    // Changing behavior SHOULD trigger rebuild
    viewModel.updateBehavior('Loading');
    await tester.pump();

    expect(find.text('UI: Loading'), findsOneWidget);
    expect(buildCount, equals(2));
  });
}
