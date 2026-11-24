import 'package:flutter/material.dart';

import '../../session/current_user.dart';

class NavigationItem {
  const NavigationItem({
    required this.label,
    required this.route,
    required this.icon,
    required this.allowedRoles,
  });

  final String label;
  final String route;
  final IconData icon;
  final Set<UserRole> allowedRoles;
}
