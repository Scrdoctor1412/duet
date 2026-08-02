import 'package:flutter/widgets.dart';
import 'package:duet/src/core/duet_core.dart';

abstract class _AnyDuetScope extends InheritedWidget {
  const _AnyDuetScope({super.key, required super.child});

  Duet get viewModel;
}

/// {@template duet_scope}
/// Widget cho phép phân vùng một Duet c�?th�?xuống cây Widget con bằng BuildContext.
/// {@endtemplate}
class DuetScope<VM extends Duet> extends _AnyDuetScope {
  /// Duet được gắn vào nhánh cây Widget này.
  @override
  final VM viewModel;

  /// {@macro duet_scope}
  const DuetScope({
    super.key,
    required this.viewModel,
    required super.child,
  });

  /// Lấy Duet gần nhất thuộc kiểu [VM] trên cây Widget trong O(1).
  static VM of<VM extends Duet>(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<DuetScope<VM>>();
    if (scope != null) return scope.viewModel;

    final anyScope = context.dependOnInheritedWidgetOfExactType<_AnyDuetScope>();
    if (anyScope != null && anyScope.viewModel is VM) {
      return anyScope.viewModel as VM;
    }

    VM? foundVM;
    InheritedElement? foundElement;

    context.visitAncestorElements((element) {
      if (element is InheritedElement && element.widget is _AnyDuetScope) {
        final scopeWidget = element.widget as _AnyDuetScope;
        if (scopeWidget.viewModel is VM) {
          foundVM = scopeWidget.viewModel as VM;
          foundElement = element;
          return false;
        }
      }
      return true;
    });

    if (foundElement != null && foundVM != null) {
      context.dependOnInheritedElement(foundElement!);
      return foundVM!;
    }

    assert(
      false,
      '�?CẢNH BÁO LỖI DUET:\n'
      'Không tìm thấy DuetScope<$VM> nào trong BuildContext hiện tại!\n'
      '👉 Hãy đảm bảo bạn đã bọc `DuetScope`, dùng `DuetView`/`DuetStateMixin` �?Màn hình cha, hoặc truyền `viewModel:` trực tiếp.',
    );
    throw StateError('DuetScope<$VM> not found in BuildContext.');
  }

  /// Tìm kiếm Duet phù hợp với kiểu d�?liệu [D] và [B] t�?BuildContext hoặc dùng [explicitVM] trong O(1).
  static Duet<D, B> find<D, B>(
    BuildContext context, {
    Duet<D, B>? explicitVM,
  }) {
    if (explicitVM != null) return explicitVM;

    final anyScope = context.dependOnInheritedWidgetOfExactType<_AnyDuetScope>();
    if (anyScope != null && anyScope.viewModel is Duet<D, B>) {
      return anyScope.viewModel as Duet<D, B>;
    }

    Duet<D, B>? foundVM;
    InheritedElement? foundElement;

    context.visitAncestorElements((element) {
      if (element is InheritedElement && element.widget is _AnyDuetScope) {
        final scope = element.widget as _AnyDuetScope;
        if (scope.viewModel is Duet<D, B>) {
          foundVM = scope.viewModel as Duet<D, B>;
          foundElement = element;
          return false;
        }
      }
      return true;
    });

    if (foundElement != null && foundVM != null) {
      context.dependOnInheritedElement(foundElement!);
      return foundVM!;
    }

    assert(
      false,
      '�?CẢNH BÁO LỖI DUET:\n'
      'Không tìm thấy Duet phù hợp cho kiểu <$D, $B> trong BuildContext hiện tại!\n'
      '👉 Hãy thực hiện 1 trong các cách sau:\n'
      '1. Truyền `viewModel:` trực tiếp vào Widget.\n'
      '2. K�?thừa `DuetView` hoặc dùng `DuetStateMixin` �?Màn hình cha.\n'
      '3. Bọc cây Widget con trong `DuetScope`.',
    );
    throw StateError('Duet for <$D, $B> not found in BuildContext.');
  }

  @override
  bool updateShouldNotify(DuetScope<VM> oldWidget) =>
      viewModel != oldWidget.viewModel;
}

/// Extension giúp truy cập Duet bằng BuildContext: `context.duetOf<MyDuet>()` hoặc `context.vm<MyViewModel>()`
extension DuetScopeContextX on BuildContext {
  /// Truy cập Duet được phân vùng gần nhất trên cây Widget.
  VM duetOf<VM extends Duet>() => DuetScope.of<VM>(this);

  /// Alias tương thích ngược cho duetOf
  VM vm<VM extends Duet>() => DuetScope.of<VM>(this);
}

/// Alias tương thích cho VMScope
typedef VMScope<VM extends Duet> = DuetScope<VM>;
