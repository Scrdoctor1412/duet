# Measuring Duet Performance

Performance must be measured with the application's real widget tree, target
Flutter SDK, and target hardware. A fast listener microbenchmark does not prove
that a screen is jank-free, and a notification count is not a widget-build
count.

## Run in profile mode

```shell
flutter run --profile
```

Debug mode includes assertions, service extensions, and optional
`DuetObserver` logging. Release mode is representative for users but has fewer
inspection tools. Profile mode is the default choice for performance analysis.

## Measure three layers separately

### 1. Listener dispatch

Record elapsed time for a fixed number of state updates and listeners. Make the
run long enough to be measurable—prefer at least 100 ms or repeat the workload
and report the median. Empty callbacks characterize notifier overhead, not
application work.

### 2. Selectors and builds

Track both selector evaluations and builder invocations. If 60 selectors listen
to one data channel, all 60 selectors are evaluated on each notification. When
one selected field changes, only that selector should rebuild.

- High evaluations with low builds: split an overly broad state channel or make
  selectors cheaper if CPU time is material.
- High builds: move reactive widgets closer to the changing UI or select a
  smaller immutable value.

### 3. Frame timing

Use Flutter `FrameTiming` or DevTools Performance view and report:

- average build duration;
- average raster duration;
- average and P95 total frame time;
- worst frame as diagnostic context;
- frames over the target display budget.

The common 60 Hz budget is 16.67 ms. A 120 Hz display has an 8.33 ms budget, so
the same workload may pass at 60 Hz and miss frames at 120 Hz.

## Stable measurement protocol

1. Use a physical target device in profile mode.
2. Close unrelated heavy applications and keep thermal conditions comparable.
3. Warm up shaders and the tested screen for 30–60 frames.
4. Measure at least 300 frames for frame workloads.
5. Repeat the run five or more times.
6. Compare medians and P95 values; do not judge a change from one worst frame.
7. Keep Flutter version, device, display refresh rate, and workload identical
   when comparing state-management implementations.

Small sub-millisecond differences in short microbenchmarks are normally timer,
scheduler, CPU-frequency, or garbage-collection noise. Treat two runs as the
same performance class unless repeated measurements show a stable regression.

## Interpreting batching

`batch()` collapses pending notifications to one notification per changed Duet
channel. This reduces listener dispatch and selector evaluation. It does not
avoid reducer work or state allocations performed inside the batch. Prefer
computing the final state once and emitting once when that is practical.
