import 'package:flutter/widgets.dart';
import 'package:duet/src/core/duet_core.dart';

abstract class _AnyDuetScope extends InheritedWidget {
  const _AnyDuetScope({super.key, required super.child});

  Duet get viewModel;
}

/// {@template duet_scope}
/// An [InheritedWidget] scoping a specific [Duet] instance down the widget subtree via [BuildContext].
/// {@endtemplate}
class DuetScope<VM extends Duet> extends _AnyDuetScope {
  /// The Duet instance scoped to this subtree.
  @override
  final VM viewModel;

  /// {@macro duet_scope}
  const DuetScope({
    super.key,
    required this.viewModel,
    required super.child,
  });

  /// Retrieves the nearest [Duet] instance of type [VM].
  ///
  /// The normal `DuetScope<VM>` path uses Flutter's inherited-element index in
  /// O(1). The ancestor fallback only exists for dynamically typed or nested
  /// legacy scopes.
  static VM of<VM extends Duet>(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<DuetScope<VM>>();
    if (scope != null) return scope.viewModel;

    final fallback = _findMatching(context, (duet) => duet is VM);
    if (fallback != null) return fallback as VM;

    assert(
      false,
      'DUET SCOPE ERROR:\n'
      'Could not find DuetScope<$VM> in the current BuildContext!\n'
      'Ensure you wrapped the widget subtree with `DuetScope`, extended `DuetView`/`DuetStateMixin` on the parent screen, or passed `viewModel:` explicitly.',
    );
    throw StateError('DuetScope<$VM> not found in BuildContext.');
  }

  /// Finds a matching Duet instance for generic types [D] and [B] from [BuildContext] or uses [explicitVM].
  static Duet<D, B> find<D, B>(
    BuildContext context, {
    Duet<D, B>? explicitVM,
  }) {
    if (explicitVM != null) return explicitVM;

    final fallback = _findMatching(context, (duet) => duet is Duet<D, B>);
    if (fallback != null) return fallback as Duet<D, B>;

    assert(
      false,
      'DUET SCOPE ERROR:\n'
      'Could not find a matching Duet for types <$D, $B> in the current BuildContext!\n'
      'Ensure you do one of the following:\n'
      '1. Pass `viewModel:` directly to the widget.\n'
      '2. Extend `DuetView` or mix in `DuetStateMixin` on the parent screen.\n'
      '3. Wrap the subtree in a `DuetScope`.',
    );
    throw StateError('Duet for <$D, $B> not found in BuildContext.');
  }

  static Duet? _findMatching(
    BuildContext context,
    bool Function(Duet duet) matches,
  ) {
    Duet? foundVM;
    InheritedElement? foundElement;

    context.visitAncestorElements((element) {
      if (element is InheritedElement && element.widget is _AnyDuetScope) {
        final scope = element.widget as _AnyDuetScope;
        if (matches(scope.viewModel)) {
          foundVM = scope.viewModel;
          foundElement = element;
          return false;
        }
      }
      return true;
    });

    if (foundElement != null && foundVM != null) {
      context.dependOnInheritedElement(foundElement!);
      return foundVM;
    }
    return null;
  }

  @override
  bool updateShouldNotify(DuetScope<VM> oldWidget) =>
      viewModel != oldWidget.viewModel;
}

/// Extension providing convenient [BuildContext] access: `context.duetOf<MyDuet>()` or `context.vm<MyViewModel>()`.
extension DuetScopeContextX on BuildContext {
  /// Accesses the nearest scoped Duet up the widget tree.
  VM duetOf<VM extends Duet>() => DuetScope.of<VM>(this);

  /// Backward compatibility alias for [duetOf].
  VM vm<VM extends Duet>() => DuetScope.of<VM>(this);
}

/// Backward compatibility alias for [DuetScope].
typedef VMScope<VM extends Duet> = DuetScope<VM>;
