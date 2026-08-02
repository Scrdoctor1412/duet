import 'package:duet/duet.dart';
import 'package:duet_example/screens/my_test_screen/states/my_test_screen_state.dart';

class MyTestViewmodel
    extends Duet<MyTestScreenDataState, MyTestScreenUIState> {
  MyTestViewmodel()
    : super(
        initialBehavior: MyTestScreenUIState.init(),
        initialData: MyTestScreenDataState(counter: 0),
      );

  void increment() {
    emit(data: data.copyWith(counter: data.counter + 1));
  }
}
