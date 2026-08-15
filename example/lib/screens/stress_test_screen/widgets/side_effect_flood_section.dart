import 'package:flutter/material.dart';
import 'package:duet/duet.dart';
import 'package:duet_example/screens/stress_test_screen/states/stress_test_state.dart';
import 'package:duet_example/screens/stress_test_screen/stress_test_viewmodel.dart';

class SideEffectFloodSection extends StatelessWidget {
  const SideEffectFloodSection({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = DuetScope.of<StressTestViewModel>(context);
    final theme = Theme.of(context);

    return DuetListener<StressTestViewModel, FloodPingEvent>(
      onEvent: (context, event) {
        vm.recordReceivedEvent();
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.waves_rounded, color: Colors.indigo),
                  const SizedBox(width: 8),
                  Text(
                    "5. Event Stream Side-Effect Flood",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                "Ph  t h  ng ngh  n s   ?ki   n Side-Effect 1 l   n qua eventStream. Ki   m tra DuetListener ti   p nh   n      y      ?100% kh  ng m   t m  t.",
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: Colors.grey[700]),
              ),
              const SizedBox(height: 16),
              DuetBuilder<StressTestData, StressTestUiBehavior>(
                builder: (context, data) {
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.indigo.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.indigo.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Events Emitted",
                                    style: TextStyle(
                                        fontSize: 11, color: Colors.grey),
                                  ),
                                  Text(
                                    "${data.eventsEmitted}",
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.indigo,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.cyan.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.cyan.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Events Received",
                                    style: TextStyle(
                                        fontSize: 11, color: Colors.grey),
                                  ),
                                  Text(
                                    "${data.eventsReceived}",
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.cyan,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: vm.startEventFlood,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: data.isEventFloodRunning
                                ? Colors.redAccent
                                : Colors.indigo,
                            foregroundColor: Colors.white,
                          ),
                          icon: Icon(
                            data.isEventFloodRunning
                                ? Icons.stop_rounded
                                : Icons.thunderstorm_rounded,
                          ),
                          label: Text(
                            data.isEventFloodRunning
                                ? "STOP EVENT FLOOD"
                                : "START HIGH-THROUGHPUT EVENT FLOOD (~1000/s)",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
