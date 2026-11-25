import 'package:flutter/material.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/cashier/orders/halaman_pesanan_berhasil.dart';
import '../../features/employee/attendance/halaman_absen_berhasil.dart';
import '../../features/employee/attendance/halaman_pengaturan_presensi.dart';
import '../../features/employee/attendance/halaman_verifikasi_lokasi.dart';
import '../../features/employee/attendance/halaman_verifikasi_wajah.dart';
import '../../models/bukti_absensi.dart';
import '../../models/lokasi_absensi.dart';
import '../app_dependencies.dart';
import '../shells/cashier_app_shell.dart';
import '../shells/main_app_shell.dart';
import '../session/current_user.dart';
import 'route_guards.dart';
import 'route_names.dart';

class AppRouter {
  const AppRouter(this.dependencies);
  final AppDependencies dependencies;
  Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final route = canonicalRoute(settings.name ?? RouteNames.home);
    final user = dependencies.sessionManager.session.currentUser;
    if (route == RouteNames.login || user == null) {
      return _page(
        settings,
        LoginPage(authRepository: dependencies.authRepository),
      );
    }
    if (!routeAllowedForRole(route, user.role)) {
      return _shell(settings, user, roleLandingRoute(user.role));
    }
    return switch (route) {
      RouteNames.home => _shell(settings, user, roleLandingRoute(user.role)),
      RouteNames.owner ||
      RouteNames.attendance ||
      RouteNames.workSchedule ||
      RouteNames.employeeProfile ||
      RouteNames.cashierPos ||
      RouteNames.changeShift => _shell(settings, user, route),
      RouteNames.attendanceSettings => _page(
        settings,
        const PengaturanPresensiScreen(),
      ),
      RouteNames.locationVerification => _page(
        settings,
        const VerifikasiLokasiScreen(),
      ),
      RouteNames.faceVerification => _page(
        settings,
        settings.arguments is LokasiAbsensi
            ? VerifikasiWajahScreen(
                lokasi: settings.arguments! as LokasiAbsensi,
              )
            : const VerifikasiLokasiScreen(),
      ),
      RouteNames.attendanceSuccess => _page(
        settings,
        settings.arguments is BuktiAbsensi
            ? AbsenSuksesScreen(bukti: settings.arguments! as BuktiAbsensi)
            : const VerifikasiLokasiScreen(),
      ),
      RouteNames.orderSuccess => _page(
        settings,
        settings.arguments is Map<String, dynamic>
            ? PesananBerhasilPage(
                sale: settings.arguments! as Map<String, dynamic>,
              )
            : const Scaffold(
                body: Center(child: Text('Bukti transaksi tidak tersedia.')),
              ),
      ),
      _ => _page(
        settings,
        const Scaffold(body: Center(child: Text('Halaman tidak ditemukan.'))),
      ),
    };
  }

  Route<dynamic> _shell(
    RouteSettings settings,
    CurrentUser user,
    String route,
  ) => _page(
    settings,
    user.role == UserRole.cashier
        ? CashierAppShell(
            currentUser: user,
            dependencies: dependencies,
            initialRoute: route,
          )
        : MainAppShell(
            currentUser: user,
            dependencies: dependencies,
            initialRoute: route,
          ),
  );
  MaterialPageRoute<dynamic> _page(RouteSettings settings, Widget page) =>
      MaterialPageRoute<void>(settings: settings, builder: (_) => page);
}
