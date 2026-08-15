import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:duet/duet.dart';

class SampleData {
  final String title;
  const SampleData({required this.title});
}

class ScopeTestViewModel extends Duet<SampleData, UiState> {
  ScopeTestViewModel()
      : super(
          initialData: const SampleData(title: 'Nested Test'),
          initialBehavior: const UiIdle(),
        );

  void updateTitle(String newTitle) {
    emit(data: SampleData(title: newTitle));
  }
}

void main() {
  testWidgets('DuetScope resolves exact VM and legacy data/behavior lookups',
      (WidgetTester tester) async {
    final viewModel = ScopeTestViewModel();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DuetScope(
            viewModel: viewModel,
            child: Builder(
              builder: (context) {
                // Deeply nested context lookup
                return Builder(
                  builder: (childContext) {
                    final vm =
                        DuetScope.find<SampleData, UiState>(childContext);
                    final exactVm =
                        DuetScope.of<ScopeTestViewModel>(childContext);
                    expect(identical(vm, exactVm), isTrue);
                    return DuetBuilder<SampleData, UiState>(
                      builder: (context, data) => Text(data.title),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );

    expect(find.text('Nested Test'), findsOneWidget);

    viewModel.updateTitle('Updated Title');
    await tester.pump();

    expect(find.text('Updated Title'), findsOneWidget);
  });
}
