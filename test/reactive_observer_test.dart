import 'package:flutter_test/flutter_test.dart';
import 'package:duet/duet.dart';

class SampleData {
  final int count;
  const SampleData({required this.count});
}

class TestObserverViewModel extends Duet<SampleData, UiState> {
  TestObserverViewModel()
      : super(
          initialData: const SampleData(count: 0),
          initialBehavior: const UiIdle(),
        );

  void increment() {
    emit(data: SampleData(count: data.count + 1), ui: const UiSuccess());
  }

  void triggerEffect() {
    emitEvent('NavigationEvent');
  }
}

class MockObserver extends DuetObserver {
  int stateEmitCount = 0;
  int effectEmitCount = 0;
  Object? lastData;
  Object? lastUi;
  Object? lastEffect;

  @override
  void onStateEmitted(Duet vm, {Object? data, Object? ui}) {
    stateEmitCount++;
    lastData = data;
    lastUi = ui;
  }

  @override
  void onEventEmitted(Duet vm, Object event) {
    effectEmitCount++;
    lastEffect = event;
  }
}

void main() {
  tearDown(() {
    DuetState.observer = null;
    DuetRegistry.resetAll();
  });

  test('DuetObserver triggers onStateEmitted and onEventEmitted', () {
    final observer = MockObserver();
    DuetState.observer = observer;

    final vm = TestObserverViewModel();
    expect(observer.stateEmitCount, equals(0));

    vm.increment();
    expect(observer.stateEmitCount, equals(1));
    expect((observer.lastData as SampleData).count, equals(1));
    expect(observer.lastUi, isA<UiSuccess>());

    vm.triggerEffect();
    expect(observer.effectEmitCount, equals(1));
    expect(observer.lastEffect, equals('NavigationEvent'));
  });

  test('Default Type Generic Duet<D, B> works properly', () {
    final vm = TestObserverViewModel();
    expect(vm.ui, isA<UiIdle>());
    expect(vm.data.count, equals(0));
  });
}
