class AuthData {
  final bool isAuthenticated;
  final bool isInitializing;
  final String? token;
  final String? email;
  final String? name;

  const AuthData({
    this.isAuthenticated = false,
    this.isInitializing = true,
    this.token,
    this.email,
    this.name,
  });

  AuthData copyWith({
    bool? isAuthenticated,
    bool? isInitializing,
    String? token,
    String? email,
    String? name,
  }) {
    return AuthData(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isInitializing: isInitializing ?? this.isInitializing,
      token: token ?? this.token,
      email: email ?? this.email,
      name: name ?? this.name,
    );
  }
}

sealed class AuthUiBehavior {
  const AuthUiBehavior();

  factory AuthUiBehavior.idle() = AuthUiIdle;
  factory AuthUiBehavior.loading() = AuthUiLoading;
  factory AuthUiBehavior.error(String message) = AuthUiError;
  factory AuthUiBehavior.success() = AuthUiSuccess;
}

class AuthUiIdle extends AuthUiBehavior {
  const AuthUiIdle();
}

class AuthUiLoading extends AuthUiBehavior {
  const AuthUiLoading();
}

class AuthUiError extends AuthUiBehavior {
  final String message;
  const AuthUiError(this.message);
}

class AuthUiSuccess extends AuthUiBehavior {
  const AuthUiSuccess();
}
