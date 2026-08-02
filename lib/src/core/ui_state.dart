import 'package:flutter/foundation.dart';

/// {@template ui_state}
/// Sealed Class chuẩn hóa toàn cục trạng thái hành vi UI (Behavior State).
///
/// Định nghĩa 4 trạng thái UI cốt lõi:
/// - [UiIdle]: Trạng thái ch�?/ Ban đầu.
/// - [UiLoading]: Trạng thái đang tải d�?liệu.
/// - [UiSuccess]: Trạng thái tải d�?liệu thành công.
/// - [UiError]: Trạng thái gặp lỗi (kèm [message]).
///
/// H�?tr�?Pattern Matching (Dart 3) bắt buộc x�?lý đ�?các nhánh �?UI.
/// {@endtemplate}
@immutable
sealed class UiState {
  const UiState();

  factory UiState.idle() = UiIdle;
  factory UiState.loading() = UiLoading;
  factory UiState.success() = UiSuccess;
  factory UiState.error(String message) = UiError;
}

final class UiIdle extends UiState {
  const UiIdle();
}

final class UiLoading extends UiState {
  const UiLoading();
}

final class UiSuccess extends UiState {
  const UiSuccess();
}

final class UiError extends UiState {
  final String message;
  const UiError(this.message);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UiError &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;
}
