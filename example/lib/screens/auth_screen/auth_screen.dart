import 'package:flutter/material.dart';
import 'package:duet/duet.dart';
import 'package:duet_example/screens/auth_screen/auth_viewmodel.dart';
import 'package:duet_example/screens/auth_screen/states/auth_state.dart';
import 'package:duet_example/screens/auth_screen/widgets/auth_error_banner.dart';
import 'package:duet_example/screens/auth_screen/widgets/auth_header_widget.dart';
import 'package:duet_example/screens/auth_screen/widgets/auth_submit_button.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with DuetStateMixin<AuthScreen, AuthViewModel> {
  final _emailController = TextEditingController(text: "demo@antigravity.vn");
  final _passwordController = TextEditingController(text: "123456");
  bool _obscurePassword = true;

  @override
  AuthViewModel bindDuet() => Duets.shared<AuthViewModel>(AuthViewModel.new);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return buildScope(
      DuetBehaviorListener<AuthData, AuthUiBehavior>(
        listener: (context, behavior) {
          if (behavior is AuthUiSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("    ng nh   p th  nh c  ng!"),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
        child: Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context)
                      .colorScheme
                      .primaryContainer
                      .withValues(alpha: 0.6),
                  Theme.of(context).colorScheme.surface,
                ],
              ),
            ),
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(28.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Header Widget
                          const AuthHeaderWidget(),
                          const SizedBox(height: 24),

                          //      Selective Duet Error Banner
                          const AuthErrorBanner(),

                          // Email input
                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: "Email",
                              prefixIcon: const Icon(Icons.email_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Theme.of(context).colorScheme.surface,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Password input
                          TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: "M   t kh   u",
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Theme.of(context).colorScheme.surface,
                            ),
                          ),
                          const SizedBox(height: 24),

                          //      Selective Duet Submit Button
                          AuthSubmitButton(
                            onPressed: () {
                              duet.login(
                                _emailController.text,
                                _passwordController.text,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
