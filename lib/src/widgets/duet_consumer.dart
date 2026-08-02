import 'package:flutter/widgets.dart';
import 'package:duet/src/core/duet_core.dart';
import 'package:duet/src/core/duet_provider.dart';

/// Mixin attached to a [StatefulWidget]'s [State] to manage lifecycle and listen to multiple [Listenable] instances.
mixin DuetConsumer<T extends StatefulWidget> on State<T> {
  /// List of [Listenable] objects to subscribe to.
  List<Listenable> get listenTo;

  /// Optional bound ViewModel instance for reference counting lifecycle management ([Duet.autoDispose]).
  Duet? get viewModel => null;

  @override
  void initState() {
    super.initState();
    viewModel?.retain();
    for (final listenable in listenTo) {
      listenable.addListener(_rebuild);
    }
  }

  @override
  void dispose() {
    for (final listenable in listenTo) {
      listenable.removeListener(_rebuild);
    }
    if (viewModel != null) {
      viewModel!.release(() {
        unregisterVM(viewModel!);
      });
    }
    super.dispose();
  }

  /// Internal callback triggering widget rebuild on notification updates.
  void _rebuild() {
    if (mounted) {
      setState(() {});
    }
  }
}

/// Backward compatibility alias for [DuetConsumer].
typedef ReactiveConsumer<T extends StatefulWidget> = DuetConsumer<T>;
