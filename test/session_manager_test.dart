import 'package:flutter_test/flutter_test.dart';
import 'package:warkop_ckb_mobile/app/session/current_user.dart';
import 'package:warkop_ckb_mobile/app/session/session_manager.dart';
import 'package:warkop_ckb_mobile/core/storage/secure_token_storage.dart';

class FakeSecureTokenStorage implements SecureTokenStorage {
  String? token;
  String? userData;

  @override
  Future<void> deleteToken() async => token = null;
  @override
  Future<void> deleteUserData() async => userData = null;
  @override
  Future<String?> readToken() async => token;
  @override
  Future<String?> readUserData() async => userData;
  @override
  Future<void> writeToken(String value) async => token = value;
  @override
  Future<void> writeUserData(String value) async => userData = value;
}

void main() {
  test(
    'stores token and restores the authenticated role and profile',
    () async {
      final storage = FakeSecureTokenStorage();
      final manager = SessionManager(tokenStorage: storage);
      const user = CurrentUser(
        id: 'employee-1',
        name: 'Rina',
        role: UserRole.employee,
        employeeCode: 'CK-01',
      );

      await manager.start('access-token', user);
      final restored = SessionManager(tokenStorage: storage);
      expect(await restored.restore(), isTrue);
      expect(restored.session.currentUser?.name, 'Rina');
      expect(restored.session.currentUser?.employeeCode, 'CK-01');
      expect(storage.token, 'access-token');
    },
  );

  test('unknown backend roles fail closed', () {
    expect(
      () => CurrentUser.fromApi({'id': '1', 'name': 'A', 'role': 'unknown'}),
      throwsFormatException,
    );
  });
}
