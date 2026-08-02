import 'package:flutter/widgets.dart';
import 'package:duet/src/core/duet_core.dart';
import 'package:duet/src/core/duet_provider.dart';

/// Mixin gắn vào [State] của [StatefulWidget], t�?động quản lý vòng đời và lắng nghe các [Listenable].
mixin DuetConsumer<T extends StatefulWidget> on State<T> {
  /// Danh sách các đối tượng [Listenable] cần lắng nghe.
  List<Listenable> get listenTo;

  /// ViewModel liên kết tùy chọn phục v�?theo dõi vòng đời [Duet.autoDispose].
  Duet? get viewModel => null;

  @override
  void initState() {
    super.initState();
    viewModel?.retain();
    for (final listenable in listenTo) {
      listenable.addListener(_rebuild);
    }
  }

  @override
  void dispose() {
    for (final listenable in listenTo) {
      listenable.removeListener(_rebuild);
    }
    if (viewModel != null) {
      viewModel!.release(() {
        unregisterVM(viewModel!);
      });
    }
    super.dispose();
  }

  /// Hàm callback kích hoạt re-build giao diện khi có thông báo thay đổi.
  void _rebuild() {
    if (mounted) {
      setState(() {});
    }
  }
}

/// Alias cho ReactiveConsumer
typedef ReactiveConsumer<T extends StatefulWidget> = DuetConsumer<T>;
