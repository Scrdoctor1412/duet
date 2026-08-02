# 1.0.0

- Initial release of `duet` package.
- Features:
  - `Duet<D, B>` dual-notifier state management (Data & UI Behavior separation).
  - `getDuet<T>()` lazy service locator with parametric `key:` scoping.
  - `DuetScope` O(1) context-based widget tree scoping.
  - `DuetView` & `DuetStateMixin` scoped view components with autoDispose reference counting.
  - `DuetBuilder`, `DuetSelector`, `DuetListener`, `DuetBehaviorListener` reactive widgets.
  - Zero external third-party dependencies (100% Flutter Native).
