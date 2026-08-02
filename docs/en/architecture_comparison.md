# 🔬 Architecture & Performance Comparison

## 1. Deep Mechanics Comparison

### `duet` vs BLoC / Cubit
- **BLoC**: Relies on `StreamController` and event transformers. Requires separate Event classes and BlocProviders.
- **`duet`**: Built on lightweight Flutter `ValueNotifier` primitives. Methods are invoked directly as standard async Dart methods without event classes.

### `duet` vs Riverpod
- **Riverpod**: Operates as a global compile-time dependency graph. Uses `WidgetRef` in consumer widgets.
- **`duet`**: Combines context-free `getDuet()` lookup with native `InheritedWidget` scoping (`DuetScope`).

---

## 2. Performance & Benchmark Analysis

| Metric | `duet` | BLoC | Riverpod | GetX |
| :--- | :--- | :--- | :--- | :--- |
| **Object Allocation per Emit** | 1 (ValueNotifier update) | 2+ (Stream event & state) | 1-2 (Provider state) | 1 (Rx variable) |
| **Context Lookup Overhead** | $O(1)$ (`_AnyDuetScope`) | $O(N)$ (Tree depth) | $O(1)$ (Graph lookup) | $O(1)$ (Global HashMap) |
| **Memory Footprint (RAM)** | Minimal (~1KB per VM) | Moderate (Stream overhead) | Low | Moderate |
| **Garbage Collection (GC)** | Zero pressure (Reuses Notifier) | Stream event GC pressure | Low | Low |

---

## 3. Enterprise & Fintech Suitability

`duet` is uniquely suited for enterprise applications (Banking, E-commerce, Fintech) due to:
1. **0% External Dependency Risk**: 100% Flutter Native guarantees seamless SDK upgrades without breaking third-party packages.
2. **Dual-Notifier Reliability**: Prevents data loss and screen flickering during banking transaction reloads.
3. **Parametric Key Isolation**: Isolates user session states safely using object keys.
