import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

sealed class MyTestScreenUIState {
  const MyTestScreenUIState();
  const factory MyTestScreenUIState.init() = MyTestScreenUIInitState;
}

final class MyTestScreenUIInitState extends MyTestScreenUIState {
  const MyTestScreenUIInitState();
}

final class MyTestScreenUiLoading extends MyTestScreenUIState {
  const MyTestScreenUiLoading();
}

@immutable
class MyTestScreenDataState {
  final int counter;

  const MyTestScreenDataState({required this.counter});

  MyTestScreenDataState copyWith({int? counter}) {
    return MyTestScreenDataState(
      counter: counter ?? this.counter,
    );
  }
}
