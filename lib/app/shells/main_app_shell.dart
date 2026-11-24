import 'package:flutter/material.dart';

import '../app_dependencies.dart';
import '../navigation/config/role_navigation_config.dart';
import '../navigation/widgets/app_bottom_navigation.dart';
import '../session/current_user.dart';

class MainAppShell extends StatefulWidget {
  const MainAppShell({
    required this.currentUser,
    required this.dependencies,
    this.initialRoute,
    super.key,
  });

  final CurrentUser currentUser;
  UserRole get role => currentUser.role;
  final AppDependencies dependencies;
  final String? initialRoute;

  @override
  State<MainAppShell> createState() => _MainAppShellState();
}

class _MainAppShellState extends State<MainAppShell> {
  late final items = RoleNavigationConfig.forRole(widget.role);
  late int _selectedIndex = _initialIndex();

  int _initialIndex() {
    final index = items.indexWhere((item) => item.route == widget.initialRoute);
    return index < 0 ? 0 : index;
  }

  @override
  Widget build(BuildContext context) {
    final pages = items
        .map(
          (item) => RoleNavigationConfig.pageFor(
            item.route,
            currentUser: widget.currentUser,
            productRepository: widget.dependencies.productRepository,
            orderRepository: widget.dependencies.orderRepository,
            onLogout: widget.dependencies.sessionManager.clear,
          ),
        )
        .toList();
    final safeIndex = pages.isEmpty
        ? 0
        : _selectedIndex.clamp(0, pages.length - 1);
    return Scaffold(
      body: pages.isEmpty
          ? const Center(child: Text('Fitur manajemen belum tersedia.'))
          : IndexedStack(index: safeIndex, children: pages),
      bottomNavigationBar: pages.isEmpty
          ? null
          : AppBottomNavigation(
              items: items,
              currentIndex: safeIndex,
              onSelected: (index) => setState(() => _selectedIndex = index),
            ),
    );
  }
}
