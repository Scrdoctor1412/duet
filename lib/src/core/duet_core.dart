import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:duet/src/core/duet_observer.dart';

/// Customized [ValueNotifier] that supports transaction batching.
///
/// Prevents multiple intermediate notifications when updating multiple state fields simultaneously.
class DuetValueNotifier<T> extends ValueNotifier<T> {
  int _batchDepth = 0;
  bool _hasPendingNotify = false;

  DuetValueNotifier(super.value);

  /// Begins a notification batch transaction.
  void beginBatch() {
    _batchDepth++;
  }

  /// Ends the batch transaction and triggers a single notification if any update occurred.
  void endBatch() {
    assert(_batchDepth > 0, 'endBatch() called without beginBatch().');
    if (_batchDepth == 0) return;

    _batchDepth--;
    if (_batchDepth == 0 && _hasPendingNotify) {
      _hasPendingNotify = false;
      notifyListeners();
    }
  }

  @override
  void notifyListeners() {
    if (_batchDepth > 0) {
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

/// An explicitly present value used by [Duet.emitPatch].
///
/// The wrapper distinguishes an omitted channel from a channel being set to
/// `null` when the Duet uses nullable data or UI types.
@immutable
final class DuetChange<T> {
  final T value;

  const DuetChange(this.value);
}

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

  /// Whether an owner has requested disposal after remaining consumers detach.
  bool _disposeWhenUnreferenced = false;

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
    _reportState(data: newData);
    _setData(newData);
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
    _reportState(data: dataState);
    dataNotifier.forceNotify();
  }

  /// Emits new UI behavior state [newBehavior] to [behaviorNotifier].
  @protected
  void emitBehavior(B newBehavior) {
    if (_isDisposed) return;
    _reportState(ui: newBehavior);
    _setBehavior(newBehavior);
  }

  /// Concise helper alias to emit UI behavior state [newUi].
  @protected
  void emitUi(B newUi) => emitBehavior(newUi);

  /// Simultaneously updates business data [data] and UI state [ui] within a single transaction.
  @protected
  void emitState({D? data, B? ui}) {
    if (_isDisposed) return;
    if (data == null && ui == null) return;

    _reportState(data: data, ui: ui);

    batch(() {
      if (data != null) _setData(data);
      if (ui != null) _setBehavior(ui);
    });
  }

  /// Most concise helper alias for [emitState].
  @protected
  void emit({D? data, B? ui}) => emitState(data: data, ui: ui);

  /// Atomically updates only the explicitly supplied channels.
  ///
  /// Unlike [emit], [DuetChange] can carry `null` as a real value:
  ///
  /// ```dart
  /// emitPatch(data: const DuetChange(null));
  /// ```
  @protected
  void emitPatch({DuetChange<D>? data, DuetChange<B>? ui}) {
    if (_isDisposed || (data == null && ui == null)) return;

    _reportState(data: data?.value, ui: ui?.value);
    batch(() {
      if (data != null) _setData(data.value);
      if (ui != null) _setBehavior(ui.value);
    });
  }

  /// Emits both values atomically without treating `null` as an omitted value.
  ///
  /// This is useful for nullable generic state and for framework helpers such
  /// as `SimpleDuet.runTask`.
  @protected
  void emitValues({required D data, required B ui}) {
    if (_isDisposed) return;
    _reportState(data: data, ui: ui);
    batch(() {
      _setData(data);
      _setBehavior(ui);
    });
  }

  void _setData(D value) => dataNotifier.value = value;

  void _setBehavior(B value) => behaviorNotifier.value = value;

  void _reportState({Object? data, Object? ui}) {
    if (kDebugMode && DuetState.observer != null) {
      DuetState.observer!.onStateEmitted(this, data: data, ui: ui);
    }
  }

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
    emitValues(data: initialData, ui: initialBehavior);
  }

  /// Increments reference count when a widget attaches to this instance.
  @internal
  void retain() {
    if (_isDisposed) return;
    _refCount++;
  }

  /// Decrements reference count and disposes if [_refCount] reaches zero and [autoDispose] is true.
  @internal
  void release(
    void Function() onDisposeRegistry, {
    bool disposeWhenUnreferenced = false,
  }) {
    if (_isDisposed) return;
    if (disposeWhenUnreferenced) {
      _disposeWhenUnreferenced = true;
    }
    assert(_refCount > 0, 'release() called without a matching retain().');
    if (_refCount == 0) return;

    _refCount--;
    if (_refCount <= 0 && (autoDispose || _disposeWhenUnreferenced)) {
      dispose();
      onDisposeRegistry();
    }
  }

  /// Disposes internal [ValueNotifier] and [StreamController] resources.
  @mustCallSuper
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    _refCount = 0;
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
