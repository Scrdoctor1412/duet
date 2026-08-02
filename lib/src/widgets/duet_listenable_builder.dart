import 'package:flutter/widgets.dart';

/// Widget tr�?giúp bọc và lắng nghe danh sách các [Listenable] thông thường (không qua ViewModel).
class DuetListenableBuilder extends StatefulWidget {
  /// Danh sách các [Listenable] cần lắng nghe.
  final List<Listenable> listenTo;

  /// Hàm builder tạo cây Widget.
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

/// Alias cho ReactiveListenableBuilder
typedef ReactiveListenableBuilder = DuetListenableBuilder;
