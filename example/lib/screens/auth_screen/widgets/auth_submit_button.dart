import 'package:flutter/material.dart';
import 'package:duet/duet.dart';
import 'package:duet_example/screens/auth_screen/auth_viewmodel.dart';
import 'package:duet_example/screens/auth_screen/states/auth_state.dart';

class AuthSubmitButton extends StatelessWidget {
  final AuthViewModel? viewModel;
  final VoidCallback onPressed;

  const AuthSubmitButton({
    super.key,
    this.viewModel,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return DuetSelector<AuthViewModel, bool>.ui(
      viewModel: viewModel,
      selector: (vm) => vm.ui is AuthUiLoading,
      builder: (context, isLoading) {
        return SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            onPressed: isLoading ? null : onPressed,
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : const Text(
                    "    ng Nh   p",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        );
      },
    );
  }
}
