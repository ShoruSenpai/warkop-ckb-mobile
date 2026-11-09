import 'pengguna_aktif.dart';

class AuthSession {
  CurrentUser? _currentUser;

  CurrentUser? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  void start(CurrentUser user) {
    _currentUser = user;
  }

  void clear() {
    _currentUser = null;
  }
}