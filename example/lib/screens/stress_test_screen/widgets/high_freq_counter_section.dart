import 'package:flutter/material.dart';
import 'package:duet/duet.dart';
import 'package:duet_example/screens/stress_test_screen/states/stress_test_state.dart';
import 'package:duet_example/screens/stress_test_screen/stress_test_viewmodel.dart';

class HighFreqCounterSection extends StatefulWidget {
  const HighFreqCounterSection({super.key});

  @override
  State<HighFreqCounterSection> createState() => _HighFreqCounterSectionState();
}

class _HighFreqCounterSectionState extends State<HighFreqCounterSection> {
  int _localBuildCount = 0;

  @override
  Widget build(BuildContext context) {
    final vm = DuetScope.of<StressTestViewModel>(context);
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.speed_rounded, color: Colors.deepOrange),
                const SizedBox(width: 8),
                Text(
                  "1. High-Frequency Ticker (60 FPS Test)",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              "Ki   m th   ?kh   ?n  ng ch   u t   i th  ng b  o tr   ng th  i t   n su   t cao li  n t   c (16ms per tick) m   kh  ng l  m lag UI thread.",
              style:
                  theme.textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.deepOrange.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.deepOrange.withValues(alpha: 0.2),
                ),
              ),
              child: DuetSelector<StressTestViewModel, int>(
                selector: (vm) => vm.data.tickerCount,
                builder: (context, count) {
                  _localBuildCount++;
                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Ticker Value",
                                style:
                                    TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              Text(
                                "$count",
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepOrange,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                "Selector Rebuilds",
                                style:
                                    TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      Colors.deepOrange.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  "$_localBuildCount",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepOrange,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            DuetBuilder<StressTestData, StressTestUiBehavior>(
              builder: (context, data) {
                return Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: vm.toggleTicker,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: data.isTickerRunning
                              ? Colors.redAccent
                              : Colors.deepOrange,
                          foregroundColor: Colors.white,
                        ),
                        icon: Icon(
                          data.isTickerRunning
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                        ),
                        label: Text(
                          data.isTickerRunning
                              ? "STOP TICKER"
                              : "START 60 FPS TICKER",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    PopupMenuButton<int>(
                      initialValue: data.tickerIntervalMs,
                      onSelected: vm.setTickerInterval,
                      tooltip: "Ch   n T   n S   ?Ticker",
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Text("${data.tickerIntervalMs} ms"),
                            const Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                            value: 16, child: Text("16 ms (~60 FPS)")),
                        PopupMenuItem(
                            value: 33, child: Text("33 ms (~30 FPS)")),
                        PopupMenuItem(
                            value: 100, child: Text("100 ms (~10 FPS)")),
                        PopupMenuItem(value: 500, child: Text("500 ms (Slow)")),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
