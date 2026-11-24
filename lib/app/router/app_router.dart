import 'package:flutter/material.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/cashier/orders/order_success_page.dart';
import '../../features/employee/attendance/domain/models/attendance_location.dart';
import '../../features/employee/attendance/domain/models/attendance_proof.dart';
import '../../features/employee/attendance/presentation/pages/attendance_success_page.dart';
import '../../features/employee/attendance/presentation/pages/face_verification_page.dart';
import '../../features/employee/attendance/presentation/pages/location_verification_page.dart';
import '../../features/employee/attendance/presentation/controllers/attendance_controller.dart';
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
    final route = settings.name ?? RouteNames.home;
    final user = dependencies.sessionManager.session.currentUser;
    if (route != RouteNames.login && user == null) {
      return _page(
        settings,
        LoginPage(authRepository: dependencies.authRepository),
      );
    }
    if (user != null && !routeAllowedForRole(route, user.role)) {
      return _shell(settings, user.role, roleLandingRoute(user.role));
    }
    return switch (route) {
      RouteNames.login => _page(
        settings,
        LoginPage(authRepository: dependencies.authRepository),
      ),
      RouteNames.home => _shell(
        settings,
        user?.role ?? UserRole.employee,
        user == null ? RouteNames.login : roleLandingRoute(user.role),
      ),
      RouteNames.attendance ||
      RouteNames.workSchedule ||
      RouteNames.employeeProfile ||
      RouteNames.cashierPos ||
      RouteNames.changeShift => _shell(settings, user!.role, route),
      RouteNames.locationVerification => _page(
        settings,
        const LocationVerificationPage(),
      ),
      RouteNames.faceVerification => _page(
        settings,
        settings.arguments is AttendanceLocation
            ? FaceVerificationPage(
                location: settings.arguments! as AttendanceLocation,
                attendanceController: AttendanceController(
                  dependencies.attendanceRepository,
                ),
              )
            : const LocationVerificationPage(),
      ),
      RouteNames.attendanceSuccess => _page(
        settings,
        settings.arguments is AttendanceProof
            ? AttendanceSuccessPage(
                proof: settings.arguments! as AttendanceProof,
                currentUser: user!,
              )
            : const LocationVerificationPage(),
      ),
      RouteNames.orderSuccess => _page(
        settings,
        OrderSuccessPage(
          currentUser: user!,
          orderData: settings.arguments is Map
              ? Map<String, dynamic>.from(settings.arguments! as Map)
              : const <String, dynamic>{},
        ),
      ),
      _ => _page(settings, const _UnknownRoutePage()),
    };
  }

  Route<dynamic> _shell(RouteSettings settings, UserRole role, String route) {
    final Widget shell = role == UserRole.cashier
        ? CashierAppShell(
            currentUser: dependencies.sessionManager.session.currentUser!,
            dependencies: dependencies,
            initialRoute: route,
          )
        : MainAppShell(
            currentUser: dependencies.sessionManager.session.currentUser!,
            dependencies: dependencies,
            initialRoute: route,
          );
    return _page(settings, shell);
  }

  MaterialPageRoute<dynamic> _page(RouteSettings settings, Widget page) =>
      MaterialPageRoute<void>(settings: settings, builder: (_) => page);
}

class _UnknownRoutePage extends StatelessWidget {
  const _UnknownRoutePage();

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Halaman tidak ditemukan.')));
}
