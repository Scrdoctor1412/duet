import 'package:flutter/foundation.dart';
import 'package:duet/src/core/duet_core.dart';

/// Global observer interface to intercept and log state mutations in debug mode.
abstract class DuetObserver {
  /// Triggered when a ViewModel emits business data or UI state.
  void onStateEmitted(Duet vm, {Object? data, Object? ui});

  /// Triggered when a ViewModel emits a one-shot side-effect event (Toast, Navigation, Dialog).
  void onEventEmitted(Duet vm, Object event);

  /// Backward compatibility alias for [onEventEmitted].
  void onEffectEmitted(Duet vm, Object event) => onEventEmitted(vm, event);
}

/// Backward compatibility alias for [DuetObserver].
typedef ReactiveStateObserver = DuetObserver;

/// Global observer configuration for Duet.
class DuetState {
  /// Registers the global observer instance.
  static DuetObserver? observer;
}

/// Backward compatibility alias for [DuetState].
typedef ReactiveState = DuetState;

/// Default logger implementation printing state transitions to console in debug mode.
class DuetLogger extends DuetObserver {
  @override
  void onStateEmitted(Duet vm, {Object? data, Object? ui}) {
    final buffer = StringBuffer();
    buffer.writeln('[${vm.runtimeType}] StateEmitted');
    if (data != null) {
      buffer.writeln('  Data: $data');
    }
    if (ui != null) {
      buffer.writeln('  UI: $ui');
    }
    debugPrint(buffer.toString().trimRight());
  }

  @override
  void onEventEmitted(Duet vm, Object event) {
    debugPrint('[${vm.runtimeType}] EventEmitted: $event');
  }

  @override
  void onEffectEmitted(Duet vm, Object event) => onEventEmitted(vm, event);
}

/// Backward compatibility alias for [DuetLogger].
typedef DefaultReactiveLogger = DuetLogger;
