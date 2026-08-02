import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import 'package:duet/src/core/duet_observer.dart';

/// Customized [ValueNotifier] that supports transaction batching.
///
/// Prevents multiple intermediate notifications when updating multiple state fields simultaneously.
class DuetValueNotifier<T> extends ValueNotifier<T> {
  bool _isBatching = false;
  bool _hasPendingNotify = false;

  DuetValueNotifier(super.value);

  /// Begins a notification batch transaction.
  void beginBatch() {
    _isBatching = true;
  }

  /// Ends the batch transaction and triggers a single notification if any update occurred.
  void endBatch() {
    _isBatching = false;
    if (_hasPendingNotify) {
      _hasPendingNotify = false;
      notifyListeners();
    }
  }

  @override
  void notifyListeners() {
    if (_isBatching) {
      _hasPendingNotify = true;
    } else {
      super.notifyListeners();
    }
  }

  /// Forces notification emission to all listeners even if [value] reference has not changed.
  void forceNotify() {
    notifyListeners();
  }
}

/// Backward compatibility alias for [DuetValueNotifier].
typedef ReactiveValueNotifier<T> = DuetValueNotifier<T>;

/// {@template duet}
/// Base abstract class managing state for all ViewModels / Controllers under the Duet architecture.
///
/// Manages two independent [ValueNotifier] instances:
/// - [dataNotifier]: Holds domain business data of type [D].
/// - [behaviorNotifier]: Holds transient UI behavior state of type [B].
///
/// Implements reference counting (`_refCount`) to automatically dispose memory ([autoDispose])
/// when no active widgets are listening.
/// {@endtemplate}
abstract class Duet<D, B> {
  /// Initial business data value of type [D].
  final D initialData;

  /// Initial UI behavior state value of type [B].
  final B initialBehavior;

  /// Manages and notifies updates to domain business data [D].
  late final DuetValueNotifier<D> dataNotifier;

  /// Manages and notifies updates to UI behavior state [B].
  late final DuetValueNotifier<B> behaviorNotifier;

  /// Internal reference counter tracking active listener widgets.
  int _refCount = 0;

  /// Flag marking whether this instance has been disposed.
  bool _isDisposed = false;

  /// Returns `true` if this instance has been disposed from memory.
  bool get isDisposed => _isDisposed;

  /// Number of active widgets attached to this instance (visible for testing).
  @visibleForTesting
  int get refCount => _refCount;

  /// Controls whether this instance should automatically dispose when [refCount] reaches zero.
  bool get autoDispose => true;

  /// Indicates whether this instance is registered as a global singleton.
  bool get isGlobal => false;

  /// Creates a [Duet] instance with initial [initialData] and [initialBehavior].
  Duet({
    required this.initialData,
    required this.initialBehavior,
  }) {
    dataNotifier = DuetValueNotifier<D>(initialData);
    behaviorNotifier = DuetValueNotifier<B>(initialBehavior);
  }

  /// Returns current synchronous business data state value.
  D get dataState => dataNotifier.value;

  /// Returns current synchronous UI behavior state value.
  B get behaviorState => behaviorNotifier.value;

  /// Concise getter alias for [dataState].
  D get data => dataNotifier.value;

  /// Concise getter alias for [behaviorState].
  B get ui => behaviorNotifier.value;

  /// Executes a group of state mutations ([action]) inside a single transaction batch.
  @protected
  void batch(void Function() action) {
    if (_isDisposed) return;
    dataNotifier.beginBatch();
    behaviorNotifier.beginBatch();
    try {
      action();
    } finally {
      dataNotifier.endBatch();
      behaviorNotifier.endBatch();
    }
  }

  /// Emits new domain business data [newData] to [dataNotifier].
  @protected
  void emitData(D newData) {
    if (_isDisposed) return;
    dataNotifier.value = newData;
  }

  /// Safely updates business data [D] using a transformation function [transform].
  @protected
  void updateData(D Function(D current) transform) {
    if (_isDisposed) return;
    final newData = transform(dataState);
    assert(
      !identical(newData, dataState),
      'WARNING: updateData() returned the identical object instance! '
      'Did you mutate properties directly instead of creating a new copy via copyWith()? '
      'If direct mutation was intended, call notifyDataChanged() instead.',
    );
    emitData(newData);
  }

  /// Forces notification emission for business data [D] to [dataNotifier].
  @protected
  void notifyDataChanged() {
    if (_isDisposed) return;
    dataNotifier.forceNotify();
  }

  /// Emits new UI behavior state [newBehavior] to [behaviorNotifier].
  @protected
  void emitBehavior(B newBehavior) {
    if (_isDisposed) return;
    behaviorNotifier.value = newBehavior;
  }

  /// Concise helper alias to emit UI behavior state [newUi].
  @protected
  void emitUi(B newUi) => emitBehavior(newUi);

  /// Simultaneously updates business data [data] and UI state [ui] within a single transaction.
  @protected
  void emitState({D? data, B? ui}) {
    if (_isDisposed) return;
    if (data == null && ui == null) return;

    if (kDebugMode && DuetState.observer != null) {
      DuetState.observer!.onStateEmitted(this, data: data, ui: ui);
    }

    batch(() {
      if (data != null) emitData(data);
      if (ui != null) emitBehavior(ui);
    });
  }

  /// Most concise helper alias for [emitState].
  @protected
  void emit({D? data, B? ui}) => emitState(data: data, ui: ui);

  /// Internal controller for one-shot side-effect events (Toasts, Navigation, Dialogs).
  final _eventController = StreamController<Object>.broadcast();

  /// Public broadcast stream for [DuetListener] instances to receive one-shot events.
  Stream<Object> get eventStream => _eventController.stream;

  /// Emits a single one-shot side-effect event [event] (Toast, Navigation, Dialog).
  @protected
  void emitEvent(Object event) {
    if (_isDisposed) return;

    if (kDebugMode && DuetState.observer != null) {
      DuetState.observer!.onEffectEmitted(this, event);
    }

    _eventController.add(event);
  }

  /// Concise helper alias for [emitEvent].
  @protected
  void emitEffect(Object event) => emitEvent(event);

  /// Resets state back to initial [initialData] and [initialBehavior].
  @mustCallSuper
  void invalidate() {
    if (_isDisposed) return;
    emitData(initialData);
    emitBehavior(initialBehavior);
  }

  /// Increments reference count when a widget attaches to this instance.
  @internal
  void retain() {
    if (_isDisposed) return;
    _refCount++;
  }

  /// Decrements reference count and disposes if [_refCount] reaches zero and [autoDispose] is true.
  @internal
  void release(void Function() onDisposeRegistry) {
    _refCount--;
    if (_refCount <= 0 && autoDispose) {
      dispose();
      onDisposeRegistry();
    }
  }

  /// Disposes internal [ValueNotifier] and [StreamController] resources.
  @mustCallSuper
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    dataNotifier.dispose();
    behaviorNotifier.dispose();
    _eventController.close();
  }
}

// ============================================================================
// TYPEDEF ALIASES
// ============================================================================

/// Combined brand alias for Duet ViewModel.
typedef DuetViewModel<D, B> = Duet<D, B>;

/// Controller style alias for Duet.
typedef DuetController<D, B> = Duet<D, B>;

/// Classic MVVM alias for Duet.
typedef ViewModel<D, B> = Duet<D, B>;

/// Backward compatibility alias for BaseViewModel.
typedef BaseViewModel<D, B> = Duet<D, B>;
