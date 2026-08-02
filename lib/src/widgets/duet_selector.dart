import 'package:flutter/widgets.dart';
import 'package:duet/src/core/duet_core.dart';
import 'package:duet/src/core/duet_provider.dart';
import 'package:duet/src/widgets/duet_scope.dart';

class DuetSelector<VM extends Duet, T> extends StatefulWidget {
  /// ViewModel liên kết tùy chọn (Nếu null s�?t�?tìm kiếm trong BuildContext).
  final VM? viewModel;

  /// Hàm trích xuất giá tr�?[T] t�?ViewModel [VM].
  final T Function(VM vm) selector;

  /// Hàm builder tr�?v�?cây Widget giao diện ph�?thuộc vào giá tr�?[T] đã chọn.
  final Widget Function(BuildContext context, T value) builder;

  /// Hàm so sánh tùy chỉnh đ�?quyết định Widget có nên rebuild hay không.
  final bool Function(T previous, T current)? shouldRebuild;

  /// C�?xác định xem đang lắng nghe `dataNotifier` (false) hay `behaviorNotifier` (true).
  final bool _isUiSelector;

  /// Lắng nghe s�?thay đổi một phần của d�?liệu nghiệp v�?(`dataNotifier`).
  const DuetSelector({
    super.key,
    this.viewModel,
    required this.selector,
    required this.builder,
    this.shouldRebuild,
  })  : _isUiSelector = false;

  /// Lắng nghe s�?thay đổi một phần của trạng thái UI (`behaviorNotifier`).
  const DuetSelector.ui({
    super.key,
    this.viewModel,
    required this.selector,
    required this.builder,
    this.shouldRebuild,
  })  : _isUiSelector = true;

  @override
  State<DuetSelector<VM, T>> createState() =>
      _DuetSelectorState<VM, T>();
}

class _DuetSelectorState<VM extends Duet, T>
    extends State<DuetSelector<VM, T>> {
  VM? _effectiveVM;
  ValueNotifier<dynamic>? _notifier;
  late T _selectedValue;

  T _computeSelectedValue() {
    return widget.selector(_effectiveVM!);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newVM = widget.viewModel ?? DuetScope.of<VM>(context);

    if (_effectiveVM != newVM) {
      if (_effectiveVM != null && _notifier != null) {
        _notifier!.removeListener(_onStateChanged);
        _effectiveVM!.release(() {
          if (_effectiveVM!.isGlobal) {
            unregisterVM(_effectiveVM!);
          }
        });
      }

      _effectiveVM = newVM;
      _effectiveVM!.retain();
      _notifier = widget._isUiSelector
          ? _effectiveVM!.behaviorNotifier
          : _effectiveVM!.dataNotifier;
      _selectedValue = _computeSelectedValue();
      _notifier!.addListener(_onStateChanged);
    }
  }

  void _onStateChanged() {
    final newSelectedValue = _computeSelectedValue();
    final needRebuild = widget.shouldRebuild != null
        ? widget.shouldRebuild!(_selectedValue, newSelectedValue)
        : _selectedValue != newSelectedValue;

    if (needRebuild) {
      _selectedValue = newSelectedValue;
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    if (_notifier != null) {
      _notifier!.removeListener(_onStateChanged);
    }
    if (_effectiveVM != null) {
      _effectiveVM!.release(() {
        if (_effectiveVM!.isGlobal) {
          unregisterVM(_effectiveVM!);
        }
      });
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _selectedValue);
  }
}

/// Alias cho ReactiveSelector
typedef ReactiveSelector<VM extends Duet, T> = DuetSelector<VM, T>;
