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

// 1. Define State
class CounterData {
  final int count;
  const CounterData({required this.count});
}

// 2. Define Duet ViewModel
class CounterViewModel extends Duet<CounterData, UiState> {
  CounterViewModel()
      : super(
          initialData: const CounterData(count: 0),
          initialBehavior: const UiIdle(),
        );

  void increment() {
    emitData(CounterData(count: data.count + 1));
  }
}

// 3. Define DuetView
class CounterScreen extends DuetView<CounterViewModel> {
  const CounterScreen({super.key});

  @override
  CounterViewModel bindDuet() => CounterViewModel();

  @override
  Widget build(BuildContext context, CounterViewModel duet) {
    return Scaffold(
      appBar: AppBar(title: const Text('Duet Counter')),
      body: Center(
        child: DuetBuilder<CounterData, UiState>(
          builder: (context, data) => Text('Count: ${data.count}'),
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
- [Overview](docs/overview.md)
- [Core Concepts](docs/core_concepts.md)
- [Best Practices](docs/best_practices.md)
- [Architecture Comparison](docs/architecture_comparison.md)
- [Technical Document](docs/duet_technical_doc.md)
