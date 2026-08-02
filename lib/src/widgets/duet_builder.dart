import 'package:flutter/widgets.dart';
import 'package:duet/src/core/duet_core.dart';
import 'package:duet/src/core/duet_provider.dart';
import 'package:duet/src/widgets/duet_scope.dart';

/// Ch�?đ�?chọn Notifier đ�?lắng nghe trong [DuetBuilder].
enum DuetTarget {
  /// Lắng nghe [Duet.dataNotifier].
  data,

  /// Lắng nghe [Duet.behaviorNotifier].
  ui,

  /// Lắng nghe c�?[Duet.dataNotifier] và [Duet.behaviorNotifier].
  both,
}

/// Alias cho ReactiveTarget
typedef ReactiveTarget = DuetTarget;

class DuetBuilder<D, B> extends StatefulWidget {
  /// ViewModel liên kết tùy chọn (Nếu null s�?t�?tìm kiếm trong BuildContext).
  final Duet<D, B>? viewModel;

  /// Hàm builder nhận d�?liệu nghiệp v�?[D].
  final Widget Function(BuildContext context, D data)? dataBuilder;

  /// Hàm builder nhận trạng thái UI [B].
  final Widget Function(BuildContext context, B ui)? uiBuilder;

  /// Hàm builder nhận C�?d�?liệu nghiệp v�?[D] lẫn trạng thái UI [B].
  final Widget Function(BuildContext context, D data, B ui)? bothBuilder;

  /// Loại Notifier cần lắng nghe.
  final DuetTarget target;

  /// Mặc định lắng nghe d�?liệu nghiệp v�?[Duet.dataNotifier].
  const DuetBuilder({
    super.key,
    this.viewModel,
    required Widget Function(BuildContext context, D data) builder,
  })  : dataBuilder = builder,
        uiBuilder = null,
        bothBuilder = null,
        target = DuetTarget.data;

  /// Lắng nghe trạng thái hành vi UI [Duet.behaviorNotifier].
  const DuetBuilder.ui({
    super.key,
    this.viewModel,
    required Widget Function(BuildContext context, B ui) builder,
  })  : uiBuilder = builder,
        dataBuilder = null,
        bothBuilder = null,
        target = DuetTarget.ui;

  /// Lắng nghe C�?d�?liệu nghiệp v�?[Duet.dataNotifier] lẫn trạng thái UI [Duet.behaviorNotifier].
  const DuetBuilder.both({
    super.key,
    this.viewModel,
    required Widget Function(BuildContext context, D data, B ui) builder,
  })  : bothBuilder = builder,
        dataBuilder = null,
        uiBuilder = null,
        target = DuetTarget.both;

  @override
  State<DuetBuilder<D, B>> createState() => _DuetBuilderState<D, B>();
}

class _DuetBuilderState<D, B> extends State<DuetBuilder<D, B>> {
  Duet<D, B>? _effectiveVM;
  List<ValueNotifier<dynamic>> _notifiers = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newVM = DuetScope.find<D, B>(context, explicitVM: widget.viewModel);

    if (_effectiveVM != newVM) {
      if (_effectiveVM != null) {
        for (final notifier in _notifiers) {
          notifier.removeListener(_rebuild);
        }
        _effectiveVM!.release(() {
          unregisterVM(_effectiveVM!);
        });
      }

      _effectiveVM = newVM;
      _effectiveVM!.retain();
      _notifiers = _getNotifiers();
      for (final notifier in _notifiers) {
        notifier.addListener(_rebuild);
      }
    }
  }

  List<ValueNotifier<dynamic>> _getNotifiers() {
    switch (widget.target) {
      case DuetTarget.data:
        return [_effectiveVM!.dataNotifier];
      case DuetTarget.ui:
        return [_effectiveVM!.behaviorNotifier];
      case DuetTarget.both:
        return [
          _effectiveVM!.dataNotifier,
          _effectiveVM!.behaviorNotifier,
        ];
    }
  }

  void _rebuild() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    for (final notifier in _notifiers) {
      notifier.removeListener(_rebuild);
    }
    if (_effectiveVM != null) {
      _effectiveVM!.release(() {
        unregisterVM(_effectiveVM!);
      });
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.target) {
      case DuetTarget.data:
        return widget.dataBuilder!(context, _effectiveVM!.dataState);
      case DuetTarget.ui:
        return widget.uiBuilder!(context, _effectiveVM!.behaviorState);
      case DuetTarget.both:
        return widget.bothBuilder!(
          context,
          _effectiveVM!.dataState,
          _effectiveVM!.behaviorState,
        );
    }
  }
}

/// Alias cho ReactiveBuilder
typedef ReactiveBuilder<D, B> = DuetBuilder<D, B>;
