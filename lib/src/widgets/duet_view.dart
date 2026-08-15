import 'package:flutter/widgets.dart';
import 'package:duet/src/core/duet_core.dart';
import 'package:duet/src/core/duet_provider.dart';
import 'package:duet/src/widgets/duet_scope.dart';

/// Mixin attached to a [StatefulWidget]'s [State] to manage lifecycle and automatically bind a Duet ViewModel [VM].
mixin DuetStateMixin<W extends StatefulWidget, VM extends Duet> on State<W> {
  late final VM _duet;

  /// Returns the Duet ViewModel instance bound to this widget.
  VM get duet => _duet;

  /// Compatibility aliases for [duet].
  VM get vm => _duet;
  VM get viewModel => _duet;

  /// Binds and provides the Duet instance for this screen component (must override [bindDuet] or [bindViewModel]).
  VM bindDuet() => bindViewModel();

  /// Compatibility alias for [bindDuet].
  VM bindViewModel() {
    throw UnimplementedError(
        'You must override bindDuet() or bindViewModel() in your screen widget.');
  }

  /// Wraps the child widget subtree in a [DuetScope].
  Widget buildScope(Widget child) {
    return DuetScope<VM>(
      viewModel: _duet,
      child: child,
    );
  }

  @override
  void initState() {
    super.initState();
    _duet = resolveBoundDuet(bindDuet());
    _duet.retain();
  }

  @override
  void dispose() {
    releaseDuet(_duet);
    super.dispose();
  }
}

/// Backward compatibility alias for [DuetStateMixin].
typedef ReactiveStateMixin<W extends StatefulWidget, VM extends Duet>
    = DuetStateMixin<W, VM>;

/// {@template duet_view}
/// Base class for Screen/View components that automatically binds and scopes a [Duet] ViewModel.
/// {@endtemplate}
abstract class DuetView<VM extends Duet> extends StatefulWidget {
  const DuetView({super.key});

  /// Binds and provides the Duet instance for this screen component.
  VM bindDuet() => bindViewModel();

  /// Compatibility alias for [bindDuet].
  VM bindViewModel() {
    throw UnimplementedError(
        'You must override bindDuet() or bindViewModel() in your screen widget.');
  }

  /// Called once after the Duet instance has been bound and retained.
  ///
  /// Use this hook for initial loading instead of starting asynchronous work in
  /// the Duet constructor.
  void onDuetReady(VM duet) {}

  /// UI build method receiving both [BuildContext] and the bound [duet] instance.
  Widget build(BuildContext context, VM duet);

  @override
  State<DuetView<VM>> createState() => _DuetViewState<VM>();
}

class _DuetViewState<VM extends Duet> extends State<DuetView<VM>>
    with DuetStateMixin<DuetView<VM>, VM> {
  @override
  VM bindDuet() => widget.bindDuet();

  @override
  void initState() {
    super.initState();
    widget.onDuetReady(duet);
  }

  @override
  Widget build(BuildContext context) {
    return DuetScope<VM>(
      viewModel: duet,
      child: widget.build(context, duet),
    );
  }
}

/// Backward compatibility alias for [DuetView].
typedef ReactiveView<VM extends Duet> = DuetView<VM>;
