import 'package:flutter/material.dart';
import 'package:duet/duet.dart';
import 'package:duet_example/screens/auth_screen/auth_viewmodel.dart';
import 'package:duet_example/screens/auth_screen/states/auth_state.dart';

class AuthErrorBanner extends StatelessWidget {
  final AuthViewModel? viewModel;

  const AuthErrorBanner({
    super.key,
    this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return DuetSelector<AuthViewModel, String?>.ui(
      viewModel: viewModel,
      selector: (vm) => switch (vm.ui) {
        AuthUiError(:final message) => message,
        _ => null,
      },
      builder: (context, errorMessage) {
        if (errorMessage == null) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    errorMessage,
                    style: TextStyle(
                      color: Colors.red.shade800,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
