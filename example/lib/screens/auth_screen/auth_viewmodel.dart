import 'package:duet_example/core/storage/auth_storage_service.dart';
import 'package:duet/duet.dart';
import 'package:duet_example/screens/auth_screen/states/auth_state.dart';

class AuthViewModel extends Duet<AuthData, AuthUiBehavior> {
  final AuthStorageService _storageService;

  AuthViewModel({AuthStorageService? storageService})
      : _storageService = storageService ?? AuthStorageService(),
        super(
          initialData: const AuthData(
            isAuthenticated: false,
            isInitializing: true,
          ),
          initialBehavior: const AuthUiIdle(),
        ) {
    checkAuthSession();
  }

  @override
  bool get autoDispose => false;

  @override
  bool get isGlobal => true;

  /// Check stored session on startup
  Future<void> checkAuthSession() async {
    final session = await _storageService.getSession();
    if (session != null) {
      emitData(
        AuthData(
          isAuthenticated: true,
          isInitializing: false,
          token: session.token,
          email: session.email,
          name: session.name,
        ),
      );
    } else {
      emitData(
        const AuthData(
          isAuthenticated: false,
          isInitializing: false,
        ),
      );
    }
  }

  Future<bool> login(String email, String password) async {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      emitBehavior(
        const AuthUiError(
            "Vui l  ng nh   p      y      ?Email v   M   t kh   u!"),
      );
      return false;
    }

    if (!email.contains('@')) {
      emitBehavior(const AuthUiError("Email kh  ng h   p l   ?"));
      return false;
    }

    if (password.length < 4) {
      emitBehavior(
          const AuthUiError("M   t kh   u ph   i c     t nh   t 4 k   t   ?"));
      return false;
    }

    emitBehavior(const AuthUiLoading());

    // Gi   ?l   p g   i API     ng nh   p
    await Future.delayed(const Duration(milliseconds: 1200));

    // T   o th  ng tin token & user
    final username = email.split('@').first;
    final displayName = username.isEmpty
        ? "Ng     i d  ng"
        : "${username[0].toUpperCase()}${username.substring(1)}";
    final token = "sec_tok_${DateTime.now().millisecondsSinceEpoch}";

    // L  u session v  o Secure Storage
    await _storageService.saveSession(
      token: token,
      email: email,
      name: displayName,
    );

    emit(
      data: AuthData(
        isAuthenticated: true,
        isInitializing: false,
        token: token,
        email: email,
        name: displayName,
      ),
      ui: const AuthUiSuccess(),
    );
    return true;
  }

  Future<void> logout() async {
    await _storageService.clearSession();
    emit(
      data: const AuthData(
        isAuthenticated: false,
        isInitializing: false,
      ),
      ui: const AuthUiIdle(),
    );
  }
}
