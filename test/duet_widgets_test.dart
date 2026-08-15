import 'package:duet/duet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class InstanceDuet extends Duet<int, String> {
  InstanceDuet() : super(initialData: 0, initialBehavior: 'idle');

  void increment() => emitData(data + 1);

  void setStatus(String status) => emitUi(status);

  void send(String message) => emitEffect(message);
}

class ReadyView extends DuetView<InstanceDuet> {
  final InstanceDuet instance;
  final void Function(InstanceDuet duet) onReady;

  const ReadyView({
    super.key,
    required this.instance,
    required this.onReady,
  });

  @override
  InstanceDuet bindDuet() => instance;

  @override
  void onDuetReady(InstanceDuet duet) => onReady(duet);

  @override
  Widget build(BuildContext context, InstanceDuet duet) {
    return duet.watchData(
      builder: (context, data) => Text('$data'),
    );
  }
}

void main() {
  testWidgets('instance helpers react to their matching Duet channels', (
    tester,
  ) async {
    final duet = InstanceDuet();
    var dataBuilds = 0;
    var uiBuilds = 0;
    var selectedBuilds = 0;
    String? effect;

    await tester.pumpWidget(
      MaterialApp(
        home: duet.listen<String>(
          onEffect: (context, value) => effect = value,
          child: Column(
            children: [
              duet.watchData(
                builder: (context, data) {
                  dataBuilds++;
                  return Text('data:$data');
                },
              ),
              duet.watchUi(
                builder: (context, ui) {
                  uiBuilds++;
                  return Text('ui:$ui');
                },
              ),
              duet.selectData<bool>(
                select: (data) => data.isEven,
                builder: (context, isEven) {
                  selectedBuilds++;
                  return Text('even:$isEven');
                },
              ),
            ],
          ),
        ),
      ),
    );

    duet.setStatus('loading');
    await tester.pump();
    expect(dataBuilds, 1);
    expect(uiBuilds, 2);
    expect(selectedBuilds, 1);

    duet.increment();
    await tester.pump();
    expect(find.text('data:1'), findsOneWidget);
    expect(find.text('even:false'), findsOneWidget);
    expect(dataBuilds, 2);
    expect(selectedBuilds, 2);

    duet.send('saved');
    await tester.pump();
    expect(effect, 'saved');
  });

  testWidgets('DuetView calls onDuetReady once and owns the instance', (
    tester,
  ) async {
    final duet = InstanceDuet();
    var readyCalls = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: ReadyView(
          instance: duet,
          onReady: (_) => readyCalls++,
        ),
      ),
    );
    await tester.pump();

    expect(readyCalls, 1);
    expect(duet.isDisposed, isFalse);

    await tester.pumpWidget(const SizedBox());
    expect(duet.isDisposed, isTrue);
  });
}
