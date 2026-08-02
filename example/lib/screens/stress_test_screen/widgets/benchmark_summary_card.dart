import 'package:flutter/material.dart';
import 'package:duet/duet.dart';
import 'package:duet_example/screens/stress_test_screen/states/stress_test_state.dart';

class BenchmarkSummaryCard extends StatelessWidget {
  const BenchmarkSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primaryContainer,
              theme.colorScheme.surface,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.monitor_heart_rounded,
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 8),
                Text(
                  "System Health & Diagnostics",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_outline, color: Colors.green, size: 14),
                      SizedBox(width: 4),
                      Text(
                        "HEALTHY",
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            DuetBuilder<StressTestData, StressTestUiBehavior>.both(
              builder: (context, data, behavior) {
                final activeVMs = 1 + data.spawnedSubVMCount;
                final isRunning = behavior is StressTestUiRunning;

                return Column(
                  children: [
                    Row(
                      children: [
                        _buildMetricTile(
                          context,
                          label: "Active ViewModels",
                          value: "$activeVMs Active",
                          icon: Icons.memory_rounded,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 12),
                        _buildMetricTile(
                          context,
                          label: "Total State Emits",
                          value: "${data.totalStateEmits}",
                          icon: Icons.bolt_rounded,
                          color: Colors.orange,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildMetricTile(
                          context,
                          label: "Ticker State",
                          value: data.isTickerRunning
                              ? "${data.tickerIntervalMs}ms (~${(1000 / data.tickerIntervalMs).round()} FPS)"
                              : "STOPPED",
                          icon: Icons.timer_outlined,
                          color: data.isTickerRunning ? Colors.purple : Colors.grey,
                        ),
                        const SizedBox(width: 12),
                        _buildMetricTile(
                          context,
                          label: "Current Mode",
                          value: isRunning
                              ? (behavior as StressTestUiRunning).testName
                              : "Idle",
                          icon: Icons.science_outlined,
                          color: isRunning ? Colors.teal : Colors.indigo,
                        ),
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

  Widget _buildMetricTile(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: color.withOpacity(0.2),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
