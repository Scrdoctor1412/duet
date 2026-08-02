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

## 4. Unit Testing Guidelines

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
