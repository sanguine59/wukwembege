import 'dart:async';
import '../api_client.dart';

class AuthUser {
  final String uid;
  const AuthUser(this.uid);
}

class AuthRepository {
  final ApiClient _api;
  final _controller = StreamController<AuthUser?>.broadcast();
  AuthUser? _current;

  AuthRepository(this._api);

  Stream<AuthUser?> authChanges() async* {
    yield _current;
    yield* _controller.stream;
  }

  AuthUser? get current => _current;

  Future<AuthUser> signIn(String email, String password) async {
    final res = await _api.post('/auth/login', {'email': email, 'password': password});
    return _accept(res);
  }

  Future<AuthUser> register(String email, String password) async {
    final res = await _api.post('/auth/register', {'email': email, 'password': password});
    return _accept(res);
  }

  AuthUser _accept(dynamic res) {
    _api.token = res['token'] as String;
    final user = AuthUser(res['uid'] as String);
    _current = user;
    _controller.add(user);
    return user;
  }

  Future<void> signOut() async {
    _api.token = null;
    _current = null;
    _controller.add(null);
  }

  Future<void> sendPasswordReset(String email) =>
      _api.post('/auth/password-reset', {'email': email});
}
