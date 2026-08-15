import 'dart:async';

import 'package:duet/duet.dart';
import 'package:flutter_test/flutter_test.dart';

class CounterDuet extends SimpleDuet<int> {
  CounterDuet() : super(initialData: 0);

  void increment() => emitData(data + 1);

  Future<int?> load(Future<int> Function() task) => runData(task);
}

class NestedBatchDuet extends SimpleDuet<int> {
  NestedBatchDuet() : super(initialData: 0);

  void updateInsideNestedBatch() {
    batch(() {
      batch(() => emitData(1));
      emitData(2);
    });
  }
}

class LatestDuet extends SimpleDuet<int> {
  LatestDuet() : super(initialData: 0);

  Future<int?> loadLatest(Future<int> Function() task) {
    return runLatestData(task);
  }
}

void main() {
  test('standard UiState factories expose payloads', () {
    expect(const UiState.idle(), isA<UiIdle>());
    expect(const DuetStatus.loading(), isA<UiLoading>());
    expect(const UiState.loading('products'), isA<UiLoading>());
    expect((const UiState.success('done') as UiSuccess).message, 'done');
    expect((const UiState.error('failed') as UiError).message, 'failed');
  });

  test('SimpleDuet removes custom state classes for local synchronous state',
      () {
    final duet = CounterDuet();

    duet.increment();

    expect(duet.data, 1);
    expect(duet.status, isA<UiIdle>());
  });

  test('runData preserves data while loading and commits data with success',
      () async {
    final duet = CounterDuet();
    final completer = Completer<int>();
    final statuses = <UiState>[];
    duet.behaviorNotifier.addListener(() => statuses.add(duet.status));

    final pending = duet.load(() => completer.future);

    expect(duet.data, 0);
    expect(duet.status, isA<UiLoading>());

    completer.complete(42);
    expect(await pending, 42);
    expect(duet.data, 42);
    expect(duet.status, isA<UiSuccess>());
    expect(statuses, hasLength(2));
  });

  test('runData keeps previous data and exposes the original error', () async {
    final duet = CounterDuet();
    final error = StateError('network');

    final result = await duet.load(() async => throw error);

    expect(result, isNull);
    expect(duet.data, 0);
    expect(duet.status, isA<UiError>());
    expect((duet.status as UiError).error, same(error));
  });

  test('nested batches notify once after the outer transaction completes', () {
    final duet = NestedBatchDuet();
    var notifications = 0;
    duet.dataNotifier.addListener(() => notifications++);

    duet.updateInsideNestedBatch();

    expect(duet.data, 2);
    expect(notifications, 1);
  });

  test('runLatest ignores an older task that completes last', () async {
    final duet = LatestDuet();
    final first = Completer<int>();
    final second = Completer<int>();

    final firstTask = duet.loadLatest(() => first.future);
    final secondTask = duet.loadLatest(() => second.future);

    second.complete(2);
    expect(await secondTask, 2);
    expect(duet.data, 2);
    expect(duet.status, isA<UiSuccess>());

    first.complete(1);
    expect(await firstTask, 1);
    expect(duet.data, 2);
    expect(duet.status, isA<UiSuccess>());
  });

  test('stale runLatest failure cannot replace the latest success', () async {
    final duet = LatestDuet();
    final first = Completer<int>();
    final second = Completer<int>();

    final firstTask = duet.loadLatest(() => first.future);
    final secondTask = duet.loadLatest(() => second.future);

    second.complete(7);
    await secondTask;
    first.completeError(StateError('stale'));
    await firstTask;

    expect(duet.data, 7);
    expect(duet.status, isA<UiSuccess>());
  });
}
