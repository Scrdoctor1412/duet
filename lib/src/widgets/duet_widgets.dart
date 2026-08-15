import 'package:duet/src/core/duet_core.dart';
import 'package:duet/src/widgets/duet_builder.dart';
import 'package:duet/src/widgets/duet_listener.dart';
import 'package:duet/src/widgets/duet_selector.dart';
import 'package:flutter/widgets.dart';

/// Flutter widget helpers bound directly to a [Duet] instance.
///
/// These helpers keep dependencies explicit and remove the need for UI code to
/// look up a Duet through [BuildContext] or repeat its data and UI generic types.
extension DuetWidgets<D, B> on Duet<D, B> {
  /// Rebuilds when the business data channel changes.
  Widget watchData({
    Key? key,
    required Widget Function(BuildContext context, D data) builder,
  }) {
    return DuetBuilder<D, B>(
      key: key,
      viewModel: this,
      builder: builder,
    );
  }

  /// Rebuilds when the UI behavior channel changes.
  Widget watchUi({
    Key? key,
    required Widget Function(BuildContext context, B ui) builder,
  }) {
    return DuetBuilder<D, B>.ui(
      key: key,
      viewModel: this,
      builder: builder,
    );
  }

  /// Rebuilds when either the business data or UI behavior channel changes.
  Widget watchBoth({
    Key? key,
    required Widget Function(BuildContext context, D data, B ui) builder,
  }) {
    return DuetBuilder<D, B>.both(
      key: key,
      viewModel: this,
      builder: builder,
    );
  }

  /// Rebuilds only when the selected business data value changes.
  Widget selectData<T>({
    Key? key,
    required T Function(D data) select,
    required Widget Function(BuildContext context, T value) builder,
    bool Function(T previous, T current)? shouldRebuild,
  }) {
    return DuetSelector<Duet<D, B>, T>(
      key: key,
      viewModel: this,
      selector: (duet) => select(duet.data),
      shouldRebuild: shouldRebuild,
      builder: builder,
    );
  }

  /// Rebuilds only when the selected UI behavior value changes.
  Widget selectUi<T>({
    Key? key,
    required T Function(B ui) select,
    required Widget Function(BuildContext context, T value) builder,
    bool Function(T previous, T current)? shouldRebuild,
  }) {
    return DuetSelector<Duet<D, B>, T>.ui(
      key: key,
      viewModel: this,
      selector: (duet) => select(duet.ui),
      shouldRebuild: shouldRebuild,
      builder: builder,
    );
  }

  /// Listens to one-shot effects emitted by this Duet instance.
  Widget listen<E>({
    Key? key,
    required void Function(BuildContext context, E effect) onEffect,
    bool Function(E effect)? listenWhen,
    required Widget child,
  }) {
    return DuetListener<Duet<D, B>, E>(
      key: key,
      viewModel: this,
      onEvent: onEffect,
      listenWhen: listenWhen,
      child: child,
    );
  }
}
