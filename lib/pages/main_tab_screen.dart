import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

import 'absensi_page.dart';
import 'jadwal_kerja.dart';
import 'kasir_page.dart';
import 'profil_karyawan.dart';

class TabNavigationScope extends InheritedWidget {
  final int currentIndex;
  final void Function(int index) switchTo;

  const TabNavigationScope({
    super.key,
    required this.currentIndex,
    required this.switchTo,
    required super.child,
  });

  static TabNavigationScope? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<TabNavigationScope>();
  }

  @override
  bool updateShouldNotify(TabNavigationScope oldWidget) {
    return currentIndex != oldWidget.currentIndex;
  }
}

class MainTabScreen extends StatefulWidget {
  final int initialTab;
  const MainTabScreen({super.key, this.initialTab = 0});

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
  late int _currentIndex;

  final Color primary = const Color(0xFF2563EB);
  final Color unselectedColor = const Color(0xFF64748B);

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab.clamp(0, 3);
  }

  void _onItemTapped(int index) {
    if (_currentIndex == index) return;
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return TabNavigationScope(
      currentIndex: _currentIndex,
      switchTo: _onItemTapped,
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: const [
            HomeScreen(),
            JadwalScreen(),
            KasirScreen(),
            ProfilScreen(),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            elevation: 0,
            selectedItemColor: primary,
            unselectedItemColor: unselectedColor,
            selectedLabelStyle: AppTextStyles.captionBold,
            unselectedLabelStyle: AppTextStyles.caption,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.timer_outlined),
                activeIcon: Icon(Icons.timer_rounded),
                label: 'Absensi',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_month_outlined),
                activeIcon: Icon(Icons.calendar_month_rounded),
                label: 'Jadwal',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.point_of_sale_outlined),
                activeIcon: Icon(Icons.point_of_sale_rounded),
                label: 'POS',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.badge_outlined),
                activeIcon: Icon(Icons.badge_rounded),
                label: 'Profil',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
