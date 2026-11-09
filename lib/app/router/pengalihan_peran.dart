import '../session/pengguna_aktif.dart';

String roleRedirect(UserRole? role) {
  return switch (role) {
    UserRole.management => '/home',
    UserRole.cashier => '/kasir',
    UserRole.employee => '/home',
    null => '/login',
  };
}