import 'package:flutter/material.dart';
import 'package:duet/duet.dart';
import 'package:duet_example/screens/stress_test_screen/states/stress_test_state.dart';
import 'package:duet_example/screens/stress_test_screen/stress_test_viewmodel.dart';

class SelectorMatrixSection extends StatelessWidget {
  const SelectorMatrixSection({super.key});

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
                const Icon(Icons.grid_view_rounded, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "2. DuetSelector Matrix (120 Cells Stress Test)",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              "Ma tr   n 120    d   ?li   u      c l   p. Khi c   p nh   t ng   u nhi  n 5   , ch   ?    ng 5         re-render nh   ?DuetSelector (Badge g  c th   ?hi   n s   ?l   n re-render t   ng   ).",
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => vm.mutateRandomCells(count: 5),
                  icon: const Icon(Icons.flash_on_rounded, size: 16),
                  label: const Text("MUTATE 5 RANDOM CELLS"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => vm.mutateRandomCells(count: 30),
                  icon: const Icon(Icons.electric_bolt_rounded, size: 16),
                  label: const Text("BURST 30 CELLS"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                  ),
                ),
                IconButton(
                  onPressed: vm.resetMatrix,
                  icon: const Icon(Icons.refresh),
                  tooltip: "Reset Ma tr   n",
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 260,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 70,
                  mainAxisExtent: 45,
                  mainAxisSpacing: 6,
                  crossAxisSpacing: 6,
                ),
                itemCount: 120,
                itemBuilder: (context, index) {
                  return _MatrixCellWidget(cellIndex: index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MatrixCellWidget extends StatefulWidget {
  final int cellIndex;
  const _MatrixCellWidget({required this.cellIndex});

  @override
  State<_MatrixCellWidget> createState() => _MatrixCellWidgetState();
}

class _MatrixCellWidgetState extends State<_MatrixCellWidget> {
  int _cellBuildCount = 0;

  @override
  Widget build(BuildContext context) {
    return DuetSelector<StressTestViewModel, MatrixCellData?>(
      selector: (vm) {
        if (widget.cellIndex < vm.data.matrixCells.length) {
          return vm.data.matrixCells[widget.cellIndex];
        }
        return null;
      },
      builder: (context, cellData) {
        if (cellData == null) return const SizedBox.shrink();
        _cellBuildCount++;

        final bool isUpdatedRecently = cellData.updateCount > 0;
        final color = isUpdatedRecently
            ? Colors.blue.shade600
            : Colors.grey.shade300;

        return Container(
          decoration: BoxDecoration(
            color: isUpdatedRecently
                ? Colors.blue.withOpacity(0.15)
                : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color, width: isUpdatedRecently ? 1.5 : 1),
          ),
          padding: const EdgeInsets.all(2),
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "#${cellData.id}",
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      "${cellData.value}",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isUpdatedRecently ? Colors.blue.shade900 : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade700,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                  child: Text(
                    "$_cellBuildCount",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
