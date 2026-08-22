import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:duet/src/core/duet_core.dart';
import 'package:duet/src/core/duet_provider.dart';
import 'package:duet/src/widgets/duet_scope.dart';

/// {@template duet_listener}
/// A helper widget that listens for one-shot side-effect events (Toasts, Navigation, Dialogs) emitted from a [Duet].
/// {@endtemplate}
class DuetListener<VM extends Duet, E> extends StatefulWidget {
  /// Explicitly provided ViewModel instance (if omitted, looked up via [BuildContext]).
  final VM? viewModel;

  /// Callback executed when a side-effect event [E] is emitted by the ViewModel.
  final void Function(BuildContext context, E event) onEvent;

  /// Optional condition filtering whether [onEvent] should be triggered for event [E].
  final bool Function(E event)? listenWhen;

  /// Child widget subtree.
  final Widget child;

  /// {@macro duet_listener}
  const DuetListener({
    super.key,
    this.viewModel,
    required this.onEvent,
    this.listenWhen,
    required this.child,
  });

  @override
  State<DuetListener<VM, E>> createState() => _DuetListenerState<VM, E>();
}

class _DuetListenerState<VM extends Duet, E>
    extends State<DuetListener<VM, E>> {
  VM? _effectiveVM;
  StreamSubscription<Object>? _subscription;

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
  void didUpdateWidget(covariant DuetListener<VM, E> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.viewModel, widget.viewModel)) {
      _detach();
      _attach(widget.viewModel ?? DuetScope.of<VM>(context));
    }
  }

  void _attach(VM viewModel) {
    _effectiveVM = viewModel;
    _effectiveVM!.retain();
    _subscribe();
  }

  void _subscribe() {
    _subscription = _effectiveVM!.eventStream.listen((event) {
      if (event is E) {
        final typedEvent = event as E;
        final shouldListen = widget.listenWhen?.call(typedEvent) ?? true;
        if (shouldListen && mounted) {
          widget.onEvent(context, typedEvent);
        }
      }
    });
  }

  void _detach() {
    _subscription?.cancel();
    _subscription = null;
    if (_effectiveVM != null) {
      releaseDuet(_effectiveVM!);
      _effectiveVM = null;
    }
  }

  @override
  void dispose() {
    _detach();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Backward compatibility alias for [DuetListener].
typedef ReactiveListener<VM extends Duet, E> = DuetListener<VM, E>;

/// {@template duet_behavior_listener}
/// A helper widget that directly listens to UI behavior state updates [Duet.behaviorNotifier] from a [Duet].
/// {@endtemplate}
class DuetBehaviorListener<D, B> extends StatefulWidget {
  /// Explicitly provided ViewModel instance (if omitted, looked up via [BuildContext]).
  final Duet<D, B>? viewModel;

  /// Callback executed when [behaviorState] changes.
  final void Function(BuildContext context, B behavior) listener;

  /// Optional condition comparing [previous] and [current] UI behavior states.
  final bool Function(B previous, B current)? listenWhen;

  /// Child widget subtree.
  final Widget child;

  /// {@macro duet_behavior_listener}
  const DuetBehaviorListener({
    super.key,
    this.viewModel,
    required this.listener,
    this.listenWhen,
    required this.child,
  });

  @override
  State<DuetBehaviorListener<D, B>> createState() =>
      _DuetBehaviorListenerState<D, B>();
}

class _DuetBehaviorListenerState<D, B>
    extends State<DuetBehaviorListener<D, B>> {
  Duet<D, B>? _effectiveVM;
  late B _previousBehavior;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newVM = DuetScope.find<D, B>(context, explicitVM: widget.viewModel);

    if (!identical(_effectiveVM, newVM)) {
      _detach();
      _attach(newVM);
    }
  }

  @override
  void didUpdateWidget(covariant DuetBehaviorListener<D, B> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.viewModel, widget.viewModel)) {
      _detach();
      _attach(DuetScope.find<D, B>(context, explicitVM: widget.viewModel));
    }
  }

  void _attach(Duet<D, B> viewModel) {
    _effectiveVM = viewModel;
    _effectiveVM!.retain();
    _previousBehavior = _effectiveVM!.behaviorState;
    _effectiveVM!.behaviorNotifier.addListener(_onBehaviorChanged);
  }

  void _detach() {
    if (_effectiveVM != null) {
      _effectiveVM!.behaviorNotifier.removeListener(_onBehaviorChanged);
      releaseDuet(_effectiveVM!);
      _effectiveVM = null;
    }
  }

  void _onBehaviorChanged() {
    final currentBehavior = _effectiveVM!.behaviorState;
    final shouldListen =
        widget.listenWhen?.call(_previousBehavior, currentBehavior) ?? true;
    if (shouldListen && mounted) {
      widget.listener(context, currentBehavior);
    }
    _previousBehavior = currentBehavior;
  }

  @override
  void dispose() {
    _detach();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Backward compatibility alias for [DuetBehaviorListener].
typedef ReactiveBehaviorListener<D, B> = DuetBehaviorListener<D, B>;
