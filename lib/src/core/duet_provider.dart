import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:duet/src/core/duet_core.dart';

/// Internal registry managing initialization and storage of Duet instances by Type and Key.
class _DuetRegistryImpl {
  static final Map<Object, Duet> _instances = {};
  static final Set<Object> _sharedKeys = {};

  static Object _sharedRegistryKey<T extends Duet>(Object? key) {
    return key == null
        ? (_DuetRegistrySpace.shared, T)
        : (_DuetRegistrySpace.shared, T, key);
  }

  static Object _registryKey<T extends Duet>(Object? key) {
    return key == null ? T : (T, key);
  }

  /// Retrieves or lazily initializes a Duet instance of type [T].
  static T get<T extends Duet>(T Function() creator, {Object? key}) {
    if (_instances.containsKey(T) &&
        _instances[T]!.isGlobal &&
        !_instances[T]!.isDisposed) {
      return _instances[T] as T;
    }

    final registryKey = _registryKey<T>(key);

    if (!_instances.containsKey(registryKey) ||
        _instances[registryKey]!.isDisposed) {
      final instance = creator();
      if (instance.isGlobal) {
        _instances[T] = instance;
        return instance;
      }

      assert(
        key != null,
        'DEPRECATED DUET REGISTRY USAGE: Retrieving [${T.toString()}] without '
        'a `key` while `isGlobal` is false can accidentally share local state. '
        'Use Duets.shared() for intentional shared state, or create local state '
        'with DuetView/DuetScope.',
      );
      _instances[registryKey] = instance;
    }
    return _instances[registryKey] as T;
  }

  /// Returns one lazily-created, registry-owned shared Duet instance.
  static T shared<T extends Duet>(T Function() creator, {Object? key}) {
    final registryKey = _sharedRegistryKey<T>(key);
    final existing = _instances[registryKey];
    if (existing != null && !existing.isDisposed) {
      return existing as T;
    }

    final instance = creator();
    if (instance.isDisposed) {
      throw StateError('Duets.shared<$T>() cannot register a disposed Duet.');
    }

    // The registry owns one reference so shared state survives gaps between
    // screens. Widgets may retain/release their own references independently.
    instance.retain();
    _instances[registryKey] = instance;
    _sharedKeys.add(registryKey);
    return instance;
  }

  static T? findShared<T extends Duet>({Object? key}) {
    final instance = _instances[_sharedRegistryKey<T>(key)];
    if (instance == null || instance.isDisposed) return null;
    return instance as T;
  }

  static bool containsShared<T extends Duet>({Object? key}) {
    return findShared<T>(key: key) != null;
  }

  static void resetShared<T extends Duet>({Object? key}) {
    final registryKey = _sharedRegistryKey<T>(key);
    _sharedKeys.remove(registryKey);
    final instance = _instances.remove(registryKey);
    if (instance != null) {
      instance.release(() {}, disposeWhenUnreferenced: true);
    }
  }

  /// Resolves a Duet instance created by a view without invoking its factory
  /// more than once.
  static T resolveBound<T extends Duet>(T candidate) {
    if (!candidate.isGlobal) return candidate;

    final existing = _instances[T];
    if (existing != null && !existing.isDisposed) {
      if (!identical(existing, candidate)) {
        candidate.dispose();
      }
      return existing as T;
    }

    _instances[T] = candidate;
    return candidate;
  }

  /// Resets and removes the Duet instance of type [T] from registry.
  static void reset<T extends Duet>({Object? key}) {
    final registryKey = _registryKey<T>(key);
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
    final entries = _instances.entries.toList(growable: false);
    _instances.clear();

    for (final entry in entries) {
      if (_sharedKeys.contains(entry.key)) {
        entry.value.release(() {}, disposeWhenUnreferenced: true);
      } else {
        entry.value.dispose();
      }
    }
    _sharedKeys.clear();
  }
}

enum _DuetRegistrySpace { shared }

/// Legacy helper that retrieves or lazily creates a Duet instance by type and
/// optional key.
///
/// Use [Duets.shared] for intentionally shared state. For screen-local state,
/// create the Duet in `DuetView.bindDuet` or provide it with `DuetScope`.
@Deprecated(
  'Use Duets.shared() for shared state, or DuetView/DuetScope for local state. '
  'This API will be removed in 2.0.0.',
)
T getDuet<T extends Duet>(T Function() creator, {Object? key}) {
  return _DuetRegistryImpl.get<T>(creator, key: key);
}

/// Backward compatibility alias for [getDuet].
@Deprecated(
  'Use Duets.shared() for shared state, or DuetView/DuetScope for local state. '
  'This API will be removed in 2.0.0.',
)
T getVM<T extends Duet>(T Function() creator, {Object? key}) {
  return _DuetRegistryImpl.get<T>(creator, key: key);
}

/// Intentional service locator for Duet state shared across screens or flows.
///
/// Local screen state should still be created directly by `DuetView.bindDuet`.
/// Shared instances are lazily created, owned by this registry, and remain alive
/// between screens until [reset] or [resetAll] is called.
abstract final class Duets {
  /// Returns the shared instance for type [T], creating it on first access.
  static T shared<T extends Duet>(T Function() create, {Object? key}) {
    return _DuetRegistryImpl.shared<T>(create, key: key);
  }

  /// Returns an existing shared instance, or `null` if it has not been created.
  static T? find<T extends Duet>({Object? key}) {
    return _DuetRegistryImpl.findShared<T>(key: key);
  }

  /// Whether a live shared instance exists for [T] and [key].
  static bool contains<T extends Duet>({Object? key}) {
    return _DuetRegistryImpl.containsShared<T>(key: key);
  }

  /// Removes one shared instance and disposes it after mounted users detach.
  static void reset<T extends Duet>({Object? key}) {
    _DuetRegistryImpl.resetShared<T>(key: key);
  }

  /// Disposes all shared and legacy registered Duet instances.
  static void resetAll() => _DuetRegistryImpl.resetAll();
}

/// Legacy [BuildContext] helpers for the old keyed registry API.
extension DuetContextX on BuildContext {
  /// Retrieves or lazily creates a Duet instance of type [T].
  @Deprecated(
    'Create local state in DuetView.bindDuet or provide it with DuetScope. '
    'Use Duets.shared() for shared state. This API will be removed in 2.0.0.',
  )
  T duet<T extends Duet>(T Function() creator, {Object? key}) {
    final autoKey = key ?? ModalRoute.of(this) ?? this;
    return _DuetRegistryImpl.get<T>(creator, key: autoKey);
  }

  /// Backward compatibility alias for [duet].
  @Deprecated(
    'Create local state in DuetView.bindDuet or provide it with DuetScope. '
    'Use Duets.shared() for shared state. This API will be removed in 2.0.0.',
  )
  T getVM<T extends Duet>(T Function() creator, {Object? key}) {
    final autoKey = key ?? ModalRoute.of(this) ?? this;
    return _DuetRegistryImpl.get<T>(creator, key: autoKey);
  }
}

/// Internal helper unregistering a disposed Duet instance from the registry.
void unregisterVM(Duet vm) {
  _DuetRegistryImpl.removeInstance(vm);
}

/// Resolves a View-bound instance while preserving global singleton semantics.
///
/// Unlike the legacy registry lookup, this never evaluates `bindDuet` twice.
@internal
T resolveBoundDuet<T extends Duet>(T candidate) {
  return _DuetRegistryImpl.resolveBound(candidate);
}

/// Releases a widget reference and removes an auto-disposed instance from the
/// registry when necessary.
@internal
void releaseDuet(Duet vm) {
  vm.release(() => _DuetRegistryImpl.removeInstance(vm));
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
