import 'package:flutter/foundation.dart';

/// Base abstract class for defining UI behavior states.
///
/// Designed to be subclassed or implemented using Dart 3 sealed class hierarchies
/// for exhaustive pattern matching (e.g. Loading, Success, Error).
@immutable
abstract class UiState {
  const UiState();
}

/// Default idle UI state.
class UiIdle extends UiState {
  const UiIdle();
}

/// Default loading UI state.
class UiLoading extends UiState {
  const UiLoading();
}

/// Default success UI state.
class UiSuccess extends UiState {
  const UiSuccess();
}

/// Default error UI state with a message payload.
class UiError extends UiState {
  final String message;
  const UiError(this.message);
}

/// Backward compatibility alias for [UiState].
typedef ReactiveStateData = UiState;
