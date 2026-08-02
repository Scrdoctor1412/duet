import 'package:flutter/widgets.dart';
import 'package:duet/src/core/duet_core.dart';
import 'package:duet/src/core/duet_provider.dart';
import 'package:duet/src/widgets/duet_scope.dart';

/// Mixin gắn vào [State] của [StatefulWidget], t�?động khởi tạo Duet [VM].
mixin DuetStateMixin<W extends StatefulWidget, VM extends Duet>
    on State<W> {
  late final VM _duet;

  /// Tr�?v�?instance của Duet [VM] liên kết với Widget này.
  VM get duet => _duet;

  /// Aliases tương thích cho [duet].
  VM get vm => _duet;
  VM get viewModel => _duet;

  /// Hàm cung cấp/liên kết Duet instance cho Màn hình (Bắt buộc triển khai bindDuet hoặc bindViewModel).
  VM bindDuet() => bindViewModel();

  /// Alias tương thích cho [bindDuet].
  VM bindViewModel() {
    throw UnimplementedError('Bạn phải ghi đè bindDuet() hoặc bindViewModel()');
  }

  /// Bọc cây Widget con bằng [DuetScope].
  Widget buildScope(Widget child) {
    return DuetScope<VM>(
      viewModel: _duet,
      child: child,
    );
  }

  @override
  void initState() {
    super.initState();
    final temp = bindDuet();
    if (temp.isGlobal) {
      _duet = getDuet<VM>(bindDuet);
    } else {
      _duet = temp;
    }
    _duet.retain();
  }

  @override
  void dispose() {
    _duet.release(() {
      if (_duet.isGlobal) {
        unregisterVM(_duet);
      }
    });
    super.dispose();
  }
}

/// Alias cho ReactiveStateMixin
typedef ReactiveStateMixin<W extends StatefulWidget, VM extends Duet> = DuetStateMixin<W, VM>;

/// {@template duet_view}
/// Class cơ s�?cho Widget đại diện cho Màn hình (Screen/View) t�?động liên kết với [Duet].
/// {@endtemplate}
abstract class DuetView<VM extends Duet> extends StatefulWidget {
  const DuetView({super.key});

  /// Hàm cung cấp/liên kết Duet instance cho Màn hình.
  VM bindDuet() => bindViewModel();

  /// Alias tương thích cho [bindDuet].
  VM bindViewModel() {
    throw UnimplementedError('Bạn phải ghi đè bindDuet() hoặc bindViewModel()');
  }

  /// Hàm dựng giao diện nhận trực tiếp [context] và [duet].
  Widget build(BuildContext context, VM duet);

  @override
  State<DuetView<VM>> createState() => _DuetViewState<VM>();
}

class _DuetViewState<VM extends Duet> extends State<DuetView<VM>>
    with DuetStateMixin<DuetView<VM>, VM> {
  @override
  VM bindDuet() => widget.bindDuet();

  @override
  Widget build(BuildContext context) {
    return DuetScope<VM>(
      viewModel: duet,
      child: widget.build(context, duet),
    );
  }
}

/// Alias cho ReactiveView
typedef ReactiveView<VM extends Duet> = DuetView<VM>;
