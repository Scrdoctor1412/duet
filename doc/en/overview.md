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
│ 2. EXPLICIT OWNERSHIP    : Screen-local or intentionally shared state  │
│ 3. FLEXIBLE SCOPING      : DuetView, DuetScope, or Duets.shared        │
│ 4. REFERENCE COUNTING    : Automatic RAM Cleanup (autoDispose)         │
│ 5. DART 3 SEALED CLASS   : Compile-Time Safety with Pattern Matching   │
└────────────────────────────────────────────────────────────────────────┘
```

### 🔹 Pillar 1: Dual-Notifier State (Data & Behavior Separation)
`Duet<D, B>` manages two separate `ValueNotifier` instances:
- `dataNotifier`: Manages business data `D` (e.g. product list, user profile).
- `behaviorNotifier`: Manages UI state `B` (e.g. `UiIdle`, `UiLoading`, `UiError`).
*Benefit:* Prevents old UI data from disappearing during reload operations (No UI Flickering).

### 🔹 Pillar 2: Explicit Ownership
- **Screen-local state:** Create it in `DuetView.bindDuet` or provide it with `DuetScope`.
- **Shared state:** Use `Duets.shared` only for state intentionally shared across screens or a flow.

### 🔹 Pillar 3: Flexible Scoping
Optional keys create multiple intentional shared instances of the same type:
```dart
final first = Duets.shared<AccountDuet>(() => AccountDuet('a'), key: 'a');
final second = Duets.shared<AccountDuet>(() => AccountDuet('b'), key: 'b');
```

The legacy `getDuet`/`getVM` APIs are deprecated and will be removed in 2.0.0.

### 🔹 Pillar 4: Reference Counting AutoDispose
Automatically tracks the active listener count (`_refCount`) connected to a Duet. When the user exits the screen (`_refCount == 0`), the Duet disposes itself from memory automatically.

### 🔹 Pillar 5: Sealed Classes & Dart 3 Pattern Matching
Leverages Dart 3 `sealed` class hierarchies, ensuring compile-time exhaustiveness checks on all UI states (`switch (behavior)`).

---

## 3. General Feature Comparison

| Feature | `duet` | GetX | Riverpod | BLoC |
| :--- | :--- | :--- | :--- | :--- |
| **Infrastructure** | 100% Native (`ValueNotifier`) | Closed Ecosystem | Dependency Graph | Stream State Machine |
| **Explicit shared state** | ✅ Yes (`Duets.shared`) | ✅ Yes (`Get.find()`) | ✅ Provider container | ✅ Repository/provider |
| **Event Boilerplate** | ✅ None (Direct async methods) | ✅ None | ✅ None | ❌ Requires Event Classes |
| **Automatic AutoDispose** | ✅ Yes (Ref Counting) | 🟡 Semi-auto | ✅ Yes (`.autoDispose`) | ✅ Tree auto-dispose |
| **No UI Flickering** | ✅ Native Dual-Stream | ❌ Tricky | ✅ Yes (`previousData`) | ❌ Prone to blank UI |
| **Field Selector** | ✅ Yes (`DuetSelector`) | ✅ Yes (`Obx`) | ✅ Yes (`select`) | ✅ Yes (`BlocSelector`) |
| **Scoping Flexibility** | Local scope or keyed shared registry | String Tags | Provider scopes | Tree/provider scopes |
