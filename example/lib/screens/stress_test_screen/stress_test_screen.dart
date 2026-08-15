import 'package:flutter/material.dart';
import 'package:duet/duet.dart';
import 'package:duet_example/screens/stress_test_screen/states/stress_test_state.dart';
import 'package:duet_example/screens/stress_test_screen/stress_test_viewmodel.dart';
import 'package:duet_example/screens/stress_test_screen/widgets/batching_benchmark_section.dart';
import 'package:duet_example/screens/stress_test_screen/widgets/benchmark_summary_card.dart';
import 'package:duet_example/screens/stress_test_screen/widgets/high_freq_counter_section.dart';
import 'package:duet_example/screens/stress_test_screen/widgets/ref_counting_spawner_section.dart';
import 'package:duet_example/screens/stress_test_screen/widgets/selector_matrix_section.dart';
import 'package:duet_example/screens/stress_test_screen/widgets/side_effect_flood_section.dart';

class StressTestScreen extends DuetView<StressTestViewModel> {
  const StressTestScreen({super.key});

  @override
  StressTestViewModel bindDuet() => StressTestViewModel();

  @override
  Widget build(BuildContext context, StressTestViewModel duet) {
    final theme = Theme.of(context);

    return DuetListener<StressTestViewModel, BenchmarkCompleteEvent>(
      onEvent: (context, event) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.emoji_events_rounded, color: Colors.amber),
                const SizedBox(width: 10),
                Expanded(child: Text(event.report)),
              ],
            ),
            backgroundColor: Colors.grey.shade900,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      },
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              const Icon(Icons.bolt, color: Colors.amber),
              const SizedBox(width: 8),
              Text(
                "Duet Stress Test Hub",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              tooltip: "Reset Benchmark",
              onPressed: () {
                duet.stopTicker();
                duet.stopEventFlood();
                duet.resetMatrix();
                duet.clearAllSubVMs();
              },
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: const [
            BenchmarkSummaryCard(),
            SizedBox(height: 12),
            HighFreqCounterSection(),
            SizedBox(height: 12),
            SelectorMatrixSection(),
            SizedBox(height: 12),
            BatchingBenchmarkSection(),
            SizedBox(height: 12),
            RefCountingSpawnerSection(),
            SizedBox(height: 12),
            SideEffectFloodSection(),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
