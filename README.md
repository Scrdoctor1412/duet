# Duet

A lightweight Flutter state-management library that keeps durable business
data separate from transient UI behavior.

Duet is built on Flutter's `ValueNotifier` and gives each feature two focused
reactive channels:

- **Data** — the information your screen renders, such as a profile, cart, or
  list of products.
- **UI state** — the status of an operation, such as idle, loading, success, or
  failure.

This separation lets a loading indicator update without rebuilding the data
view, and keeps one-shot actions such as navigation out of persistent state.

## Highlights

- Progressive API: start with `SimpleDuet<D>` and move to `Duet<D, B>` only
  when a feature needs domain-specific UI states.
- Fine-grained rebuilding for data, UI state, both channels, or one selected
  value.
- Built-in async lifecycle helpers and a latest-request-wins policy.
- One-shot effects for snackbars, dialogs, analytics, and navigation.
- Screen scoping and reference-counted lifecycle management.
- Intentional lazy registry for state shared across screens.
- No runtime dependencies beyond the Flutter SDK.

## Installation

```shell
flutter pub add duet
```

Or add Duet to `pubspec.yaml`:

```yaml
dependencies:
  duet: ^1.1.0
```

Then import its public API:

```dart
import 'package:duet/duet.dart';
```

Duet requires Dart 3.0+ and Flutter 3.0+.

## Quick start

For most screens, one `SimpleDuet` class is enough:

```dart
class CounterDuet extends SimpleDuet<int> {
  CounterDuet() : super(initialData: 0);

  void increment() => emitData(data + 1);
}
```

Bind it to a `DuetView`. The view owns the instance, provides it to descendants,
and releases it automatically:

```dart
class CounterScreen extends DuetView<CounterDuet> {
  const CounterScreen({super.key});

  @override
  CounterDuet bindDuet() => CounterDuet();

  @override
  Widget build(BuildContext context, CounterDuet duet) {
    return Scaffold(
      appBar: AppBar(title: const Text('Duet counter')),
      body: Center(
        child: duet.watchData(
          builder: (context, count) => Text(
            '$count',
            style: Theme.of(context).textTheme.displayMedium,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: duet.increment,
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

State-changing methods are protected, so widgets call intent-based methods
such as `increment()` instead of writing to notifiers directly.

## Async data

`SimpleDuet` includes the standard `UiIdle`, `UiLoading`, `UiSuccess`, and
`UiError` lifecycle. `runData` replaces the current data when a task succeeds,
preserves old data while loading, and converts failures to `UiError`:

```dart
class ProductsDuet extends SimpleDuet<List<Product>> {
  ProductsDuet(this.repository) : super(initialData: const []);

  final ProductsRepository repository;

  Future<void> load() async {
    await runData(repository.fetchProducts);
  }
}
```

Start initial work in `onDuetReady`, after the view has retained its Duet:

```dart
@override
void onDuetReady(ProductsDuet duet) => duet.load();
```

Render data and operation state independently:

```dart
Stack(
  children: [
    duet.watchData(
      builder: (context, products) => ProductList(products: products),
    ),
    duet.watchUi(
      builder: (context, state) => switch (state) {
        UiLoading() => const Center(child: CircularProgressIndicator()),
        UiError(message: final message) => ErrorView(message: message),
        _ => const SizedBox.shrink(),
      },
    ),
  ],
)
```

When a result must be combined with existing data, use `runTask` and `reduce`:

```dart
await runTask<Product>(
  task: () => repository.createProduct(draft),
  reduce: (products, created) => [...products, created],
);
```

For search, filtering, refresh, or changing route parameters, use
`runLatestData` (or `runLatest`). A slower previous request may finish, but only
the newest invocation can commit state:

```dart
Future<void> search(String query) async {
  await runLatestData(() => repository.search(query));
}
```

## Rebuild only what changed

The instance-bound helpers are the shortest API inside a `DuetView`:

| Helper | Rebuilds when |
| --- | --- |
| `duet.watchData(...)` | Business data changes |
| `duet.watchUi(...)` | UI state changes |
| `duet.watchBoth(...)` | Either channel changes |
| `duet.selectData(...)` | A selected data value changes |
| `duet.selectUi(...)` | A selected UI value changes |

Use a selector for widgets that depend on one derived value:

```dart
duet.selectData<int>(
  select: (cart) => cart.items.length,
  builder: (context, count) => Badge(label: Text('$count')),
)
```

When a concrete instance is not available, scoped widgets provide the same
capabilities:

```dart
DuetWatch<CartDuet>.data(
  builder: (context, duet) => CartTotal(value: duet.data.total),
)

DuetSelector<CartDuet, int>(
  selector: (duet) => duet.data.items.length,
  builder: (context, count) => Text('$count items'),
)
```

Both widgets resolve the nearest matching `DuetScope`. You can also pass
`viewModel:` explicitly.

### What a state update costs

Duet deliberately uses Flutter's synchronous `ValueNotifier` dispatch. Updating
one channel visits that channel's listeners in O(N). Every `DuetSelector` on the
channel evaluates its selector, but calls `setState` only when its selected value
changes. Keep selectors cheap and place reactive widgets close to the UI that
actually changes.

`batch()` and `emit(data: ..., ui: ...)` reduce notification dispatch and
selector evaluation for synchronous groups of updates. They do not remove state
construction work, and notification count is not widget-build count: Flutter
may coalesce repeated `setState` calls before the next frame.

Validate performance in profile mode on target devices. See the
[performance guide](doc/en/performance.md) for the measurement protocol and how
to interpret build, raster, P95, worst-frame, and selector metrics.

## One-shot effects

Snackbars, dialogs, and navigation are events rather than durable state. Emit
them once and listen from the UI:

```dart
sealed class CheckoutEffect {
  const CheckoutEffect();
}

final class CheckoutCompleted extends CheckoutEffect {
  const CheckoutCompleted();
}

class CheckoutDuet extends SimpleDuet<Cart> {
  CheckoutDuet() : super(initialData: const Cart());

  Future<void> submit() async {
    // Complete the operation, then notify active listeners once.
    emitEffect(const CheckoutCompleted());
  }
}
```

```dart
duet.listen<CheckoutCompleted>(
  onEffect: (context, effect) {
    Navigator.of(context).pushReplacementNamed('/orders');
  },
  child: const CheckoutBody(),
)
```

Effects are broadcast to active listeners and are not replayed to widgets that
mount later.

## Shared state across screens

Keep local state local. When state genuinely belongs to several routes or an
entire flow, expose a deliberate shared dependency:

```dart
abstract final class AppDuets {
  static CartDuet get cart => Duets.shared<CartDuet>(CartDuet.new);
  static SessionDuet get session =>
      Duets.shared<SessionDuet>(SessionDuet.new);
}
```

Each access returns the same lazily-created instance. The registry owns it, so
it remains alive while screens mount and unmount:

```dart
final cart = AppDuets.cart;
final sameCart = AppDuets.cart;

assert(identical(cart, sameCart));
```

Dispose shared state explicitly at its application boundary:

```dart
Duets.reset<CartDuet>();

// Useful for logout and test cleanup:
Duets.resetAll();
```

Optional `key:` values allow several intentional shared instances of the same
Duet type.

### Migrating from the legacy service locator

`getDuet`, `getVM`, `context.duet`, and `context.getVM` are deprecated and will
be removed in 2.0.0. Replace intentional global or cross-screen lookups with
`Duets.shared`:

```dart
// Before
final cart = getDuet(CartDuet.new);

// After
final cart = Duets.shared<CartDuet>(CartDuet.new);
```

For screen-local state, create the instance in `DuetView.bindDuet` or pass an
existing instance through `DuetScope`; do not replace local state with a shared
registry entry. New code should not override `isGlobal` when it uses
`Duets.shared`, because the registry itself owns the shared lifetime.

## Advanced: custom UI workflows

Use the full `Duet<D, B>` API when the UI state is part of the feature domain,
for example OTP verification, checkout, or a multi-step approval flow:

```dart
sealed class PaymentUi {
  const PaymentUi();
}

final class PaymentIdle extends PaymentUi {
  const PaymentIdle();
}

final class PaymentAuthorizing extends PaymentUi {
  const PaymentAuthorizing();
}

final class PaymentDeclined extends PaymentUi {
  const PaymentDeclined(this.reason);

  final String reason;
}

class PaymentDuet extends Duet<PaymentData, PaymentUi> {
  PaymentDuet()
      : super(
          initialData: const PaymentData(),
          initialBehavior: const PaymentIdle(),
        );

  void beginAuthorization() => emitUi(const PaymentAuthorizing());
}
```

Use `emit(data: ..., ui: ...)` to update both channels in one transaction. For
nullable channel types, `emitPatch` distinguishes an omitted channel from an
explicit `null` value.

## API guide

| Need | Recommended API |
| --- | --- |
| Standard idle/loading/success/error screen | `SimpleDuet<D>` |
| Domain-specific behavior workflow | `Duet<D, B>` |
| Own and scope a Duet for a screen | `DuetView<VM>` |
| Add Duet lifecycle to an existing `State` | `DuetStateMixin<W, VM>` |
| Provide an existing instance to descendants | `DuetScope<VM>` |
| Rebuild from one or both channels | `DuetWatch<VM>` / `DuetBuilder<D, B>` |
| Rebuild from a derived value | `DuetSelector<VM, T>` |
| Handle a one-shot event | `DuetListener<VM, E>` / `duet.listen<E>` |
| Share state intentionally across screens | `Duets.shared<T>` |

## Testing

A Duet is a plain Dart object, so business logic can be tested without pumping
a widget:

```dart
test('increment updates the count', () {
  final duet = CounterDuet();

  duet.increment();

  expect(duet.data, 1);
  duet.dispose();
});
```

Clear the registry between tests that use shared state:

```dart
tearDown(Duets.resetAll);
```

## Practical guidelines

- Keep data immutable and emit a new value instead of mutating in place.
- Expose intent methods from a Duet; keep emission details inside it.
- Keep server data visible during loading and failure when possible.
- Use selectors for small widgets that depend on one derived value.
- Use effects for one-time actions, not persistent data or UI state.
- Start with screen-scoped state and introduce `Duets.shared` only at a real
  cross-screen boundary.
- Avoid starting asynchronous work in a constructor; use `onDuetReady`.

## Documentation

- [Documentation hub](doc/README.md)
- [English guide](doc/en/README.md)
- [Vietnamese guide](doc/vi/README.md)
- [Progressive API](doc/en/simple_api.md)
- [Core concepts](doc/en/core_concepts.md)
- [Best practices](doc/en/best_practices.md)
- [Performance measurement](doc/en/performance.md)
- [Architecture and internals](doc/en/duet_technical_doc.md)
- [Example application](example/)

## License

Duet is available under the [MIT License](LICENSE).
