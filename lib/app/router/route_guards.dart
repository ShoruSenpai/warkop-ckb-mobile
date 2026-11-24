import '../session/current_user.dart';
import 'route_names.dart';

String roleLandingRoute(UserRole role) => switch (role) {
  UserRole.management => RouteNames.home,
  UserRole.cashier => RouteNames.cashierPos,
  UserRole.employee => RouteNames.attendance,
};

bool routeAllowedForRole(String route, UserRole role) => switch (route) {
  RouteNames.attendance ||
  RouteNames.locationVerification ||
  RouteNames.faceVerification ||
  RouteNames.attendanceSuccess ||
  RouteNames.workSchedule => role == UserRole.employee,
  RouteNames.cashierPos ||
  RouteNames.orderSuccess ||
  RouteNames.changeShift => role == UserRole.cashier,
  RouteNames.employeeProfile => role != UserRole.management,
  _ => true,
};
