# 📖 Overview & Architecture Philosophy

## 1. Design Philosophy

Most state management libraries today fall into one of two extremes:
- **Too Verbose:** Like BLoC, forcing developers to write boilerplate `Event`, `State`, `BlocProvider` classes, expanding file count by 3x.
- **Too "Magic" & Closed:** Like GetX, replacing Flutter's native Navigator, SnackBar, and Dialogs, leading to brittle code during Flutter SDK upgrades.

**`duet`** was created with a clear philosophy:
> **"100% Native Flutter — Pure Freedom — Memory Efficient — Absolute Safety."**

---

## 2. The 5 Core Pillars of `duet`

```text
┌────────────────────────────────────────────────────────────────────────┐
│                          DUET ARCHITECTURE                             │
├────────────────────────────────────────────────────────────────────────┤
│ 1. DUAL-NOTIFIER STATE    : Separate DataState & UIBehaviorState       │
│ 2. HYBRID SCOPING        : Contextless (getDuet) or Tree Scoped (DuetScope)│
│ 3. PARAMETRIC KEY        : Differentiate Instances via Keys (key: id)  │
│ 4. REFERENCE COUNTING    : Automatic RAM Cleanup (autoDispose)         │
│ 5. DART 3 SEALED CLASS   : Compile-Time Safety with Pattern Matching   │
└────────────────────────────────────────────────────────────────────────┘
```

### 🔹 Pillar 1: Dual-Notifier State (Data & Behavior Separation)
`Duet<D, B>` manages two separate `ValueNotifier` instances:
- `dataNotifier`: Manages business data `D` (e.g. product list, user profile).
- `behaviorNotifier`: Manages UI state `B` (e.g. `UiIdle`, `UiLoading`, `UiError`).
*Benefit:* Prevents old UI data from disappearing during reload operations (No UI Flickering).

### 🔹 Pillar 2: Hybrid Scoping (Context-Free or Context-Bound)
- **Without `BuildContext`:** Use `getDuet(() => MyViewModel())` to obtain a Duet instance anywhere (Service, Repository, UI).
- **With `BuildContext`:** Use `DuetScope` and `context.duetOf<MyViewModel>()` when scoping by the Widget Tree.

### 🔹 Pillar 3: Parametric Scoping (`key: Object?`)
Create multiple independent instances of the same Duet class on the same screen without magic strings:
```dart
final vmA = getDuet(() => ProductItemViewModel(productA), key: productA.id);
final vmB = getDuet(() => ProductItemViewModel(productB), key: productB.id);
```

### 🔹 Pillar 4: Reference Counting AutoDispose
Automatically tracks the active listener count (`_refCount`) connected to a Duet. When the user exits the screen (`_refCount == 0`), the Duet disposes itself from memory automatically.

### 🔹 Pillar 5: Sealed Classes & Dart 3 Pattern Matching
Leverages Dart 3 `sealed` class hierarchies, ensuring compile-time exhaustiveness checks on all UI states (`switch (behavior)`).

---

## 3. General Feature Comparison

| Feature | `duet` | GetX | Riverpod | BLoC |
| :--- | :--- | :--- | :--- | :--- |
| **Infrastructure** | 100% Native (`ValueNotifier`) | Closed Ecosystem | Dependency Graph | Stream State Machine |
| **Contextless Lookup** | ✅ Yes (`getDuet()`) | ✅ Yes (`Get.find()`) | ❌ Requires `WidgetRef` | ❌ Requires `context.read()` |
| **Event Boilerplate** | ✅ None (Direct async methods) | ✅ None | ✅ None | ❌ Requires Event Classes |
| **Automatic AutoDispose** | ✅ Yes (Ref Counting) | 🟡 Semi-auto | ✅ Yes (`.autoDispose`) | ✅ Tree auto-dispose |
| **No UI Flickering** | ✅ Native Dual-Stream | ❌ Tricky | ✅ Yes (`previousData`) | ❌ Prone to blank UI |
| **Field Selector** | ✅ Yes (`DuetSelector`) | ✅ Yes (`Obx`) | ✅ Yes (`select`) | ✅ Yes (`BlocSelector`) |
| **Scoping Flexibility** | 🏆 Very High (Global/Key/Scope) | 🟡 String Tags | 🟢 High | 🔴 Tree-Bound |
