import 'user.dart';

/// Application-level authentication actions kept outside presentation code.
class AuthUseCases {
  const AuthUseCases(this._repository);

  final AuthRepository _repository;

  Future<bool> hasSession() => _repository.hasSession();

  Future<User> restoreSession() => _repository.getCurrentUser();

  Future<User> login({
    required String username,
    required String password,
  }) async {
    await _repository.login(username: username, password: password);
    // Fetching /auth/me after authentication makes the profile source explicit.
    return _repository.getCurrentUser();
  }

  Future<void> logout() => _repository.logout();
}
