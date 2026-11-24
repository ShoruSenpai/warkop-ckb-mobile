import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../models/navigation_item.dart';

class AppBottomNavigation extends StatelessWidget {
  const AppBottomNavigation({
    required this.items,
    required this.currentIndex,
    required this.onSelected,
    super.key,
  });

  final List<NavigationItem> items;
  final int currentIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) => NavigationBar(
    selectedIndex: currentIndex,
    onDestinationSelected: onSelected,
    backgroundColor: Colors.white,
    indicatorColor: AppColors.primaryLight,
    destinations: [
      for (final item in items)
        NavigationDestination(icon: Icon(item.icon), label: item.label),
    ],
  );
}
