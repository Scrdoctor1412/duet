import 'dart:async';
import 'dart:math';
import 'package:duet/duet.dart';
import 'package:duet_example/screens/stress_test_screen/states/stress_test_state.dart';

class StressTestViewModel extends Duet<StressTestData, StressTestUiBehavior> {
  Timer? _tickerTimer;
  Timer? _floodTimer;
  final Random _random = Random();

  StressTestViewModel()
      : super(
          initialData: const StressTestData(),
          initialBehavior: const StressTestUiIdle(),
        ) {
    _initDefaultMatrix();
  }

  void _initDefaultMatrix() {
    final cells = List.generate(
      120,
      (index) => MatrixCellData(id: index, value: 0, updateCount: 0),
    );
    emitData(data.copyWith(matrixCells: cells));
  }

  // --- 1. Ticker 60 FPS Test ---
  void toggleTicker() {
    if (data.isTickerRunning) {
      stopTicker();
    } else {
      startTicker();
    }
  }

  void startTicker() {
    _tickerTimer?.cancel();
    emitData(data.copyWith(isTickerRunning: true));
    emitUi(const StressTestUiRunning('60 FPS High-Frequency Ticker'));

    _tickerTimer = Timer.periodic(
      Duration(milliseconds: data.tickerIntervalMs),
      (_) {
        emitData(
          data.copyWith(
            tickerCount: data.tickerCount + 1,
            totalStateEmits: data.totalStateEmits + 1,
          ),
        );
      },
    );
  }

  void stopTicker() {
    _tickerTimer?.cancel();
    _tickerTimer = null;
    emitData(data.copyWith(isTickerRunning: false));
    emitUi(const StressTestUiIdle());
  }

  void setTickerInterval(int intervalMs) {
    final wasRunning = data.isTickerRunning;
    if (wasRunning) stopTicker();
    emitData(data.copyWith(tickerIntervalMs: intervalMs));
    if (wasRunning) startTicker();
  }

  // --- 2. DuetSelector Matrix Test ---
  void mutateRandomCells({int count = 5}) {
    if (data.matrixCells.isEmpty) return;

    final updatedCells = List<MatrixCellData>.from(data.matrixCells);
    for (int i = 0; i < count; i++) {
      final randomIndex = _random.nextInt(updatedCells.length);
      final current = updatedCells[randomIndex];
      updatedCells[randomIndex] = current.copyWith(
        value: _random.nextInt(1000),
        updateCount: current.updateCount + 1,
      );
    }

    emitData(
      data.copyWith(
        matrixCells: updatedCells,
        totalStateEmits: data.totalStateEmits + 1,
      ),
    );
  }

  void resetMatrix() {
    _initDefaultMatrix();
  }

  // --- 3. Batching Benchmark Test ---
  Future<void> runBatchingBenchmark() async {
    if (data.isBatchingTestRunning) return;

    emitData(data.copyWith(isBatchingTestRunning: true));
    emitUi(const StressTestUiRunning('Batching vs Non-Batching Benchmark'));

    int unbatchedCount = 0;
    int batchedCount = 0;

    // Direct listener counters
    void unbatchedListener() => unbatchedCount++;
    void batchedListener() => batchedCount++;

    dataNotifier.addListener(unbatchedListener);

    // Test 1: 100 sequential emitData updates without batch
    for (int i = 0; i < 100; i++) {
      emitData(data.copyWith(tickerCount: data.tickerCount + 1));
    }

    dataNotifier.removeListener(unbatchedListener);
    dataNotifier.addListener(batchedListener);

    // Test 2: 100 sequential emitData updates WITH batch()
    batch(() {
      for (int i = 0; i < 100; i++) {
        emitData(data.copyWith(tickerCount: data.tickerCount + 1));
      }
    });

    dataNotifier.removeListener(batchedListener);

    emitData(
      data.copyWith(
        unbatchedNotifies: unbatchedCount,
        batchedNotifies: batchedCount,
        isBatchingTestRunning: false,
        totalStateEmits: data.totalStateEmits + 101,
      ),
    );

    emitUi(const StressTestUiIdle());
    emitEffect(
      BenchmarkCompleteEvent(
        'Kh  ng Batch: $unbatchedCount notifications ph  t ra\n'
        'C   Batching: $batchedCount notification duy nh   t ph  t ra! (Ti   t ki   m ${((1 - batchedCount / unbatchedCount) * 100).toStringAsFixed(1)}% rebuilds)',
      ),
    );
  }

  // --- 4. Event Stream Side-Effect Flood Test ---
  void startEventFlood() {
    if (data.isEventFloodRunning) {
      stopEventFlood();
      return;
    }

    emitData(data.copyWith(
        isEventFloodRunning: true, eventsEmitted: 0, eventsReceived: 0));
    emitUi(const StressTestUiRunning('Event Flood Stream Test'));

    int seq = 0;
    // Emit 100 events per tick every 10ms (~10,000 events/sec)
    _floodTimer = Timer.periodic(const Duration(milliseconds: 10), (_) {
      for (int i = 0; i < 10; i++) {
        seq++;
        emitEffect(FloodPingEvent(seq, DateTime.now()));
      }
      emitData(data.copyWith(eventsEmitted: seq));
    });
  }

  void recordReceivedEvent() {
    emitData(data.copyWith(eventsReceived: data.eventsReceived + 1));
  }

  void stopEventFlood() {
    _floodTimer?.cancel();
    _floodTimer = null;
    emitData(data.copyWith(isEventFloodRunning: false));
    emitUi(const StressTestUiIdle());
  }

  // --- 5. Dynamic Sub-VM Spawner Test ---
  void spawnSubVM() {
    emitData(data.copyWith(spawnedSubVMCount: data.spawnedSubVMCount + 1));
  }

  void removeSubVM() {
    if (data.spawnedSubVMCount > 0) {
      emitData(data.copyWith(spawnedSubVMCount: data.spawnedSubVMCount - 1));
    }
  }

  void spawnMultipleSubVMs(int count) {
    emitData(data.copyWith(spawnedSubVMCount: data.spawnedSubVMCount + count));
  }

  void clearAllSubVMs() {
    emitData(data.copyWith(spawnedSubVMCount: 0));
  }

  @override
  void dispose() {
    _tickerTimer?.cancel();
    _floodTimer?.cancel();
    super.dispose();
  }
}

// Child ViewModel used in RefCounting / AutoDispose test
class DummyChildViewModel extends Duet<int, String> {
  final String vmId;

  DummyChildViewModel({required this.vmId})
      : super(initialData: 0, initialBehavior: 'Active');

  void increment() {
    emitData(data + 1);
  }
}
