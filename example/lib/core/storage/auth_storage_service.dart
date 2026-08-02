import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserSession {
  final String token;
  final String email;
  final String name;

  const UserSession({
    required this.token,
    required this.email,
    required this.name,
  });
}

class AuthStorageService {
  static const _keyToken = 'auth_token';
  static const _keyEmail = 'auth_email';
  static const _keyName = 'auth_name';

  final FlutterSecureStorage _storage;

  AuthStorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  /// Save user session into secure storage
  Future<void> saveSession({
    required String token,
    required String email,
    required String name,
  }) async {
    await _storage.write(key: _keyToken, value: token);
    await _storage.write(key: _keyEmail, value: email);
    await _storage.write(key: _keyName, value: name);
  }

  /// Retrieve existing session from secure storage
  Future<UserSession?> getSession() async {
    try {
      final token = await _storage.read(key: _keyToken);
      final email = await _storage.read(key: _keyEmail);
      final name = await _storage.read(key: _keyName);

      if (token != null && token.isNotEmpty && email != null && name != null) {
        return UserSession(token: token, email: email, name: name);
      }
    } catch (e) {
      // In case of platform specific storage read error, fallback to null
      return null;
    }
    return null;
  }

  /// Clear all stored session items
  Future<void> clearSession() async {
    await _storage.delete(key: _keyToken);
    await _storage.delete(key: _keyEmail);
    await _storage.delete(key: _keyName);
  }
}
