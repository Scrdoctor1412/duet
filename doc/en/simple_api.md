# Progressive Simple API

Duet keeps its dual-notifier architecture: durable business data remains
separate from transient UI behavior. The progressive API only hides types and
states that small screens should not have to define themselves.

| Need | Recommended API |
| --- | --- |
| Local toggle, tab, or animation state | Flutter `StatefulWidget` or `ValueNotifier` |
| Small/medium screen with idle, loading, success, and error | `SimpleDuet<D>` |
| Domain-specific behavior workflow | `Duet<D, B>` |

```dart
class CounterDuet extends SimpleDuet<int> {
  CounterDuet() : super(initialData: 0);

  void increment() => emitData(data + 1);
}

duet.watchData(
  builder: (context, count) => Text('$count'),
)
```

Inside a `DuetView`, pass the bound `duet` instance to child widgets and use
`watchData`, `watchUi`, `watchBoth`, `selectData`, and `listen`. This keeps the
dependency explicit without looking it up through `BuildContext`.

Use `runData()` when a task result replaces data, or `runTask()` with a
`reduce` callback when it should be combined with current data. Both preserve
old data during loading and failure. Successful data and status changes are
committed in one transaction.

For search, refresh, filtering, or route-parameter changes, use `runLatest()`
or `runLatestData()`. Only the newest invocation may commit state, so a slower
old request cannot overwrite a newer result. Use `cancelLatest()` when the
current result should be ignored without starting another request.

For nullable full Duets, `emitPatch()` distinguishes an omitted channel from
an explicit `null` while keeping updates atomic:

```dart
emitPatch(data: const DuetChange(null));
```

Use the full `Duet<D, B>` API when UI behavior is part of the feature domain,
for example OTP verification, approval, or payment processing phases.
