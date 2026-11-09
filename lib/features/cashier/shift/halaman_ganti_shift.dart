import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../services/layanan_waktu.dart';

class ShiftScreen extends StatefulWidget {
  const ShiftScreen({super.key});

  @override
  State<ShiftScreen> createState() => _ShiftScreenState();
}

class _ShiftScreenState extends State<ShiftScreen> {
  String _activeFilter = 'all';
  String _incomingStatus = 'none';
  final DateTime _now = DateTime.now();

  final Color primary = const Color(0xFF2563EB);
  final Color primaryDark = const Color(0xFF1D4ED8);
  final Color primaryLight = const Color(0xFFDBEAFE);
  final Color secondary = const Color(0xFF475569);
  final Color surface = const Color(0xFFF8FAFC);
  final Color surfaceWhite = const Color(0xFFFFFFFF);
  final Color textPrimary = const Color(0xFF0F172A);
  final Color textSecondary = const Color(0xFF64748B);
  final Color borderLight = const Color(0xFFE2E8F0);
  final Color successBg = const Color(0xFFDCFCE7);
  final Color successText = const Color(0xFF15803D);
  final Color warningBg = const Color(0xFFFEF3C7);
  final Color warningText = const Color(0xFFB45309);
  final Color dangerBg = const Color(0xFFFEE2E2);
  final Color dangerText = const Color(0xFFB91C1C);

  String _formatDate(DateTime dt) {
    const days = ['', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${days[dt.weekday]}, ${dt.day} ${months[dt.month]}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primary,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primary, primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: -50,
                    right: -40,
                    child: Container(
                      width: 170,
                      height: 170,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.08),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    left: -30,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.05),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (Navigator.canPop(context)) {
                                Navigator.pop(context);
                              } else {
                                Navigator.pushReplacementNamed(context, '/home');
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.18),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.arrow_back_ios_new, size: 12, color: Colors.white),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Kembali',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.calendar_today, size: 12, color: Colors.white),
                                const SizedBox(width: 6),
                                Text(
                                  _formatDate(_now),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2.4),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                              image: const DecorationImage(
                                image: AssetImage('assets/images/avatar_chiikawa.png'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Halo, Azai!',
                                  style: GoogleFonts.poppins(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Kelola permohonan & jadwal tukar shift Anda',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                              ],
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
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: borderLight, width: 1),
                        ),
                        child: Row(
                          children: [
                            _buildTabButton('Semua', 'all'),
                            _buildTabButton('Menunggu', 'pending'),
                            _buildTabButton('Selesai', 'completed'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      if (_activeFilter != 'completed') ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'PERMINTAAN MASUK',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: textPrimary,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: primaryLight,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '1 Baru',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              'Lihat Semua',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: surfaceWhite,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: borderLight, width: 1.2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const CircleAvatar(
                                        radius: 24,
                                        backgroundImage: NetworkImage(
                                          'https://lh3.googleusercontent.com/aida-public/AB6AXuA3mm_UjnC6nk5dDZFXiLeixQqOkD0kBo-gx2Cr2LJr8qHFPBKJi5Qd0naSmm4-e98oIUp6voEbs-D5pHYcO54h0q_OwMsB0zsi-CWZcXcqeO_RbOMnEP034rbnffkbQPzexgPU7DfBIi7u8n80SUE6zLI2JgvqONavIAEeKC_J_vkSvavCLkFh4kW5CpRRonRyFbKKLvZiQ6spqg2yNhQP9uhp_fHpTKSgEY8gZLWVeEe_dIBj5_zpQw',
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Budi Santoso',
                                            style: GoogleFonts.poppins(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                              color: textPrimary,
                                            ),
                                          ),
                                          Text(
                                            'Floor Staff & Kasir',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 12,
                                              color: textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: surface,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: borderLight, width: 0.8),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.schedule, size: 12, color: textSecondary),
                                        const SizedBox(width: 4),
                                        Text(
                                          '2 jam lalu',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 11,
                                            color: textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: surface,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(color: borderLight, width: 1),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.event_repeat, color: primary, size: 20),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Budi meminta Anda menggantikan Shift Malam',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              color: textPrimary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: borderLight, width: 0.8),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Shift Diajukan:',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 12,
                                              color: textSecondary,
                                            ),
                                          ),
                                          Text(
                                            'Jum, 10 Okt • 15.00 - 23.00 ${LayananWaktu.zonaWaktu(_now)}',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: textPrimary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: borderLight, width: 0.8),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Jadwal Anda:',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 12,
                                              color: textSecondary,
                                            ),
                                          ),
                                          Text(
                                            'Shift Pagi (08.00 - 16.00 ${LayananWaktu.zonaWaktu(_now)})',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: primary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Icon(Icons.format_quote, size: 16, color: primary.withOpacity(0.5)),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            '“Izin nenek saya ikut balapan!”',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 12,
                                              fontStyle: FontStyle.italic,
                                              color: textSecondary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              if (_incomingStatus == 'none')
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          backgroundColor: surface,
                                          foregroundColor: textPrimary,
                                          side: BorderSide(color: borderLight, width: 1),
                                          padding: const EdgeInsets.symmetric(vertical: 14),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                        ),
                                        onPressed: () => setState(() => _incomingStatus = 'declined'),
                                        child: Text(
                                          'Tolak',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: primary,
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          padding: const EdgeInsets.symmetric(vertical: 14),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                        ),
                                        onPressed: () => setState(() => _incomingStatus = 'accepted'),
                                        child: Text(
                                          'Terima',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              else
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: _incomingStatus == 'accepted' ? successBg : dangerBg,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  alignment: Alignment.center,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        _incomingStatus == 'accepted' ? Icons.check_circle : Icons.cancel,
                                        size: 16,
                                        color: _incomingStatus == 'accepted' ? successText : dangerText,
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          _incomingStatus == 'accepted'
                                              ? 'Permintaan diterima! Menunggu approval SPV...'
                                              : 'Permintaan pergantian shift telah ditolak.',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: _incomingStatus == 'accepted' ? successText : dangerText,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                'RIWAYAT PENGAJUAN',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: textPrimary,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '(3 Total)',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  color: textSecondary,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: surface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: borderLight, width: 1),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.calendar_month, size: 13, color: primary),
                                const SizedBox(width: 4),
                                Text(
                                  'Bulan Ini',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Column(
                        children: [
                          if (_activeFilter == 'all' || _activeFilter == 'completed')
                            _buildHistoryCard(
                              date: 'Kamis, 24 Okt 2024',
                              time: '08.00 - 16.00 ${LayananWaktu.zonaWaktu(_now)}',
                              shiftType: 'Shift Pagi',
                              status: 'Disetujui',
                              statusBg: successBg,
                              statusText: successText,
                              partner: 'Dimas Arya (Barista)',
                              reason: 'Jadwal Ujian Semester',
                              footerText: 'Disetujui oleh SPV Rian pada 22 Okt',
                              icon: Icons.coffee,
                            ),
                          if (_activeFilter == 'all' || _activeFilter == 'completed')
                            const SizedBox(height: 12),
                          if (_activeFilter == 'all' || _activeFilter == 'pending')
                            _buildHistoryCard(
                              date: 'Senin, 28 Okt 2024',
                              time: '12.00 - 20.00 ${LayananWaktu.zonaWaktu(_now)}',
                              shiftType: 'Shift Siang',
                              status: 'Menunggu SPV',
                              statusBg: warningBg,
                              statusText: warningText,
                              partner: 'Menggantikan Siti Sarah',
                              reason: 'Urusan Keluarga',
                              footerText: 'Telah disetujui rekan kerja, menunggu approval outlet lead',
                              icon: Icons.wb_sunny,
                            ),
                          if (_activeFilter == 'all' || _activeFilter == 'pending')
                            const SizedBox(height: 12),
                          if (_activeFilter == 'all' || _activeFilter == 'completed')
                            _buildHistoryCard(
                              date: 'Minggu, 13 Okt 2024',
                              time: '07.00 - 15.00 ${LayananWaktu.zonaWaktu(_now)}',
                              shiftType: 'Shift Pagi',
                              status: 'Ditolak',
                              statusBg: dangerBg,
                              statusText: dangerText,
                              partner: 'Kevin Pratama',
                              reason: 'Kebutuhan mendadak',
                              footerText: 'Slot kuota shift minimum outlet tidak terpenuhi',
                              icon: Icons.wb_twilight,
                              isError: true,
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: primaryLight.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: primary.withOpacity(0.2), width: 1),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.04),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                  child: Icon(Icons.add_circle, color: primary, size: 24),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Perlu Tukar Shift Lain?',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: textPrimary,
                                      ),
                                    ),
                                    Text(
                                      'Ajukan ke rekan satu outlet',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        color: textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Ajukan',
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
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
          ),
        ],
      ),
    ),
    bottomNavigationBar: BottomNavigationBar(
      currentIndex: 1,
      onTap: (index) {
        if (index == 0) {
          Navigator.pushReplacementNamed(context, '/home');
        } else if (index == 2) {
          Navigator.pushReplacementNamed(context, '/kasir');
        } else if (index == 3) {
          Navigator.pushReplacementNamed(context, '/profil');
        }
      },
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: primary,
      unselectedItemColor: textSecondary,
      selectedLabelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 11),
      unselectedLabelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w500, fontSize: 11),
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

  Widget _buildTabButton(String title, String filterKey) {
    bool isActive = _activeFilter == filterKey;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeFilter = filterKey),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ]
                : [],
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
              color: isActive ? primary : textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryCard({
    required String date,
    required String time,
    required String shiftType,
    required String status,
    required Color statusBg,
    required Color statusText,
    required String partner,
    required String reason,
    required String footerText,
    required IconData icon,
    bool isError = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderLight, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: borderLight, width: 1),
                    ),
                    child: Icon(icon, color: primary, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        date,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                        ),
                      ),
                      Text(
                        '$shiftType • $time',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: statusText,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      status,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: statusText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderLight, width: 1),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Partner:',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: textSecondary,
                      ),
                    ),
                    Text(
                      partner,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Alasan:',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: textSecondary,
                      ),
                    ),
                    Text(
                      reason,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                isError ? Icons.error_outline : Icons.verified_user_outlined,
                size: 15,
                color: isError ? dangerText : primary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  footerText,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isError ? dangerText : textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
