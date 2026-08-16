# Next

- Deprecated the legacy `getDuet`, `getVM`, `context.duet`, and
  `context.getVM` service-locator APIs. Use `Duets.shared` for intentionally
  shared state and `DuetView`/`DuetScope` for local state. The deprecated APIs
  remain functional until 2.0.0.
- Migrated the example and documentation to the explicit ownership APIs.

# 1.1.0

- Added `SimpleDuet<D>` with built-in `UiState` lifecycle and async helpers.
- Added ViewModel-first `DuetWatch<VM>` data, UI, and combined builders.
- Added instance-bound `watchData`, `watchUi`, `watchBoth`, `selectData`,
  `selectUi`, and `listen` Flutter helpers.
- Added `DuetView.onDuetReady` for lifecycle-owned initial loading.
- Added the intentional `Duets.shared/find/contains/reset` service locator for
  state shared across screens without requiring `BuildContext`.
- Added `UiState` factories and optional loading/success/error payloads while
  preserving support for external custom subclasses.
- Fixed global `DuetView` binding so its factory is not evaluated twice.
- Improved nested batching, direct-emission observer coverage, nullable atomic
  emission, registry cleanup, and runtime ViewModel replacement handling.
- Added an explicit latest-wins async policy for search, refresh, and filtering.
- Fixed `DuetConsumer` subscriptions and reference counts when dependencies
  change at runtime.
- Fixed shared registry reset so mounted consumers can safely finish their
  lifecycle before the old instance is disposed.
- Added `emitPatch` to atomically update nullable data or UI channels.
- Clarified the O(1) exact-scope path versus the legacy ancestor fallback.
- Removed the direct `meta` dependency; Duet now depends only on Flutter SDK.

# 1.0.0

- Initial release of `duet` package.
- Features:
  - `Duet<D, B>` dual-notifier state management (Data & UI Behavior separation).
  - `getDuet<T>()` lazy service locator with parametric `key:` scoping.
  - `DuetScope` O(1) context-based widget tree scoping.
  - `DuetView` & `DuetStateMixin` scoped view components with autoDispose reference counting.
  - `DuetBuilder`, `DuetSelector`, `DuetListener`, `DuetBehaviorListener` reactive widgets.
  - Zero external third-party dependencies (100% Flutter Native).
