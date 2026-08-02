import 'package:flutter/widgets.dart';
import 'package:duet/src/core/duet_core.dart';
import 'package:duet/src/core/duet_provider.dart';
import 'package:duet/src/widgets/duet_scope.dart';

/// Specifies which notifier target [DuetBuilder] should listen to.
enum DuetTarget {
  /// Listens to domain business data [Duet.dataNotifier].
  data,

  /// Listens to UI behavior state [Duet.behaviorNotifier].
  ui,

  /// Listens to both [Duet.dataNotifier] and [Duet.behaviorNotifier].
  both,
}

/// Backward compatibility alias for [DuetTarget].
typedef ReactiveTarget = DuetTarget;

/// A reactive widget that automatically listens to updates from a [Duet] instance
/// and rebuilds its widget subtree.
class DuetBuilder<D, B> extends StatefulWidget {
  /// Explicitly provided ViewModel instance (if omitted, looked up via [BuildContext]).
  final Duet<D, B>? viewModel;

  /// Builder callback receiving business data state [D].
  final Widget Function(BuildContext context, D data)? dataBuilder;

  /// Builder callback receiving UI behavior state [B].
  final Widget Function(BuildContext context, B ui)? uiBuilder;

  /// Builder callback receiving both business data [D] and UI behavior state [B].
  final Widget Function(BuildContext context, D data, B ui)? bothBuilder;

  /// The notifier target being listened to.
  final DuetTarget target;

  /// Default constructor listening to domain business data [Duet.dataNotifier].
  const DuetBuilder({
    super.key,
    this.viewModel,
    required Widget Function(BuildContext context, D data) builder,
  })  : dataBuilder = builder,
        uiBuilder = null,
        bothBuilder = null,
        target = DuetTarget.data;

  /// Listens to UI behavior state updates [Duet.behaviorNotifier].
  const DuetBuilder.ui({
    super.key,
    this.viewModel,
    required Widget Function(BuildContext context, B ui) builder,
  })  : uiBuilder = builder,
        dataBuilder = null,
        bothBuilder = null,
        target = DuetTarget.ui;

  /// Listens to both business data [Duet.dataNotifier] and UI behavior state [Duet.behaviorNotifier].
  const DuetBuilder.both({
    super.key,
    this.viewModel,
    required Widget Function(BuildContext context, D data, B ui) builder,
  })  : bothBuilder = builder,
        dataBuilder = null,
        uiBuilder = null,
        target = DuetTarget.both;

  @override
  State<DuetBuilder<D, B>> createState() => _DuetBuilderState<D, B>();
}

class _DuetBuilderState<D, B> extends State<DuetBuilder<D, B>> {
  Duet<D, B>? _effectiveVM;
  List<ValueNotifier<dynamic>> _notifiers = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newVM = DuetScope.find<D, B>(context, explicitVM: widget.viewModel);

    if (_effectiveVM != newVM) {
      if (_effectiveVM != null) {
        for (final notifier in _notifiers) {
          notifier.removeListener(_rebuild);
        }
        _effectiveVM!.release(() {
          unregisterVM(_effectiveVM!);
        });
      }

      _effectiveVM = newVM;
      _effectiveVM!.retain();
      _notifiers = _getNotifiers();
      for (final notifier in _notifiers) {
        notifier.addListener(_rebuild);
      }
    }
  }

  List<ValueNotifier<dynamic>> _getNotifiers() {
    switch (widget.target) {
      case DuetTarget.data:
        return [_effectiveVM!.dataNotifier];
      case DuetTarget.ui:
        return [_effectiveVM!.behaviorNotifier];
      case DuetTarget.both:
        return [
          _effectiveVM!.dataNotifier,
          _effectiveVM!.behaviorNotifier,
        ];
    }
  }

  void _rebuild() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    for (final notifier in _notifiers) {
      notifier.removeListener(_rebuild);
    }
    if (_effectiveVM != null) {
      _effectiveVM!.release(() {
        unregisterVM(_effectiveVM!);
      });
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.target) {
      case DuetTarget.data:
        return widget.dataBuilder!(context, _effectiveVM!.dataState);
      case DuetTarget.ui:
        return widget.uiBuilder!(context, _effectiveVM!.behaviorState);
      case DuetTarget.both:
        return widget.bothBuilder!(
          context,
          _effectiveVM!.dataState,
          _effectiveVM!.behaviorState,
        );
    }
  }
}

/// Backward compatibility alias for [DuetBuilder].
typedef ReactiveBuilder<D, B> = DuetBuilder<D, B>;
