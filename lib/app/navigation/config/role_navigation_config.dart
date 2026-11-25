import 'package:flutter/material.dart';

import '../../../features/cashier/pos/data/repositories/order_repository.dart';
import '../../../features/cashier/pos/data/repositories/product_repository.dart';
import '../../../features/cashier/pos/halaman_kasir.dart';
import '../../../features/cashier/shift/change_shift_page.dart';
import '../../../features/employee/attendance/halaman_absensi.dart';
import '../../../features/employee/profile/employee_profile_page.dart';
import '../../../features/employee/schedule/work_schedule_page.dart';
import '../../../features/owner/halaman_owner.dart';
import '../../router/route_names.dart';
import '../../session/current_user.dart';
import '../models/navigation_item.dart';

abstract final class RoleNavigationConfig {
  static const _employeeItems = <NavigationItem>[
    NavigationItem(
      label: 'Absensi',
      route: RouteNames.attendance,
      icon: Icons.fact_check_outlined,
      allowedRoles: {UserRole.employee},
    ),
    NavigationItem(
      label: 'Jadwal',
      route: RouteNames.workSchedule,
      icon: Icons.calendar_month_outlined,
      allowedRoles: {UserRole.employee},
    ),
    NavigationItem(
      label: 'Profil',
      route: RouteNames.employeeProfile,
      icon: Icons.person_outline,
      allowedRoles: {UserRole.employee},
    ),
  ];
  static const _cashierItems = <NavigationItem>[
    NavigationItem(
      label: 'POS',
      route: RouteNames.cashierPos,
      icon: Icons.point_of_sale_outlined,
      allowedRoles: {UserRole.cashier},
    ),
    NavigationItem(
      label: 'Absensi',
      route: RouteNames.attendance,
      icon: Icons.fact_check_outlined,
      allowedRoles: {UserRole.cashier},
    ),
    NavigationItem(
      label: 'Tukar Shift',
      route: RouteNames.changeShift,
      icon: Icons.swap_horiz,
      allowedRoles: {UserRole.cashier},
    ),
    NavigationItem(
      label: 'Profil',
      route: RouteNames.employeeProfile,
      icon: Icons.person_outline,
      allowedRoles: {UserRole.cashier},
    ),
  ];
  static const _ownerItems = <NavigationItem>[
    NavigationItem(
      label: 'Owner',
      route: RouteNames.owner,
      icon: Icons.dashboard_outlined,
      allowedRoles: {UserRole.owner},
    ),
    NavigationItem(
      label: 'Absensi',
      route: RouteNames.attendance,
      icon: Icons.fact_check_outlined,
      allowedRoles: {UserRole.owner},
    ),
    NavigationItem(
      label: 'POS',
      route: RouteNames.cashierPos,
      icon: Icons.point_of_sale_outlined,
      allowedRoles: {UserRole.owner},
    ),
    NavigationItem(
      label: 'Jadwal',
      route: RouteNames.workSchedule,
      icon: Icons.calendar_month_outlined,
      allowedRoles: {UserRole.owner},
    ),
    NavigationItem(
      label: 'Profil',
      route: RouteNames.employeeProfile,
      icon: Icons.person_outline,
      allowedRoles: {UserRole.owner},
    ),
  ];
  static List<NavigationItem> forRole(UserRole role) => switch (role) {
    UserRole.owner => _ownerItems,
    UserRole.employee => _employeeItems,
    UserRole.cashier => _cashierItems,
    UserRole.management => const [],
  };

  // Retain the Laravel stock/idempotency and server-side face/location flows.
  // These screens share Shoru's shell without a second navigation footer.
  static Widget pageFor(
    String route, {
    required CurrentUser currentUser,
    required ProductRepository productRepository,
    required OrderRepository orderRepository,
    required Future<void> Function() onLogout,
  }) => switch (route) {
    RouteNames.owner => const OwnerScreen(),
    RouteNames.attendance => const HomeScreen(embedded: true),
    RouteNames.cashierPos => const KasirScreen(),
    RouteNames.workSchedule => const WorkSchedulePage(),
    RouteNames.employeeProfile => EmployeeProfilePage(
      currentUser: currentUser,
      onLogout: onLogout,
    ),
    RouteNames.changeShift => ChangeShiftPage(currentUser: currentUser),
    _ => const SizedBox.shrink(),
  };
}
