import 'package:duet/duet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class TrackingNotifier extends ChangeNotifier {
  int addCount = 0;
  int removeCount = 0;

  @override
  void addListener(VoidCallback listener) {
    addCount++;
    super.addListener(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    removeCount++;
    super.removeListener(listener);
  }

  void ping() => notifyListeners();
}

void main() {
  testWidgets(
    'DuetListenableBuilder deduplicates and diffs subscriptions by identity',
    (tester) async {
      final first = TrackingNotifier();
      final second = TrackingNotifier();
      var builds = 0;

      Widget host(List<Listenable> listenables) {
        return Directionality(
          textDirection: TextDirection.ltr,
          child: DuetListenableBuilder(
            listenTo: listenables,
            builder: (_) {
              builds++;
              return const SizedBox();
            },
          ),
        );
      }

      await tester.pumpWidget(host([first, first]));
      expect(first.addCount, 1);

      first.ping();
      await tester.pump();
      expect(builds, 2);

      // A fresh list containing the same instance must not rewire listeners.
      await tester.pumpWidget(host([first]));
      expect(first.addCount, 1);
      expect(first.removeCount, 0);

      await tester.pumpWidget(host([second, second]));
      expect(first.removeCount, 1);
      expect(second.addCount, 1);

      final buildsAfterSwap = builds;
      first.ping();
      await tester.pump();
      expect(builds, buildsAfterSwap);

      second.ping();
      await tester.pump();
      expect(builds, buildsAfterSwap + 1);

      await tester.pumpWidget(const SizedBox());
      expect(second.removeCount, 1);
    },
  );
}
