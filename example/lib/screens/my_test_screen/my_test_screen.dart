import 'package:flutter/material.dart';
import 'package:duet/duet.dart';
import 'package:duet_example/screens/my_test_screen/my_test_viewmodel.dart';

class MyTestScreen extends DuetView<MyTestViewmodel> {
  static const route = '/MyTestScreen';
  const MyTestScreen({super.key});

  @override
  MyTestViewmodel bindDuet() => MyTestViewmodel();

  @override
  Widget build(BuildContext context, MyTestViewmodel duet) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Test Screen"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            DuetSelector<MyTestViewmodel, int>(
              selector: (vm) => vm.data.counter,
              builder: (context, value) {
                return Text(
                  "$value",
                  style: Theme.of(context).textTheme.headlineMedium,
                );
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: duet.increment,
              icon: const Icon(Icons.add),
              label: const Text("Increment"),
            ),
          ],
        ),
      ),
    );
  }
}
