import 'package:flutter/widgets.dart';
import 'package:duet/src/core/duet_core.dart';
import 'package:duet/src/core/duet_provider.dart';
import 'package:duet/src/widgets/duet_builder.dart';
import 'package:duet/src/widgets/duet_scope.dart';

/// ViewModel-first reactive builder.
///
/// This is the concise alternative to `DuetBuilder<D, B>` for screens that
/// prefer declaring only their concrete Duet type:
///
/// ```dart
/// DuetWatch<ProfileDuet>.data(
///   builder: (context, duet) => Text(duet.data.name),
/// )
/// ```
class DuetWatch<VM extends Duet> extends StatefulWidget {
  final VM? viewModel;
  final Widget Function(BuildContext context, VM duet) builder;
  final DuetTarget target;

  /// Listens to business data changes.
  const DuetWatch({
    super.key,
    this.viewModel,
    required this.builder,
  }) : target = DuetTarget.data;

  /// Listens to business data changes.
  const DuetWatch.data({
    super.key,
    this.viewModel,
    required this.builder,
  }) : target = DuetTarget.data;

  /// Listens to UI behavior changes.
  const DuetWatch.ui({
    super.key,
    this.viewModel,
    required this.builder,
  }) : target = DuetTarget.ui;

  /// Listens to both business data and UI behavior changes.
  const DuetWatch.both({
    super.key,
    this.viewModel,
    required this.builder,
  }) : target = DuetTarget.both;

  @override
  State<DuetWatch<VM>> createState() => _DuetWatchState<VM>();
}

class _DuetWatchState<VM extends Duet> extends State<DuetWatch<VM>> {
  VM? _effectiveVM;
  List<ValueNotifier<dynamic>> _notifiers = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncViewModel(widget.viewModel ?? DuetScope.of<VM>(context));
  }

  @override
  void didUpdateWidget(covariant DuetWatch<VM> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.viewModel != widget.viewModel) {
      _syncViewModel(widget.viewModel ?? DuetScope.of<VM>(context));
    } else if (oldWidget.target != widget.target) {
      _unsubscribe();
      _subscribe();
    }
  }

  void _syncViewModel(VM viewModel) {
    if (identical(_effectiveVM, viewModel)) return;
    _detach();
    _effectiveVM = viewModel;
    _effectiveVM!.retain();
    _subscribe();
  }

  void _subscribe() {
    final duet = _effectiveVM!;
    _notifiers = switch (widget.target) {
      DuetTarget.data => [duet.dataNotifier],
      DuetTarget.ui => [duet.behaviorNotifier],
      DuetTarget.both => [duet.dataNotifier, duet.behaviorNotifier],
    };
    for (final notifier in _notifiers) {
      notifier.addListener(_rebuild);
    }
  }

  void _unsubscribe() {
    for (final notifier in _notifiers) {
      notifier.removeListener(_rebuild);
    }
    _notifiers = [];
  }

  void _detach() {
    _unsubscribe();
    if (_effectiveVM != null) {
      releaseDuet(_effectiveVM!);
      _effectiveVM = null;
    }
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _detach();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _effectiveVM!);
  }
}
