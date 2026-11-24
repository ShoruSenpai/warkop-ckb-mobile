import 'package:flutter_test/flutter_test.dart';
import 'package:warkop_ckb_mobile/app/navigation/config/role_navigation_config.dart';
import 'package:warkop_ckb_mobile/app/router/route_guards.dart';
import 'package:warkop_ckb_mobile/app/router/route_names.dart';
import 'package:warkop_ckb_mobile/app/session/current_user.dart';

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
    expect(roleLandingRoute(UserRole.employee), RouteNames.attendance);
    expect(roleLandingRoute(UserRole.cashier), RouteNames.cashierPos);
    expect(roleLandingRoute(UserRole.management), RouteNames.home);
  });
}
