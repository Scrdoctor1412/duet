import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:duet/src/core/duet_core.dart';
import 'package:duet/src/core/duet_provider.dart';
import 'package:duet/src/widgets/duet_scope.dart';

/// {@template duet_listener}
/// Widget tr�?giúp bọc và lắng nghe các s�?kiện 1 lần (Side-Effect Events như Toast, Navigation, Dialog) phát ra t�?[Duet].
/// {@endtemplate}
class DuetListener<VM extends Duet, E> extends StatefulWidget {
  /// ViewModel liên kết tùy chọn (Nếu null s�?t�?tìm kiếm t�?BuildContext).
  final VM? viewModel;

  /// Callback x�?lý s�?kiện khi có [E] phát ra t�?ViewModel.
  final void Function(BuildContext context, E event) onEvent;

  /// B�?lọc điều kiện tùy chọn quyết định s�?kiện [E] có được kích hoạt callback [onEvent] hay không.
  final bool Function(E event)? listenWhen;

  /// Cây Widget con phía dưới.
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

    if (_effectiveVM != newVM) {
      if (_effectiveVM != null) {
        _subscription?.cancel();
        _effectiveVM!.release(() {
          unregisterVM(_effectiveVM!);
        });
      }

      _effectiveVM = newVM;
      _effectiveVM!.retain();
      _subscribe();
    }
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

  @override
  void dispose() {
    _subscription?.cancel();
    if (_effectiveVM != null) {
      _effectiveVM!.release(() {
        unregisterVM(_effectiveVM!);
      });
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Alias cho ReactiveListener
typedef ReactiveListener<VM extends Duet, E> = DuetListener<VM, E>;

/// {@template duet_behavior_listener}
/// Widget tr�?giúp bọc và lắng nghe trực tiếp s�?thay đổi trạng thái [behaviorNotifier] t�?[Duet].
/// {@endtemplate}
class DuetBehaviorListener<D, B> extends StatefulWidget {
  /// ViewModel liên kết tùy chọn (Nếu null s�?t�?tìm kiếm t�?BuildContext).
  final Duet<D, B>? viewModel;

  /// Callback x�?lý khi [behaviorState] thay đổi.
  final void Function(BuildContext context, B behavior) listener;

  /// B�?lọc điều kiện tùy chọn so sánh [previous] và [current] behavior.
  final bool Function(B previous, B current)? listenWhen;

  /// Cây Widget con phía dưới.
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

    if (_effectiveVM != newVM) {
      if (_effectiveVM != null) {
        _effectiveVM!.behaviorNotifier.removeListener(_onBehaviorChanged);
        _effectiveVM!.release(() {
          unregisterVM(_effectiveVM!);
        });
      }

      _effectiveVM = newVM;
      _effectiveVM!.retain();
      _previousBehavior = _effectiveVM!.behaviorState;
      _effectiveVM!.behaviorNotifier.addListener(_onBehaviorChanged);
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
    if (_effectiveVM != null) {
      _effectiveVM!.behaviorNotifier.removeListener(_onBehaviorChanged);
      _effectiveVM!.release(() {
        unregisterVM(_effectiveVM!);
      });
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Alias cho ReactiveBehaviorListener
typedef ReactiveBehaviorListener<D, B> = DuetBehaviorListener<D, B>;
