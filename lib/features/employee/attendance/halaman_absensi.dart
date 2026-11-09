import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

import '../../../services/layanan_waktu.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _isClockingIn = false;
  late Timer _timer;
  DateTime _now = LayananWaktu.sekarang();

  @override
  void initState() {
    super.initState();
    _now = LayananWaktu.sekarang();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _now = LayananWaktu.sekarang();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatDate(DateTime dt) {
    const days = ['', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${days[dt.weekday]}, ${dt.day} ${months[dt.month]}';
  }

  String _formatTime(DateTime dt) {
    return LayananWaktu.formatJam(dt);
  }

  final Color primary = const Color(0xFF2563EB);
  final Color primaryContainer = const Color(0xFF1D4ED8);
  final Color surface = const Color(0xFFF4F6FB);
  final Color surfaceContainerLowest = const Color(0xFFFFFFFF);
  final Color surfaceContainerLow = const Color(0xFFEFF6FF);
  final Color surfaceContainer = const Color(0xFFEFF6FF);
  final Color secondaryContainer = const Color(0xFFBAE6FD);
  final Color secondary = const Color(0xFF396477);
  final Color onSurface = const Color(0xFF0B1C30);
  final Color onSurfaceVariant = const Color(0xFF5A6672);

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 1) Navigator.pushNamed(context, '/jadwal');
    if (index == 2) Navigator.pushNamed(context, '/kasir');
    if (index == 3) Navigator.pushNamed(context, '/profil');
  }

  void _handleClockIn() {
    setState(() => _isClockingIn = true);
    Timer(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      setState(() => _isClockingIn = false);
      Navigator.pushNamed(context, '/verifikasi_lokasi');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surface,
      body: SingleChildScrollView(
        child: Column(
          children: [

            Stack(
              clipBehavior: Clip.none,
              children: [

                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(36),
                    bottomRight: Radius.circular(36),
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 48, 20, 75),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF2563EB),
                          Color(0xFF1E40AF),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [

                        Positioned(
                          top: -70,
                          left: -55,
                          child: Container(
                            width: 220,
                            height: 220,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.07),
                            ),
                          ),
                        ),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [

                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2.2),
                              image: const DecorationImage(
                                image: AssetImage('assets/images/avatar_chiikawa.png'),
                                fit: BoxFit.cover,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.12),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 14),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Halo, Selamat Pagi!',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white.withOpacity(0.88),
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  'Azai Lunia',
                                  style: GoogleFonts.poppins(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: -0.4,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF4ADE80),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    _formatTime(_now),
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 1),
                              Text(
                                _formatDate(_now),
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFFBAE6FD),
                                  height: 1.1,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 12),

                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.18),
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: const Icon(
                                    Icons.notifications_none_rounded,
                                    color: Colors.white,
                                    size: 21,
                                  ),
                                  onPressed: () => _showFloatingNotifications(context),
                                ),
                              ),

                              Positioned(
                                top: 2,
                                right: 2,
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEF4444),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: const Color(0xFF2563EB), width: 2),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.14),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.20),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.location_on_rounded,
                              size: 13,
                              color: Color(0xFFBAE6FD),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'Warkop Cak Kebo • Outlet Senopati',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFE0F2FE),
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 172, left: 20, right: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1E3A8A).withOpacity(0.12),
                          blurRadius: 28,
                          offset: const Offset(0, 14),
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(26),
                      child: Stack(
                        children: [

                          Positioned(
                            right: -55,
                            bottom: -70,
                            child: Transform.rotate(
                              angle: -0.08,
                              child: Opacity(
                                opacity: 0.075,
                                child: Image.asset(
                                  'assets/images/logo_cak_kebo_transparent.png',
                                  width: 290,
                                  height: 290,
                                  color: const Color(0xFF1E3A8A),
                                  colorBlendMode: BlendMode.srcIn,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.all(22),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEFF6FF),
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(color: const Color(0xFFDBEAFE)),
                                      ),
                                      child: const Icon(
                                        Icons.person_rounded,
                                        color: Color(0xFF2563EB),
                                        size: 26,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'STATUS PRESENSI',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color: const Color(0xFF64748B),
                                              letterSpacing: 0.8,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Belum Absen Masuk',
                                            style: GoogleFonts.poppins(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700,
                                              color: const Color(0xFF0F172A),
                                              letterSpacing: -0.3,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Azai Lunia • Barista Staff',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: const Color(0xFF64748B),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.schedule_rounded,
                                                size: 16,
                                                color: Color(0xFF2563EB),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Shift Pagi (08:00 - 16:00)',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w700,
                                                  color: const Color(0xFF0F172A),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF2563EB),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              'Wajib',
                                              style: TextStyle(
                                                fontSize: 10.5,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.hourglass_empty_rounded,
                                                size: 14,
                                                color: Color(0xFF2563EB),
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                '15 Menit lagi',
                                                style: TextStyle(
                                                  fontSize: 11.5,
                                                  fontWeight: FontWeight.w700,
                                                  color: const Color(0xFF0F172A),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            'Toleransi: s/d 08:10',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500,
                                              color: const Color(0xFF64748B),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),

                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEFF6FF),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: const Color(0xFFDBEAFE)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: const BoxDecoration(
                                              color: Color(0xFF2563EB),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Area Terverifikasi',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: const Color(0xFF0F172A),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        'SIAP MASUK',
                                        style: TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF2563EB),
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),

                        Container(
                          width: double.infinity,
                          height: 52,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF2563EB),
                                Color(0xFF1D4ED8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF2563EB).withOpacity(0.35),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _isClockingIn ? null : _handleClockIn,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: _isClockingIn
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Absen Masuk Sekarang',
                                        style: GoogleFonts.poppins(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'MENU CEPAT',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF64748B),
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),

            LayoutBuilder(
              builder: (context, constraints) {
                final availableWidth = constraints.maxWidth;
                const double leftPadding = 20.0;
                const double gap = 12.0;
                const double peekWidth = 32.0;

                double cardWidth = (availableWidth - leftPadding - (3 * gap) - peekWidth) / 3;
                if (availableWidth < 360) {
                  cardWidth = (availableWidth - leftPadding - (2 * gap) - peekWidth) / 2;
                }
                cardWidth = cardWidth.clamp(90.0, 136.0);

                return SizedBox(
                  height: 124,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    clipBehavior: Clip.none,
                    children: [
                      _buildHugeCard(
                        context: context,
                        width: cardWidth,
                        title: 'Jadwal',
                        subtitle: 'Shift kerja',
                        icon: Icons.calendar_month_rounded,
                        iconColor: const Color(0xFF2563EB),
                        route: '/jadwal',
                      ),
                      const SizedBox(width: gap),
                      _buildHugeCard(
                        context: context,
                        width: cardWidth,
                        title: 'Ganti Shift',
                        subtitle: 'Tukar rekan',
                        icon: Icons.swap_horiz_rounded,
                        iconColor: const Color(0xFF2563EB),
                        route: '/shift',
                      ),
                      const SizedBox(width: gap),
                      _buildHugeCard(
                        context: context,
                        width: cardWidth,
                        title: 'Kasir POS',
                        subtitle: 'Order & bayar',
                        icon: Icons.point_of_sale_rounded,
                        iconColor: const Color(0xFF2563EB),
                        route: '/kasir',
                      ),
                      const SizedBox(width: gap),
                      _buildHugeCard(
                        context: context,
                        width: cardWidth,
                        title: 'Profil',
                        subtitle: 'Data staf',
                        icon: Icons.badge_outlined,
                        iconColor: const Color(0xFF2563EB),
                        route: '/profil',
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: surfaceContainerLow,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.storefront, color: primary),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Warkop Cak Kebo',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: onSurface,
                                ),
                              ),
                              Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Buka • 12m dari posisi Anda',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.map, color: primary),
                          style: IconButton.styleFrom(
                            backgroundColor: surfaceContainer,
                          ),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: surfaceContainerLow,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.lightbulb, color: primary, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Panduan Presensi Cepat',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Pastikan wajah tidak tertutup masker saat selfie verifikasi, dan tetap berada dalam radius 50 meter dari kasir outlet Cak Kebo.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: primary,
        unselectedItemColor: const Color(0xFF64748B),
        selectedLabelStyle: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
        unselectedLabelStyle: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w500,
          fontSize: 11,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.timer),
            label: 'Absensi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Jadwal',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.point_of_sale),
            label: 'POS',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.badge),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

Widget _buildHugeCard({
    required BuildContext context,
    required double width,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required String route,
  }) {
    return Container(
      width: width,
      height: 124,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => Navigator.pushNamed(context, route),
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                Positioned(
                  right: -12,
                  bottom: -12,
                  child: Opacity(
                    opacity: 0.12,
                    child: Icon(
                      icon,
                      size: 78,
                      color: iconColor,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(icon, color: iconColor, size: 24),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F172A),
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBentoStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color baseColor,
    required Color bgColor,
    required Color borderColor,
    required double progress,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: baseColor.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: baseColor.withOpacity(0.12),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(icon, size: 16, color: baseColor),
                ),
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: baseColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
                letterSpacing: -0.3,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 3),

            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 8),

            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 3.5,
                backgroundColor: Colors.white.withOpacity(0.7),
                valueColor: AlwaysStoppedAnimation<Color>(baseColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildNavPillItem({
    required int index,
    required IconData icon,
    required String label,
    required String route,
  }) {
    final bool isSelected = _selectedIndex == index;

    return InkWell(
      onTap: () {
        setState(() => _selectedIndex = index);
        if (index > 0) Navigator.pushNamed(context, route);
      },
      borderRadius: BorderRadius.circular(24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: isSelected
            ? const EdgeInsets.symmetric(horizontal: 16, vertical: 10)
            : const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEEF2FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFF94A3B8),
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF4F46E5),
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showFloatingNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withOpacity(0.18),
                blurRadius: 36,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  Center(
                    child: Container(
                      width: 40,
                      height: 4.5,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.notifications_active_rounded,
                              size: 18,
                              color: Color(0xFF2563EB),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Notifikasi',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F172A),
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '2 Baru',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF2563EB),
                              ),
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.close_rounded, size: 22, color: Color(0xFF94A3B8)),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  const SizedBox(height: 14),

                  _buildNotificationItem(
                    icon: Icons.alarm_on_rounded,
                    iconColor: const Color(0xFFD97706),
                    iconBg: const Color(0xFFFEF3C7),
                    title: 'Shift Pagi Segera Dimulai',
                    subtitle: 'Jadwal Barista kamu mulai pukul 08:00 ${LayananWaktu.zonaWaktu(_now)}. Segera lakukan presensi masuk.',
                    time: '15 menit yang lalu',
                    isUnread: true,
                  ),
                  const SizedBox(height: 12),
                  _buildNotificationItem(
                    icon: Icons.radar_rounded,
                    iconColor: const Color(0xFF16A34A),
                    iconBg: const Color(0xFFDCFCE7),
                    title: 'Radius Outlet Terverifikasi',
                    subtitle: 'Perangkat kamu terdeteksi 12m dari mesin kasir Warkop Cak Kebo Senopati.',
                    time: '45 menit yang lalu',
                    isUnread: true,
                  ),
                  const SizedBox(height: 12),
                  _buildNotificationItem(
                    icon: Icons.local_cafe_rounded,
                    iconColor: const Color(0xFF2563EB),
                    iconBg: const Color(0xFFEFF6FF),
                    title: 'Restock Logistik Cabang',
                    subtitle: 'Biji kopi robusta, fresh milk & sirup aren telah diperbarui untuk shift hari ini.',
                    time: 'Kemarin, 21:30',
                    isUnread: false,
                  ),
                  const SizedBox(height: 18),

                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF8FAFC),
                        foregroundColor: const Color(0xFF475569),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                      ),
                      child: Text(
                        'Tutup',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotificationItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
    required String time,
    required bool isUnread,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isUnread ? const Color(0xFFF8FAFC) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnread ? const Color(0xFFE2E8F0) : const Color(0xFFF1F5F9),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    if (isUnread)
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Color(0xFF2563EB),
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
