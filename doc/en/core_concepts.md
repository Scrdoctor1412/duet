# 💡 Core Concepts & Developer Guide

## 1. `Duet<D, B>` (Separating Data & UI Behavior)

`Duet<D, B>` (also aliased as `DuetViewModel`, `DuetController`, or `ViewModel`) is the core class of the library. It accepts two generic type parameters:
- `D`: The Data class representing domain models.
- `B`: The UI Behavior class representing transient UI states (Loading, Success, Error).

```dart
class CartViewModel extends Duet<CartData, CartUiBehavior> {
  CartViewModel()
      : super(
          initialData: const CartData(items: []),
          initialBehavior: const CartUiIdle(),
        );

  void addItem(CartItem item) {
    emitData(data.copyWith(items: [...data.items, item]));
  }
}
```

---

## 2. Explicit shared state (`Duets.shared`)

Use `Duets.shared<T>()` only when state intentionally belongs to several
screens or an application flow. The registry owns one reference until
`Duets.reset<T>()` or `Duets.resetAll()` is called:

```dart
final auth = Duets.shared<AuthViewModel>(AuthViewModel.new);
final cart = Duets.shared<CartViewModel>(CartViewModel.new);

// Optional keys create independent intentional shared instances.
final account = Duets.shared<AccountDuet>(
  () => AccountDuet(accountId),
  key: accountId,
);
```

For local state, instantiate the Duet in `DuetView.bindDuet` or provide it
through `DuetScope`. The legacy `getDuet`, `getVM`, `context.duet`, and
`context.getVM` APIs are deprecated and will be removed in 2.0.0.

---

## 3. `DuetScope` & Context Extensions

`DuetScope` binds a Duet instance down the widget subtree. Subtree widgets can query it in $O(1)$ time using `context.duetOf<T>()`:

```dart
DuetScope<CartViewModel>(
  viewModel: cartVM,
  child: const CartBody(),
)

// Inside CartBody:
final cartVM = context.duetOf<CartViewModel>();
```

---

## 4. `DuetView` & `DuetStateMixin`

- **`DuetView<VM>`**: Base `StatefulWidget` for screen components, automatically managing `bindDuet()`, scope injection, and autoDispose reference counting.
- **`DuetStateMixin`**: Mixin for custom `StatefulWidget` classes requiring local state management.

```dart
class ProfileScreen extends DuetView<ProfileViewModel> {
  const ProfileScreen({super.key});

  @override
  ProfileViewModel bindDuet() => ProfileViewModel();

  @override
  Widget build(BuildContext context, ProfileViewModel duet) {
    return Scaffold(appBar: AppBar(title: Text(duet.data.name)));
  }
}
```

---

## 5. Selective Rebuilding: `DuetBuilder` & `DuetSelector`

- **`DuetBuilder<D, B>`**: Rebuilds when data or behavior updates.
- **`DuetSelector<VM, T>`**: Rebuilds ONLY when the extracted property `T` changes.

```dart
DuetSelector<CartViewModel, int>(
  selector: (vm) => vm.data.items.length,
  builder: (context, count) => Text("Items ($count)"),
)
```

---

## 6. One-Shot Side-Effect Listeners: `DuetListener` & `DuetBehaviorListener`

Listen for side effects (Toasts, SnackBars, Navigation) without rebuilding the UI tree:

```dart
DuetBehaviorListener<CartData, CartUiBehavior>(
  listener: (context, behavior) {
    if (behavior is CartUiSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(behavior.message)));
    }
  },
  child: const CartScreenBody(),
)
```
