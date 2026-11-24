import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'secure_token_storage.dart';

class FlutterSecureTokenStorage implements SecureTokenStorage {
  FlutterSecureTokenStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _tokenKey = 'auth_token';
  static const _userDataKey = 'auth_user';
  final FlutterSecureStorage _storage;

  @override
  Future<String?> readToken() => _storage.read(key: _tokenKey);

  @override
  Future<void> writeToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  @override
  Future<void> deleteToken() => _storage.delete(key: _tokenKey);

  @override
  Future<String?> readUserData() => _storage.read(key: _userDataKey);

  @override
  Future<void> writeUserData(String userData) =>
      _storage.write(key: _userDataKey, value: userData);

  @override
  Future<void> deleteUserData() => _storage.delete(key: _userDataKey);
}
