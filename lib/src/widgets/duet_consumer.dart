import 'package:flutter/widgets.dart';
import 'package:duet/src/core/duet_core.dart';
import 'package:duet/src/core/duet_provider.dart';

/// Mixin attached to a [StatefulWidget]'s [State] to manage lifecycle and listen to multiple [Listenable] instances.
mixin DuetConsumer<T extends StatefulWidget> on State<T> {
  List<Listenable> _attachedListenables = const [];
  Duet? _attachedViewModel;

  /// List of [Listenable] objects to subscribe to.
  List<Listenable> get listenTo;

  /// Optional bound ViewModel instance for reference counting lifecycle management ([Duet.autoDispose]).
  Duet? get viewModel => null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncDependencies();
  }

  @override
  void didUpdateWidget(covariant T oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncDependencies();
  }

  @override
  void dispose() {
    for (final listenable in _attachedListenables) {
      listenable.removeListener(_rebuild);
    }
    _attachedListenables = const [];

    final attachedViewModel = _attachedViewModel;
    _attachedViewModel = null;
    if (attachedViewModel != null) releaseDuet(attachedViewModel);
    super.dispose();
  }

  void _syncDependencies() {
    final nextListenables = _uniqueByIdentity(listenTo);

    for (final oldListenable in _attachedListenables) {
      if (!_containsIdentical(nextListenables, oldListenable)) {
        oldListenable.removeListener(_rebuild);
      }
    }
    for (final newListenable in nextListenables) {
      if (!_containsIdentical(_attachedListenables, newListenable)) {
        newListenable.addListener(_rebuild);
      }
    }
    _attachedListenables = nextListenables;

    final nextViewModel = viewModel;
    if (!identical(_attachedViewModel, nextViewModel)) {
      // Retain first so swapping aliases cannot briefly dispose a live model.
      nextViewModel?.retain();
      final previousViewModel = _attachedViewModel;
      _attachedViewModel = nextViewModel;
      if (previousViewModel != null) releaseDuet(previousViewModel);
    }
  }

  List<Listenable> _uniqueByIdentity(Iterable<Listenable> values) {
    final result = <Listenable>[];
    for (final value in values) {
      if (!_containsIdentical(result, value)) result.add(value);
    }
    return List.unmodifiable(result);
  }

  bool _containsIdentical(Iterable<Listenable> values, Listenable candidate) {
    return values.any((value) => identical(value, candidate));
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
