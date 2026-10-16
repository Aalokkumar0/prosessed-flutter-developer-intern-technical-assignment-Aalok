import '../../../core/network/api_client.dart';
import '../../../core/network/session_store.dart';
import '../domain/user.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._client, this._sessionStore);

  final ApiClient _client;
  final SessionStore _sessionStore;

  @override
  Future<User> login({
    required String username,
    required String password,
  }) async {
    final json = await _client.post(
      '/auth/login',
      authenticated: false,
      data: {'username': username, 'password': password, 'expiresInMins': 30},
    );
    await _sessionStore.saveTokens(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
    );
    return _userFromJson(json);
  }

  @override
  Future<User> getCurrentUser() async =>
      _userFromJson(await _client.get('/auth/me'));

  @override
  Future<bool> hasSession() => _sessionStore.hasSession;

  @override
  Future<void> logout() => _sessionStore.clear();

  User _userFromJson(Map<String, dynamic> json) => User(
    id: (json['id'] as num).toInt(),
    firstName: json['firstName']?.toString() ?? '',
    lastName: json['lastName']?.toString() ?? '',
    email: json['email']?.toString() ?? '',
    phone: json['phone']?.toString() ?? '',
    image: json['image']?.toString() ?? '',
  );
}
