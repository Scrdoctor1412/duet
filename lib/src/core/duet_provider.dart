import 'package:flutter/widgets.dart';
import 'package:duet/src/core/duet_core.dart';

/// Internal registry managing initialization and storage of Duet instances by Type and Key.
class _DuetRegistryImpl {
  static final Map<Object, Duet> _instances = {};

  /// Retrieves or lazily initializes a Duet instance of type [T].
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
        'WARNING: Retrieving Duet [${T.toString()}] via getDuet without providing a `key` '
        'while `isGlobal` is false. This may lead to multiple screens accidentally sharing the same instance! '
        'Consider using `getDuet(() => ${T.toString()}(), key: this)` or `context.duet(...)` or overriding `bool get isGlobal => true`.',
      );
      _instances[registryKey] = instance;
    }
    return _instances[registryKey] as T;
  }

  /// Resets and removes the Duet instance of type [T] from registry.
  static void reset<T extends Duet>({Object? key}) {
    final registryKey = key != null ? Object.hash(T, key) : T;
    if (_instances.containsKey(registryKey)) {
      _instances[registryKey]?.dispose();
      _instances.remove(registryKey);
    }
  }

  /// Removes a specific Duet instance from registry.
  static void removeInstance(Duet vm) {
    _instances.removeWhere((key, value) => identical(value, vm));
  }

  /// Disposes and clears all registered Duet instances.
  static void resetAll() {
    for (final vm in _instances.values) {
      vm.dispose();
    }
    _instances.clear();
  }
}

/// Global helper function to retrieve or lazily create a Duet instance of type [T].
T getDuet<T extends Duet>(T Function() creator, {Object? key}) {
  return _DuetRegistryImpl.get<T>(creator, key: key);
}

/// Backward compatibility alias for [getDuet].
T getVM<T extends Duet>(T Function() creator, {Object? key}) {
  return getDuet<T>(creator, key: key);
}

/// Extension providing [BuildContext] access to lazily create and locate Duet instances with automatic route keys.
extension DuetContextX on BuildContext {
  /// Retrieves or lazily creates a Duet instance of type [T].
  T duet<T extends Duet>(T Function() creator, {Object? key}) {
    final autoKey = key ?? ModalRoute.of(this)?.settings.name ?? T.toString();
    return _DuetRegistryImpl.get<T>(creator, key: autoKey);
  }

  /// Backward compatibility alias for [duet].
  T getVM<T extends Duet>(T Function() creator, {Object? key}) {
    return duet<T>(creator, key: key);
  }
}

/// Internal helper unregistering a disposed Duet instance from the registry.
void unregisterVM(Duet vm) {
  _DuetRegistryImpl.removeInstance(vm);
}

/// Public utility class for managing the registry during runtime and unit testing.
abstract class DuetRegistry {
  /// Disposes and clears all active Duet instances.
  static void resetAll() => _DuetRegistryImpl.resetAll();

  /// Convenient alias for [resetAll].
  static void clearAll() => resetAll();

  /// Disposes and resets a specific Duet instance of type [T] with optional [key].
  static void reset<T extends Duet>({Object? key}) =>
      _DuetRegistryImpl.reset<T>(key: key);
}

/// Backward compatibility alias for [DuetRegistry].
typedef ViewModelRegistry = DuetRegistry;
