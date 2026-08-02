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
  State<DuetListenableBuilder> createState() =>
      _DuetListenableBuilderState();
}

class _DuetListenableBuilderState
    extends State<DuetListenableBuilder> {
  @override
  void initState() {
    super.initState();
    for (final listenable in widget.listenTo) {
      listenable.addListener(_rebuild);
    }
  }

  @override
  void didUpdateWidget(covariant DuetListenableBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.listenTo != widget.listenTo) {
      for (final listenable in oldWidget.listenTo) {
        listenable.removeListener(_rebuild);
      }
      for (final listenable in widget.listenTo) {
        listenable.addListener(_rebuild);
      }
    }
  }

  void _rebuild() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    for (final listenable in widget.listenTo) {
      listenable.removeListener(_rebuild);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context);
  }
}

/// Backward compatibility alias for [DuetListenableBuilder].
typedef ReactiveListenableBuilder = DuetListenableBuilder;
