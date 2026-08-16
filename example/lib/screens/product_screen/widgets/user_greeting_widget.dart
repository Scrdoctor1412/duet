import 'package:flutter/material.dart';
import 'package:duet/duet.dart';
import 'package:duet_example/screens/auth_screen/auth_viewmodel.dart';

class UserGreetingWidget extends StatelessWidget {
  final AuthViewModel? authVM;

  const UserGreetingWidget({
    super.key,
    this.authVM,
  });

  @override
  Widget build(BuildContext context) {
    final vm = authVM ?? Duets.shared<AuthViewModel>(AuthViewModel.new);
    //      Selective Listening: Rebuilds ONLY when auth name changes
    return DuetSelector<AuthViewModel, String>(
      viewModel: vm,
      selector: (vm) => vm.data.name ?? "Kh  ch",
      builder: (context, name) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Tech Store",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              "Xin ch  o, $name!",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        );
      },
    );
  }
}
