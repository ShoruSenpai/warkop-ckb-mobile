import '../../data/repositories/auth_repository.dart';
import '../../../../app/session/current_user.dart';

class LoginController {
  const LoginController(this._authRepository);

  final AuthRepository _authRepository;

  Future<CurrentUser> submit(String identifier, String password) =>
      _authRepository.login(identifier: identifier.trim(), password: password);
}
