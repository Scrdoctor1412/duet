import 'package:flutter/widgets.dart';
import 'package:duet/src/core/duet_core.dart';
import 'package:duet/src/core/duet_provider.dart';
import 'package:duet/src/widgets/duet_scope.dart';

/// A reactive widget that extracts a specific property [T] from a [Duet] instance
/// and rebuilds ONLY when the extracted property changes.
class DuetSelector<VM extends Duet, T> extends StatefulWidget {
  /// Explicitly provided ViewModel instance (if omitted, looked up via [BuildContext]).
  final VM? viewModel;

  /// Selector function extracting property [T] from ViewModel [VM].
  final T Function(VM vm) selector;

  /// Builder callback producing the widget tree dependent on extracted value [T].
  final Widget Function(BuildContext context, T value) builder;

  /// Optional custom comparator determining whether the widget should rebuild.
  final bool Function(T previous, T current)? shouldRebuild;

  /// Internal flag indicating whether selector listens to `dataNotifier` (false) or `behaviorNotifier` (true).
  final bool _isUiSelector;

  /// Listens to updates on a specific field of domain business data (`dataNotifier`).
  const DuetSelector({
    super.key,
    this.viewModel,
    required this.selector,
    required this.builder,
    this.shouldRebuild,
  }) : _isUiSelector = false;

  /// Listens to updates on a specific field of UI behavior state (`behaviorNotifier`).
  const DuetSelector.ui({
    super.key,
    this.viewModel,
    required this.selector,
    required this.builder,
    this.shouldRebuild,
  }) : _isUiSelector = true;

  @override
  State<DuetSelector<VM, T>> createState() => _DuetSelectorState<VM, T>();
}

class _DuetSelectorState<VM extends Duet, T>
    extends State<DuetSelector<VM, T>> {
  VM? _effectiveVM;
  ValueNotifier<dynamic>? _notifier;
  late T _selectedValue;

  T _computeSelectedValue() {
    return widget.selector(_effectiveVM!);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newVM = widget.viewModel ?? DuetScope.of<VM>(context);

    if (!identical(_effectiveVM, newVM)) {
      _detach();
      _attach(newVM);
    }
  }

  @override
  void didUpdateWidget(covariant DuetSelector<VM, T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.viewModel, widget.viewModel)) {
      _detach();
      _attach(widget.viewModel ?? DuetScope.of<VM>(context));
      return;
    }

    if (oldWidget._isUiSelector != widget._isUiSelector) {
      _notifier?.removeListener(_onStateChanged);
      _notifier = _selectNotifier();
      _notifier!.addListener(_onStateChanged);
    }
    _selectedValue = _computeSelectedValue();
  }

  void _attach(VM viewModel) {
    _effectiveVM = viewModel;
    _effectiveVM!.retain();
    _notifier = _selectNotifier();
    _selectedValue = _computeSelectedValue();
    _notifier!.addListener(_onStateChanged);
  }

  ValueNotifier<dynamic> _selectNotifier() {
    return widget._isUiSelector
        ? _effectiveVM!.behaviorNotifier
        : _effectiveVM!.dataNotifier;
  }

  void _detach() {
    _notifier?.removeListener(_onStateChanged);
    _notifier = null;
    if (_effectiveVM != null) {
      releaseDuet(_effectiveVM!);
      _effectiveVM = null;
    }
  }

  void _onStateChanged() {
    final newSelectedValue = _computeSelectedValue();
    final needRebuild = widget.shouldRebuild != null
        ? widget.shouldRebuild!(_selectedValue, newSelectedValue)
        : _selectedValue != newSelectedValue;

    if (needRebuild) {
      _selectedValue = newSelectedValue;
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    _detach();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _selectedValue);
  }
}

/// Backward compatibility alias for [DuetSelector].
typedef ReactiveSelector<VM extends Duet, T> = DuetSelector<VM, T>;
