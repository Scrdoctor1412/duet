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

These are architectural characteristics, not universal benchmark results.
Measure the actual application workload on its target devices and Flutter SDK.

| Metric | `duet` | BLoC | Riverpod | GetX |
| :--- | :--- | :--- | :--- | :--- |
| **Listener dispatch** | Synchronous, O(N listeners) | Stream/subscription dependent | Provider-graph dependent | Rx-subscription dependent |
| **Primary lookup** | O(1) HashMap or exact typed scope; legacy fallback scans ancestors | Inherited context | Provider container/graph | Global HashMap |
| **Base machinery** | Two notifiers and one broadcast event stream per Duet | Stream/state machinery | Provider nodes | Rx/proxy machinery |
| **Selective rebuild** | `DuetSelector` / `DuetWatch` | `BlocSelector` | `.select()` | `Obx` |

---

## 3. Enterprise & Fintech Suitability

`duet` is uniquely suited for enterprise applications (Banking, E-commerce, Fintech) due to:
1. **Small dependency surface**: Duet depends only on the Flutter SDK. This reduces, but does not eliminate, application supply-chain and upgrade risk.
2. **Dual-Notifier Reliability**: Prevents data loss and screen flickering during banking transaction reloads.
3. **Parametric Key Isolation**: Isolates user session states safely using object keys.
