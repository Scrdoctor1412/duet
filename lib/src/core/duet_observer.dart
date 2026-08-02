import 'package:flutter/foundation.dart';
import 'package:duet/src/core/duet_core.dart';

abstract class DuetObserver {
  void onStateEmitted(Duet vm, {Object? data, Object? ui});
  void onEventEmitted(Duet vm, Object event);
  void onEffectEmitted(Duet vm, Object event) => onEventEmitted(vm, event);
}

typedef ReactiveStateObserver = DuetObserver;

class DuetState {
  static DuetObserver? observer;
}

typedef ReactiveState = DuetState;

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

typedef DefaultReactiveLogger = DuetLogger;
