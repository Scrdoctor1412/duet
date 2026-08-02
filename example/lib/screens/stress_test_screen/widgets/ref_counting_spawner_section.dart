import 'package:flutter/material.dart';
import 'package:duet/duet.dart';
import 'package:duet_example/screens/stress_test_screen/states/stress_test_state.dart';
import 'package:duet_example/screens/stress_test_screen/stress_test_viewmodel.dart';

class RefCountingSpawnerSection extends StatelessWidget {
  const RefCountingSpawnerSection({super.key});

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
                const Icon(Icons.recycling_rounded, color: Colors.teal),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "4. AutoDispose & RefCounting Spawner",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              "T   o & h   y h  ng lo   t Sub-ViewModel dynamically. Khi Widget unmount, refCount gi   m v   ?0 v   t   ?     ng dispose kh   i RAM.",
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
            ),
            const SizedBox(height: 12),
            DuetBuilder<StressTestData, StressTestUiBehavior>(
              builder: (context, data) {
                return Column(
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ElevatedButton.icon(
                          onPressed: vm.spawnSubVM,
                          icon: const Icon(Icons.add_circle_outline, size: 16),
                          label: const Text("+1 SUB-VM"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => vm.spawnMultipleSubVMs(10),
                          icon: const Icon(Icons.library_add, size: 16),
                          label: const Text("+10 SUB-VMS"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal.shade700,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: vm.clearAllSubVMs,
                          icon: const Icon(Icons.delete_sweep_outlined, size: 16),
                          label: const Text("CLEAR ALL"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pink.shade700,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 150,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.teal.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.teal.withOpacity(0.2)),
                      ),
                      child: data.spawnedSubVMCount == 0
                          ? const Center(
                              child: Text(
                                "Ch  a c   Sub-ViewModel n  o        c mount. Nh   n n  t      ?t   o m   i!",
                                style: TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            )
                          : GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 110,
                                mainAxisExtent: 38,
                                mainAxisSpacing: 6,
                                crossAxisSpacing: 6,
                              ),
                              itemCount: data.spawnedSubVMCount,
                              itemBuilder: (context, index) {
                                return _SubVMItemWidget(
                                  key: ValueKey(index),
                                  index: index,
                                );
                              },
                            ),
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

class _SubVMItemWidget extends DuetView<DummyChildViewModel> {
  final int index;
  const _SubVMItemWidget({super.key, required this.index});

  @override
  DummyChildViewModel bindDuet() {
    return DummyChildViewModel(vmId: 'sub_vm_$index');
  }

  @override
  Widget build(BuildContext context, DummyChildViewModel duet) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.teal.shade300),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              "#$index",
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          DuetSelector<DummyChildViewModel, int>(
            selector: (vm) => vm.data,
            builder: (context, val) {
              return Text(
                "$val",
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              );
            },
          ),
          const SizedBox(width: 2),
          InkWell(
            onTap: duet.increment,
            child: const Icon(Icons.add, size: 14, color: Colors.teal),
          ),
        ],
      ),
    );
  }
}
