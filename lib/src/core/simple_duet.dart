import 'package:flutter/foundation.dart';
import 'package:duet/src/core/duet_core.dart';
import 'package:duet/src/core/ui_state.dart';

/// A progressive Duet API for screens that only need the standard
/// idle/loading/success/error behavior lifecycle.
///
/// Use [Duet] directly when a feature has domain-specific UI behaviors such as
/// OTP verification, multi-step approval, or payment processing phases.
abstract class SimpleDuet<D> extends Duet<D, UiState> {
  int _latestOperation = 0;

  SimpleDuet({
    required super.initialData,
    UiState initialStatus = const UiIdle(),
  }) : super(initialBehavior: initialStatus);

  /// Current standard UI status.
  UiState get status => ui;

  /// Whether the current task is loading.
  bool get isLoading => status is UiLoading;

  @protected
  void setIdle() => emitUi(const UiIdle());

  @protected
  void setLoading([String? label]) => emitUi(UiLoading(label));

  @protected
  void setSuccess([String? message]) => emitUi(UiSuccess(message));

  @protected
  void setFailure(Object error, [StackTrace? stackTrace]) {
    emitUi(
      UiError(
        error.toString(),
        error: error,
        stackTrace: stackTrace,
      ),
    );
  }

  /// Runs an asynchronous task with the standard status lifecycle.
  ///
  /// When [reduce] is provided, the resulting data and success status are
  /// emitted in the same Duet transaction. Existing data is preserved while
  /// loading and on failure.
  @protected
  Future<R?> runTask<R>({
    required Future<R> Function() task,
    D Function(D current, R result)? reduce,
    UiState Function(R result)? successState,
    UiState Function(Object error, StackTrace stackTrace)? failureState,
    bool emitLoading = true,
    bool rethrowError = false,
  }) async {
    if (emitLoading) {
      emit(ui: const UiLoading());
    }

    try {
      final result = await task();
      final nextStatus = successState?.call(result) ?? const UiSuccess();

      if (reduce != null) {
        emitValues(
          data: reduce(data, result),
          ui: nextStatus,
        );
      } else {
        emit(ui: nextStatus);
      }
      return result;
    } catch (error, stackTrace) {
      final nextStatus = failureState?.call(error, stackTrace) ??
          UiError(
            error.toString(),
            error: error,
            stackTrace: stackTrace,
          );
      emit(ui: nextStatus);

      if (rethrowError) {
        Error.throwWithStackTrace(error, stackTrace);
      }
      return null;
    }
  }

  /// Runs an asynchronous task where only the latest invocation may commit
  /// data, success, or failure state.
  ///
  /// Older tasks are not physically cancelled, but their completion is ignored
  /// after a newer invocation starts. Their successful result is still returned
  /// to the original caller. This policy is suitable for search, filtering,
  /// refresh, and route-parameter changes.
  @protected
  Future<R?> runLatest<R>({
    required Future<R> Function() task,
    D Function(D current, R result)? reduce,
    UiState Function(R result)? successState,
    UiState Function(Object error, StackTrace stackTrace)? failureState,
    bool emitLoading = true,
    bool rethrowError = false,
  }) async {
    final operation = ++_latestOperation;

    if (emitLoading) {
      emitUi(const UiLoading());
    }

    try {
      final result = await task();
      if (operation != _latestOperation || isDisposed) return result;

      final nextStatus = successState?.call(result) ?? const UiSuccess();
      if (reduce != null) {
        emitValues(data: reduce(data, result), ui: nextStatus);
      } else {
        emitUi(nextStatus);
      }
      return result;
    } catch (error, stackTrace) {
      final isCurrent = operation == _latestOperation && !isDisposed;
      if (isCurrent) {
        emitUi(
          failureState?.call(error, stackTrace) ??
              UiError(
                error.toString(),
                error: error,
                stackTrace: stackTrace,
              ),
        );
      }

      if (rethrowError) {
        Error.throwWithStackTrace(error, stackTrace);
      }
      return null;
    }
  }

  /// Latest-wins variant whose successful result replaces the current data.
  @protected
  Future<D?> runLatestData(
    Future<D> Function() task, {
    UiState Function(D result)? successState,
    UiState Function(Object error, StackTrace stackTrace)? failureState,
    bool emitLoading = true,
    bool rethrowError = false,
  }) {
    return runLatest<D>(
      task: task,
      reduce: (_, result) => result,
      successState: successState,
      failureState: failureState,
      emitLoading: emitLoading,
      rethrowError: rethrowError,
    );
  }

  /// Prevents the currently latest task from committing state when it finishes.
  @protected
  void cancelLatest() {
    _latestOperation++;
  }

  /// Runs a task whose result replaces the current data value.
  @protected
  Future<D?> runData(
    Future<D> Function() task, {
    UiState Function(D result)? successState,
    UiState Function(Object error, StackTrace stackTrace)? failureState,
    bool emitLoading = true,
    bool rethrowError = false,
  }) {
    return runTask<D>(
      task: task,
      reduce: (_, result) => result,
      successState: successState,
      failureState: failureState,
      emitLoading: emitLoading,
      rethrowError: rethrowError,
    );
  }

  @override
  void invalidate() {
    cancelLatest();
    super.invalidate();
  }
}
