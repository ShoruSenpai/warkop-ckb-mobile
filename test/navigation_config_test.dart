import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_ckb/app/navigation/config/role_navigation_config.dart';
import 'package:mobile_ckb/app/router/route_guards.dart';
import 'package:mobile_ckb/app/router/route_names.dart';
import 'package:mobile_ckb/app/session/current_user.dart';

void main() {
  test('employee navigation contains only implemented employee pages', () {
    final items = RoleNavigationConfig.forRole(UserRole.employee);

    expect(items.map((item) => item.route), [
      RouteNames.attendance,
      RouteNames.workSchedule,
      RouteNames.employeeProfile,
    ]);
  });

  test(
    'cashier opens POS first and management has no invented destinations',
    () {
      final cashierItems = RoleNavigationConfig.forRole(UserRole.cashier);

      expect(cashierItems.first.route, RouteNames.cashierPos);
      expect(RoleNavigationConfig.forRole(UserRole.management), isEmpty);
    },
  );

  test('landing route follows authenticated role', () {
    expect(roleLandingRoute(UserRole.owner), RouteNames.owner);
    expect(roleLandingRoute(UserRole.employee), RouteNames.attendance);
    expect(roleLandingRoute(UserRole.cashier), RouteNames.cashierPos);
    expect(roleLandingRoute(UserRole.management), RouteNames.home);
  });

  test(
    'owner retains all implemented areas and legacy aliases enforce roles',
    () {
      final routes = RoleNavigationConfig.forRole(UserRole.owner)
          .map((item) => item.route);
      expect(
        routes,
        containsAll([
          RouteNames.owner,
          RouteNames.attendance,
          RouteNames.cashierPos,
          RouteNames.employeeProfile,
        ]),
      );
      for (final role in UserRole.values) {
        expect(
          routeAllowedForRole('/pengaturan_presensi', role),
          role == UserRole.owner,
        );
        expect(routeAllowedForRole('/owner', role), role == UserRole.owner);
        expect(
          routeAllowedForRole('/kasir', role),
          role == UserRole.owner || role == UserRole.cashier,
        );
      }
      expect(
        routeAllowedForRole('/verifikasi_lokasi', UserRole.cashier),
        isTrue,
      );
    },
  );
}
