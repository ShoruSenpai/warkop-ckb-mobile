import 'dart:convert';

import '../../core/storage/secure_token_storage.dart';
import 'auth_session.dart';
import 'current_user.dart';

class SessionManager {
  SessionManager({
    required SecureTokenStorage tokenStorage,
    AuthSession? session,
  }) : _tokenStorage = tokenStorage,
       session = session ?? AuthSession();

  final SecureTokenStorage _tokenStorage;
  final AuthSession session;

  Future<bool> restore() async {
    final token = await _tokenStorage.readToken();
    final rawUser = await _tokenStorage.readUserData();
    if (token == null || token.isEmpty || rawUser == null) {
      await clear();
      return false;
    }
    try {
      final user = CurrentUser.fromApi(
        Map<String, dynamic>.from(jsonDecode(rawUser) as Map),
      );
      session.start(user);
      return true;
    } on Object {
      await clear();
      return false;
    }
  }

  Future<void> start(String token, CurrentUser user) async {
    await _tokenStorage.writeToken(token);
    await _tokenStorage.writeUserData(
      jsonEncode({
        'id': user.id,
        'name': user.name,
        'role': user.role.name,
        'employee_code': user.employeeCode,
        'position': user.position,
        'outlet': user.outlet,
        'shift': user.shift,
      }),
    );
    session.start(user);
  }

  Future<void> clear() async {
    await _tokenStorage.deleteToken();
    await _tokenStorage.deleteUserData();
    session.clear();
  }
}
