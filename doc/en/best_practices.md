# 🎯 Best Practices & Production Guidelines

## 1. Preventing UI Flickering (No UI Flickering)

When reloading data in a screen, do NOT emit an empty data state. Keep the existing `Data` intact while switching `UiBehavior` to `Loading`:

```dart
Future<void> reloadData() async {
  // Retain existing data while changing UI behavior to loading
  emitBehavior(const ProductUiLoading());
  
  final newProducts = await repository.fetchProducts();
  
  // Atomically update both data and behavior using emit()
  emit(
    data: ProductData(products: newProducts),
    ui: const ProductUiSuccess(),
  );
}
```

---

## 2. Using Atomic `emit(data: ..., ui: ...)`

To prevent intermediate rebuilds and **Reactive Glitch**, update both Data and UI Behavior in a single call:

```dart
// ✅ Correct
emit(
  data: data.copyWith(name: newName),
  ui: ProfileUiSuccess("Profile updated successfully"),
);
```

---

## 3. Immutability Guidelines

Always use immutable data structures for `Data` and `UiBehavior` classes. Use `copyWith` methods or packages like `freezed` to enforce data safety:

`ValueNotifier` compares the old and new values with `==`. A new instance that
is value-equal to the previous state does not notify listeners. Mutating a list
inside the existing state and assigning that same state again can therefore
leave the UI unchanged.

```dart
@immutable
class UserData {
  final String id;
  final String name;
  const UserData({required this.id, required this.name});

  UserData copyWith({String? name}) => UserData(id: id, name: name ?? this.name);
}
```

---

## 4. Selectors, batching, and rebuilds

- Every notification evaluates every `DuetSelector` subscribed to that channel.
- Only selectors whose selected result changes call `setState`.
- Keep selectors O(1); do not sort, filter, parse, or perform I/O in them.
- `batch()` reduces notification dispatch and selector evaluation, but it does
  not remove the cost of constructing intermediate state objects.
- Notification count is not widget-build count. Flutter may coalesce repeated
  synchronous `setState` calls before the next frame.

Use the [performance guide](performance.md) to measure jank in profile mode.

---

## 5. Unit Testing Guidelines

Testing a `Duet` class requires zero Flutter widget dependencies. Test your business logic directly in pure Dart:

```dart
void main() {
  tearDown(() {
    DuetRegistry.resetAll();
  });

  test('CounterViewModel increments count correctly', () {
    final vm = CounterViewModel();
    expect(vm.data.count, equals(0));

    vm.increment();
    expect(vm.data.count, equals(1));
  });
}
```
