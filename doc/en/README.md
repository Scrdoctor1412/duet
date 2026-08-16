# 🚀 Duet Documentation (English)

Welcome to the official documentation for **`duet`** — a lightweight, zero-dependency dual-notifier state management package for Flutter Native.

---

## 📚 Table of Contents

1. 📖 **[Overview & Architecture Philosophy](overview.md)**
   - Design Philosophy
   - 5 Core Pillars of `duet`
   - Feature Comparison Matrix (BLoC, Riverpod, GetX)
2. 💡 **[Core Concepts & Guide](core_concepts.md)**
   - `Duet<D, B>` (Separating Data State & UI Behavior State)
   - `UiState` & Sealed Classes (Dart 3 Pattern Matching)
   - `Duets.shared()` (Intentional shared state with optional keys)
   - `DuetScope` & `context.duetOf` (Widget Tree Scoping)
   - `DuetBuilder` & `DuetSelector` (Selective Rebuilding)
   - `autoDispose` & Reference Counting
3. 🎯 **[Best Practices](best_practices.md)**
   - Preventing UI Flickering
   - Immutability & `freezed` integration
   - Memory Management & Unit Testing
4. 🔬 **[Architecture & Performance Comparison](architecture_comparison.md)**
   - Internal Mechanics Comparison
   - CPU, RAM, and GC Benchmarks
   - Enterprise & Fintech App Suitability
5. 📜 **[Team Conventions](conventions.md)**
   - 4 Core Coding Rules
   - Do's & Don'ts Checklist
6. 📖 **[Technical Report](duet_technical_doc.md)**
   - Step-by-step design, Reference Counting algorithm, and Glitch Prevention.

---

## ⚡ Quick Start

### Step 1: Define State with Sealed Classes (Dart 3)
```dart
import 'package:flutter/foundation.dart';
import 'package:duet/duet.dart';

@immutable
sealed class ProductUiBehavior {
  const ProductUiBehavior();

  factory ProductUiBehavior.idle() = ProductUiIdle;
  factory ProductUiBehavior.loading() = ProductUiLoading;
  factory ProductUiBehavior.success() = ProductUiSuccess;
  factory ProductUiBehavior.error(String message) = ProductUiError;
}

class ProductUiIdle extends ProductUiBehavior { const ProductUiIdle(); }
class ProductUiLoading extends ProductUiBehavior { const ProductUiLoading(); }
class ProductUiSuccess extends ProductUiBehavior { const ProductUiSuccess(); }
class ProductUiError extends ProductUiBehavior {
  final String message;
  const ProductUiError(this.message);
}

class ProductData {
  final List<String> products;
  final int totalCount;
  ProductData({required this.products, this.totalCount = 0});
}
```

### Step 2: Create ViewModel / Duet
```dart
import 'package:duet/duet.dart';

class ProductViewModel extends Duet<ProductData, ProductUiBehavior> {
  ProductViewModel()
      : super(
          initialData: ProductData(products: []),
          initialBehavior: const ProductUiIdle(),
        );

  Future<void> fetchProducts() async {
    if (behaviorState is ProductUiLoading) return;

    emitBehavior(const ProductUiLoading());
    try {
      await Future.delayed(const Duration(seconds: 1));
      final list = ["iPhone 15", "MacBook M3"];
      emitData(ProductData(products: list, totalCount: list.length));
      emitBehavior(const ProductUiSuccess());
    } catch (e) {
      emitBehavior(ProductUiError(e.toString()));
    }
  }
}
```

### Step 3: Build Safe & Clean UI
```dart
import 'package:flutter/material.dart';
import 'package:duet/duet.dart';

class ProductScreen extends DuetView<ProductViewModel> {
  const ProductScreen({super.key});

  @override
  ProductViewModel bindDuet() => ProductViewModel();

  @override
  Widget build(BuildContext context, ProductViewModel duet) {
    return Scaffold(
      appBar: AppBar(
        title: DuetSelector<ProductViewModel, int>(
          selector: (vm) => vm.data.totalCount,
          builder: (context, total) => Text("Products ($total)"),
        ),
      ),
      body: Stack(
        children: [
          DuetBuilder(
            builder: (context, data) {
              if (data.products.isEmpty) {
                return const Center(child: Text("Tap + to load products"));
              }
              return ListView.builder(
                itemCount: data.products.length,
                itemBuilder: (ctx, i) => ListTile(title: Text(data.products[i])),
              );
            },
          ),
          DuetBuilder.ui(
            builder: (context, behavior) {
              return switch (behavior) {
                ProductUiLoading() => const Center(child: CircularProgressIndicator()),
                ProductUiError(message: final msg) => Center(child: Text("Error: $msg")),
                ProductUiIdle() || ProductUiSuccess() => const SizedBox.shrink(),
              };
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: duet.fetchProducts,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
```
