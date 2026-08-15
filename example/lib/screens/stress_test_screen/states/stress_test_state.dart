import 'package:flutter/foundation.dart';

@immutable
class MatrixCellData {
  final int id;
  final int value;
  final int updateCount;

  const MatrixCellData({
    required this.id,
    required this.value,
    this.updateCount = 0,
  });

  MatrixCellData copyWith({int? value, int? updateCount}) {
    return MatrixCellData(
      id: id,
      value: value ?? this.value,
      updateCount: updateCount ?? this.updateCount,
    );
  }
}

@immutable
class StressTestData {
  // 1. High frequency ticker (60 FPS test)
  final int tickerCount;
  final bool isTickerRunning;
  final int tickerIntervalMs;

  // 2. Matrix selector stress test (120 cells)
  final List<MatrixCellData> matrixCells;

  // 3. Batching benchmark stats
  final int unbatchedNotifies;
  final int batchedNotifies;
  final bool isBatchingTestRunning;

  // 4. Side Effect Event Flood stats
  final int eventsEmitted;
  final int eventsReceived;
  final bool isEventFloodRunning;

  // 5. Dynamic Sub-VM / RefCounting Spawner stats
  final int spawnedSubVMCount;

  // 6. Metrics & counters
  final int totalStateEmits;

  const StressTestData({
    this.tickerCount = 0,
    this.isTickerRunning = false,
    this.tickerIntervalMs = 16,
    this.matrixCells = const [],
    this.unbatchedNotifies = 0,
    this.batchedNotifies = 0,
    this.isBatchingTestRunning = false,
    this.eventsEmitted = 0,
    this.eventsReceived = 0,
    this.isEventFloodRunning = false,
    this.spawnedSubVMCount = 0,
    this.totalStateEmits = 0,
  });

  StressTestData copyWith({
    int? tickerCount,
    bool? isTickerRunning,
    int? tickerIntervalMs,
    List<MatrixCellData>? matrixCells,
    int? unbatchedNotifies,
    int? batchedNotifies,
    bool? isBatchingTestRunning,
    int? eventsEmitted,
    int? eventsReceived,
    bool? isEventFloodRunning,
    int? spawnedSubVMCount,
    int? totalStateEmits,
  }) {
    return StressTestData(
      tickerCount: tickerCount ?? this.tickerCount,
      isTickerRunning: isTickerRunning ?? this.isTickerRunning,
      tickerIntervalMs: tickerIntervalMs ?? this.tickerIntervalMs,
      matrixCells: matrixCells ?? this.matrixCells,
      unbatchedNotifies: unbatchedNotifies ?? this.unbatchedNotifies,
      batchedNotifies: batchedNotifies ?? this.batchedNotifies,
      isBatchingTestRunning:
          isBatchingTestRunning ?? this.isBatchingTestRunning,
      eventsEmitted: eventsEmitted ?? this.eventsEmitted,
      eventsReceived: eventsReceived ?? this.eventsReceived,
      isEventFloodRunning: isEventFloodRunning ?? this.isEventFloodRunning,
      spawnedSubVMCount: spawnedSubVMCount ?? this.spawnedSubVMCount,
      totalStateEmits: totalStateEmits ?? this.totalStateEmits,
    );
  }
}

sealed class StressTestUiBehavior {
  const StressTestUiBehavior();
}

class StressTestUiIdle extends StressTestUiBehavior {
  const StressTestUiIdle();
}

class StressTestUiRunning extends StressTestUiBehavior {
  final String testName;
  const StressTestUiRunning(this.testName);
}

class StressTestUiAlert extends StressTestUiBehavior {
  final String title;
  final String message;
  final bool isError;
  const StressTestUiAlert({
    required this.title,
    required this.message,
    this.isError = false,
  });
}

sealed class StressTestEvent {
  const StressTestEvent();
}

class FloodPingEvent extends StressTestEvent {
  final int sequence;
  final DateTime timestamp;
  const FloodPingEvent(this.sequence, this.timestamp);
}

class BenchmarkCompleteEvent extends StressTestEvent {
  final String report;
  const BenchmarkCompleteEvent(this.report);
}
