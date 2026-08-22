import 'package:flutter/widgets.dart';

/// Helper widget that subscribes to a list of arbitrary [Listenable] instances and rebuilds its widget subtree.
class DuetListenableBuilder extends StatefulWidget {
  /// List of [Listenable] objects to listen to.
  final List<Listenable> listenTo;

  /// Builder callback producing the widget tree.
  final WidgetBuilder builder;

  const DuetListenableBuilder({
    super.key,
    required this.listenTo,
    required this.builder,
  });

  @override
  State<DuetListenableBuilder> createState() => _DuetListenableBuilderState();
}

class _DuetListenableBuilderState extends State<DuetListenableBuilder> {
  List<Listenable> _attachedListenables = const [];

  @override
  void initState() {
    super.initState();
    _syncListenables();
  }

  @override
  void didUpdateWidget(covariant DuetListenableBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncListenables();
  }

  void _syncListenables() {
    final nextListenables = _uniqueByIdentity(widget.listenTo);

    for (final listenable in _attachedListenables) {
      if (!_containsIdentical(nextListenables, listenable)) {
        listenable.removeListener(_rebuild);
      }
    }
    for (final listenable in nextListenables) {
      if (!_containsIdentical(_attachedListenables, listenable)) {
        listenable.addListener(_rebuild);
      }
    }
    _attachedListenables = nextListenables;
  }

  List<Listenable> _uniqueByIdentity(Iterable<Listenable> values) {
    final result = <Listenable>[];
    for (final value in values) {
      if (!_containsIdentical(result, value)) result.add(value);
    }
    return List.unmodifiable(result);
  }

  bool _containsIdentical(
    Iterable<Listenable> values,
    Listenable candidate,
  ) {
    return values.any((value) => identical(value, candidate));
  }

  void _rebuild() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    for (final listenable in _attachedListenables) {
      listenable.removeListener(_rebuild);
    }
    _attachedListenables = const [];
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context);
  }
}

/// Backward compatibility alias for [DuetListenableBuilder].
typedef ReactiveListenableBuilder = DuetListenableBuilder;
