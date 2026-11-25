import 'package:flutter/material.dart';

import '../../data/repositories/auth_repository.dart';
import '../halaman_masuk.dart';

// Keep the verified server-address flow while using Shoru's session/router.
class LoginPage extends StatelessWidget {
  const LoginPage({required this.authRepository, super.key});
  final AuthRepository authRepository;
  @override
  Widget build(BuildContext context) => LoginScreen(
    onLogin: (email, password) async {
      await authRepository.login(identifier: email, password: password);
    },
  );
}
