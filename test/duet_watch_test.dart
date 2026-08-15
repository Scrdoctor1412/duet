import 'package:duet/duet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class WatchDuet extends SimpleDuet<int> {
  WatchDuet() : super(initialData: 0);

  void increment() => emitData(data + 1);

  void load() => emitUi(const UiLoading());
}

class GlobalWatchDuet extends SimpleDuet<int> {
  static int creations = 0;

  GlobalWatchDuet() : super(initialData: creations++);

  @override
  bool get isGlobal => true;
}

class GlobalWatchView extends DuetView<GlobalWatchDuet> {
  const GlobalWatchView({super.key});

  @override
  GlobalWatchDuet bindDuet() => GlobalWatchDuet();

  @override
  Widget build(BuildContext context, GlobalWatchDuet duet) {
    return const SizedBox();
  }
}

void main() {
  tearDown(DuetRegistry.resetAll);

  testWidgets('DuetWatch declares only the concrete ViewModel type',
      (tester) async {
    final duet = WatchDuet();
    var builds = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: DuetWatch<WatchDuet>.data(
          viewModel: duet,
          builder: (context, value) {
            builds++;
            return Text('${value.data}');
          },
        ),
      ),
    );

    expect(find.text('0'), findsOneWidget);
    duet.load();
    await tester.pump();
    expect(builds, 1);

    duet.increment();
    await tester.pump();
    expect(find.text('1'), findsOneWidget);
    expect(builds, 2);
  });

  testWidgets('DuetView binds a new global candidate only once',
      (tester) async {
    GlobalWatchDuet.creations = 0;

    await tester.pumpWidget(const MaterialApp(home: GlobalWatchView()));

    expect(GlobalWatchDuet.creations, 1);
  });
}
