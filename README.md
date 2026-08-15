# 🚀 Duet

A lightweight, zero-dependency dual-notifier state management & service locator library for Flutter.

---

## ⚡ Quick Start

```yaml
dependencies:
  duet:
    path: ../
```

```dart
import 'package:flutter/material.dart';
import 'package:duet/duet.dart';

// Small and medium screens only need one class.
class CounterDuet extends SimpleDuet<int> {
  CounterDuet() : super(initialData: 0);

  void increment() {
    emitData(data + 1);
  }
}

class CounterScreen extends DuetView<CounterDuet> {
  const CounterScreen({super.key});

  @override
  CounterDuet bindDuet() => CounterDuet();

  @override
  Widget build(BuildContext context, CounterDuet duet) {
    return Scaffold(
      appBar: AppBar(title: const Text('Duet Counter')),
      body: Center(
        child: duet.watchData(
          builder: (context, count) => Text('Count: $count'),
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

---

## 📖 Documentation

For in-depth guides, technical architecture, and best practices, check the `docs/` folder:
- [Documentation Hub](docs/README.md)
- [Progressive API (Vietnamese)](docs/vi/simple_api.md)
- [Overview (English)](docs/en/overview.md)
- [Core Concepts (English)](docs/en/core_concepts.md)

## Shared state without `BuildContext`

Keep local state local, and register only state that genuinely belongs to
multiple screens:

```dart
abstract final class AppDuets {
  static CartDuet get cart => Duets.shared<CartDuet>(CartDuet.new);
}
```

Every access returns the same lazy instance:

```dart
final cart = AppDuets.cart; // creates once
final sameCart = AppDuets.cart; // returns the existing instance
```

The registry owns shared state between routes. Dispose it explicitly at an app
boundary such as logout:

```dart
Duets.reset<CartDuet>();
```
