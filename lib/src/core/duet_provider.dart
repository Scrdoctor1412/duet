import 'package:flutter/widgets.dart';
import 'package:duet/src/core/duet_core.dart';

/// Quản lý nội b�?việc khởi tạo và lưu tr�?các instance Singleton của Duet theo Type và Key.
class _DuetRegistryImpl {
  static final Map<Object, Duet> _instances = {};

  /// Lấy hoặc t�?động khởi tạo tr�?(Lazy init) instance của Duet kiểu [T].
  static T get<T extends Duet>(T Function() creator, {Object? key}) {
    if (_instances.containsKey(T) &&
        _instances[T]!.isGlobal &&
        !_instances[T]!.isDisposed) {
      return _instances[T] as T;
    }

    final registryKey = key != null ? Object.hash(T, key) : T;

    if (!_instances.containsKey(registryKey) ||
        _instances[registryKey]!.isDisposed) {
      final instance = creator();
      if (instance.isGlobal) {
        _instances[T] = instance;
        return instance;
      }

      assert(
        key != null,
        'CẢNH BÁO: Bạn đang lấy Duet [${T.toString()}] qua getDuet mà KHÔNG truyền `key`, '
        'trong khi `isGlobal` = false. Điều này có th�?dẫn đến việc nhiều màn hình dùng chung 1 instance! '
        'Khuyên dùng `getDuet(() => ${T.toString()}(), key: this)` hoặc `context.duet(...)` hoặc ghi đè `bool get isGlobal => true`.',
      );
      _instances[registryKey] = instance;
    }
    return _instances[registryKey] as T;
  }

  /// Giải phóng và xóa instance của Duet kiểu [T] khỏi Registry.
  static void reset<T extends Duet>({Object? key}) {
    final registryKey = key != null ? Object.hash(T, key) : T;
    if (_instances.containsKey(registryKey)) {
      _instances[registryKey]?.dispose();
      _instances.remove(registryKey);
    }
  }

  /// Xóa một instance Duet c�?th�?khỏi Registry.
  static void removeInstance(Duet vm) {
    _instances.removeWhere((key, value) => identical(value, vm));
  }

  /// Giải phóng b�?nh�?và xóa toàn b�?các Duet đang lưu trong Registry.
  static void resetAll() {
    for (final vm in _instances.values) {
      vm.dispose();
    }
    _instances.clear();
  }
}

/// Hàm tr�?giúp toàn cục chính thức lấy hoặc t�?động khởi tạo tr�?(Lazy creation) Duet instance [T].
T getDuet<T extends Duet>(T Function() creator, {Object? key}) {
  return _DuetRegistryImpl.get<T>(creator, key: key);
}

/// Alias tương thích ngược cho getDuet
T getVM<T extends Duet>(T Function() creator, {Object? key}) {
  return getDuet<T>(creator, key: key);
}

/// Extension giúp lấy Duet thông qua [BuildContext] với tính năng t�?động tạo key t�?Route.
extension DuetContextX on BuildContext {
  /// Lấy hoặc t�?động khởi tạo Duet [T].
  T duet<T extends Duet>(T Function() creator, {Object? key}) {
    final autoKey = key ?? ModalRoute.of(this)?.settings.name ?? T.toString();
    return _DuetRegistryImpl.get<T>(creator, key: autoKey);
  }

  /// Alias tương thích ngược cho duet()
  T getVM<T extends Duet>(T Function() creator, {Object? key}) {
    return duet<T>(creator, key: key);
  }
}

/// Hàm nội b�?hủy đăng ký Duet khỏi Registry khi b�?autoDispose.
void unregisterVM(Duet vm) {
  _DuetRegistryImpl.removeInstance(vm);
}

/// Class tiện ích phục v�?việc quản lý Registry và h�?tr�?trong Unit Test.
abstract class DuetRegistry {
  /// Giải phóng b�?nh�?và xóa toàn b�?các Duet trong ứng dụng.
  static void resetAll() => _DuetRegistryImpl.resetAll();

  /// Alias tiện lợi cho resetAll
  static void clearAll() => resetAll();

  /// Giải phóng và khởi tạo lại duy nhất Duet của kiểu [T] với [key] tùy chọn.
  static void reset<T extends Duet>({Object? key}) =>
      _DuetRegistryImpl.reset<T>(key: key);
}

/// Alias tương thích ngược cho DuetRegistry
typedef ViewModelRegistry = DuetRegistry;
