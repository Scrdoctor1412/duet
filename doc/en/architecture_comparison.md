# Architecture and Performance Comparison

This document compares Duet's architectural characteristics with Provider,
Riverpod, BLoC/Cubit, and GetX. It is not an absolute speed ranking. Real results
must be measured with the same widget tree, workload, Flutter SDK, and hardware.

## Duet mechanics

Each `Duet<D, B>` owns two independent `DuetValueNotifier` instances:

- `dataNotifier` holds durable business data;
- `behaviorNotifier` holds transient UI state;
- a broadcast event stream carries one-shot effects;
- reference counting manages the lifetime of widget-consumed instances.

When one channel changes, `ValueNotifier` synchronously dispatches to that
channel's listeners in O(N listeners). `DuetBuilder` and `DuetWatch` call
`setState` for notifications from their selected channels. `DuetSelector`
evaluates its selector on each notification but calls `setState` only when the
selected value changes.

Exact typed lookup through `DuetScope.of<VM>` uses Flutter's inherited-element
index. Pair-based `<D, B>` lookup retains an ancestor fallback for compatibility.
Intentional shared state uses a registry keyed by type and an optional key.

## Characteristic comparison

| Concern | Duet | Provider | Riverpod | BLoC/Cubit | GetX |
| --- | --- | --- | --- | --- | --- |
| Reactive core | Two `ValueNotifier`s | Commonly `ChangeNotifier`/`Listenable` | Provider dependency graph | State stream/subscription | Rx or explicit update |
| Update granularity | Data, UI, or selected value | Provider/selected value | Provider/selected dependency | State or selected value | Rx dependency or update ID |
| Lookup | Typed scope or explicit registry | Inherited provider | Provider container | `BlocProvider` | Global dependency registry |
| Async composition | Direct Dart methods and `SimpleDuet` helpers | Application-defined | Async provider primitives | Event/state pipeline | Controllers/workers |
| Lifecycle | Scope + reference counting | Provider ownership | Container + auto-dispose policies | Provider ownership | Binding/smart-management policies |
| Base machinery per unit | 2 notifiers + event stream | Depends on provider type | Provider nodes/dependencies | Bloc/Cubit + state stream | Rx/controller machinery |
| Selective rebuild | `DuetSelector` | `Selector`/`context.select` | `.select()` | `BlocSelector`/`buildWhen` | `Obx`/IDs |

These choices have different trade-offs. Duet prioritizes a small, synchronous,
traceable engine. Riverpod emphasizes dependency composition; BLoC emphasizes
event pipelines and governance; Provider stays close to Flutter primitives;
GetX emphasizes concise integrated APIs. The table alone cannot establish which
application is faster.

## Batching and widget builds

`batch()` collapses pending work to one notification per changed channel. It
reduces listener dispatch and selector evaluation but does not eliminate state
objects constructed inside the batch.

Notification count is not widget-build count. Flutter may coalesce repeated
synchronous `setState` calls before the next frame. A benchmark that only counts
`notifyListeners()` cannot claim the same reduction in widget builds or jank.

See [Measuring Duet Performance](performance.md) to measure dispatch, selectors,
and frame timing separately.

## Large-team considerations

- Duet depends only on Flutter SDK. This keeps its dependency surface small but
  does not remove supply-chain risk from the full application.
- `DuetObserver` and `DuetLogger` observe state and effects in debug mode. A
  production audit trail still needs application-owned transport, redaction,
  persistence, and security.
- Duet does not require an event class for every intent. Large teams should
  standardize public intent methods and coding conventions.
- Use `DuetView`/`DuetScope` for local ownership and `Duets.shared` only for
  intentional cross-screen state. Avoid legacy service-locator APIs in new code.
- Split state with different update frequencies or lifetimes into smaller Duets
  instead of one application-wide object.
