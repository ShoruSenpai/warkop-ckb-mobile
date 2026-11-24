import 'package:flutter/foundation.dart';

import 'current_user.dart';

class AuthSession extends ChangeNotifier {
  CurrentUser? _currentUser;
  CurrentUser? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  void start(CurrentUser user) {
    _currentUser = user;
    notifyListeners();
  }

  void clear() {
    _currentUser = null;
    notifyListeners();
  }
}
