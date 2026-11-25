import '../session/current_user.dart';
import 'route_names.dart';

String roleLandingRoute(UserRole role) => switch (role) {
  UserRole.owner => RouteNames.owner,
  UserRole.management => RouteNames.home,
  UserRole.cashier => RouteNames.cashierPos,
  UserRole.employee => RouteNames.attendance,
};

String canonicalRoute(String route) =>
    const {
      '/': RouteNames.home,
      '/kasir': RouteNames.cashierPos,
      '/jadwal': RouteNames.workSchedule,
      '/profil': RouteNames.employeeProfile,
      '/shift': RouteNames.changeShift,
      '/verifikasi_lokasi': RouteNames.locationVerification,
      '/verifikasi_wajah': RouteNames.faceVerification,
      '/absen_sukses': RouteNames.attendanceSuccess,
      '/pesanan_berhasil': RouteNames.orderSuccess,
    }[route] ??
    route;

bool routeAllowedForRole(String route, UserRole role) {
  route = canonicalRoute(route);
  if (role == UserRole.owner) return true;
  return switch (route) {
    RouteNames.owner || RouteNames.attendanceSettings => false,
    RouteNames.attendance ||
    RouteNames.locationVerification ||
    RouteNames.faceVerification ||
    RouteNames.attendanceSuccess =>
      role == UserRole.employee || role == UserRole.cashier,
    RouteNames.workSchedule => role == UserRole.employee,
    RouteNames.cashierPos ||
    RouteNames.orderSuccess ||
    RouteNames.changeShift => role == UserRole.cashier,
    RouteNames.employeeProfile => role != UserRole.management,
    _ => true,
  };
}
