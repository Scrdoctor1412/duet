import 'package:flutter/foundation.dart';

/// Standard UI behavior states for small and medium Duet features.
///
/// Larger features can still define their own behavior hierarchy and use
/// `Duet<D, B>` directly.
@immutable
abstract class UiState {
  const UiState();

  const factory UiState.idle() = UiIdle;
  const factory UiState.loading([String? label]) = UiLoading;
  const factory UiState.success([String? message]) = UiSuccess;
  const factory UiState.error(String message) = UiError;
}

/// Default idle UI state.
final class UiIdle extends UiState {
  const UiIdle();
}

/// Default loading UI state.
final class UiLoading extends UiState {
  final String? label;

  const UiLoading([this.label]);
}

/// Default success UI state.
final class UiSuccess extends UiState {
  final String? message;

  const UiSuccess([this.message]);
}

/// Default error UI state with a message payload.
final class UiError extends UiState {
  final String message;
  final Object? error;
  final StackTrace? stackTrace;

  const UiError(this.message, {this.error, this.stackTrace});
}

/// Preferred name for the built-in behavior type used by [SimpleDuet].
typedef DuetStatus = UiState;

/// Backward compatibility alias for [UiState].
typedef ReactiveStateData = UiState;
