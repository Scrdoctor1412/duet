# 📜 Team Coding Conventions - DUET

> **Target Audience**: All team developers.  
> **Objective**: Standardize codebase patterns, prevent memory leaks, eliminate key collision bugs, and optimize UI render performance.

---

## 📋 4 Core Rules

### Rule 1: Every Screen = 1 `DuetView` (or `buildScope`)

At the root of every top-level screen component, use one of the two standard patterns:
- **Option A (Recommended for StatelessWidget/Screens)**: Extend `DuetView<MyViewModel>`.
- **Option B (Recommended for StatefulWidget with local state)**: Use mixin `with DuetStateMixin<MyScreen, MyViewModel>` and wrap child UI with `buildScope(...)`.

```dart
class ProfileScreen extends DuetView<ProfileViewModel> {
  const ProfileScreen({super.key});

  @override
  ProfileViewModel bindDuet() => ProfileViewModel();

  @override
  Widget build(BuildContext context, ProfileViewModel duet) {
    return Scaffold(appBar: AppBar(title: Text(duet.data.name)));
  }
}
```

---

### Rule 2: Child Widgets Should NOT Pass `viewModel:` Explicitly

Child widgets (`DuetBuilder`, `DuetSelector`, `DuetListener`) automatically locate the parent screen's Duet via `BuildContext`:

```dart
// ✅ Correct (Clean & Automatic Context Lookup)
DuetBuilder<ProfileData, ProfileUiBehavior>(
  builder: (context, data) => Text(data.name),
)
```

---

### Rule 3: Updating Dual State Must Use `emit(data: ..., ui: ...)`

To update Data and UI Behavior simultaneously without UI glitches, always use `emit()`:

```dart
emit(
  data: data.copyWith(name: newName),
  ui: const ProfileUiSuccess('Updated successfully!'),
);
```

---

### Rule 4: Screen Level vs Child Component Scoping

- **`DuetView` / `DuetStateMixin`**: Screen level components ONLY.
- **Child Widgets**: Do not instantiate new Duet instances; use `DuetBuilder` or `context.duetOf<MyViewModel>()`.

---

## 📊 Do's & Don'ts Checklist

| Action | Do | Don't |
| :--- | :--- | :--- |
| **New Screen** | Extend `DuetView<MyVM>` | Create a local Duet inside `build()` |
| **Reactive Widget** | Use `DuetBuilder<Data, Behavior>()` | Pass redundant `viewModel: duet` in child widgets |
| **Dual State Update** | Use `emit(data: ..., ui: ...)` | Call `emitData()` and `emitBehavior()` separately |
| **One-shot Events** | Use `DuetBehaviorListener` | Add manual listeners in `initState` |
| **Child VM Lookup** | Use `context.duetOf<MyVM>()` | Instantiate a duplicate ViewModel in the child |
