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
  })  : _isUiSelector = false;

  /// Listens to updates on a specific field of UI behavior state (`behaviorNotifier`).
  const DuetSelector.ui({
    super.key,
    this.viewModel,
    required this.selector,
    required this.builder,
    this.shouldRebuild,
  })  : _isUiSelector = true;

  @override
  State<DuetSelector<VM, T>> createState() =>
      _DuetSelectorState<VM, T>();
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

    if (_effectiveVM != newVM) {
      if (_effectiveVM != null && _notifier != null) {
        _notifier!.removeListener(_onStateChanged);
        _effectiveVM!.release(() {
          if (_effectiveVM!.isGlobal) {
            unregisterVM(_effectiveVM!);
          }
        });
      }

      _effectiveVM = newVM;
      _effectiveVM!.retain();
      _notifier = widget._isUiSelector
          ? _effectiveVM!.behaviorNotifier
          : _effectiveVM!.dataNotifier;
      _selectedValue = _computeSelectedValue();
      _notifier!.addListener(_onStateChanged);
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
    if (_notifier != null) {
      _notifier!.removeListener(_onStateChanged);
    }
    if (_effectiveVM != null) {
      _effectiveVM!.release(() {
        if (_effectiveVM!.isGlobal) {
          unregisterVM(_effectiveVM!);
        }
      });
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _selectedValue);
  }
}

/// Backward compatibility alias for [DuetSelector].
typedef ReactiveSelector<VM extends Duet, T> = DuetSelector<VM, T>;
