import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../services/layanan_waktu.dart';

class JadwalScreen extends StatefulWidget {
  const JadwalScreen({super.key});

  @override
  State<JadwalScreen> createState() => _JadwalScreenState();
}

class _JadwalScreenState extends State<JadwalScreen> {
  late final DateTime _hariIni = LayananWaktu.sekarang();
  late final DateTime _awalPekan = DateTime(
    _hariIni.year,
    _hariIni.month,
    _hariIni.day,
  ).subtract(Duration(days: _hariIni.weekday - 1));
  late int _selectedDayIndex = _hariIni.weekday - 1;

  late final List<Map<String, dynamic>> _weekDays = List.generate(7, (index) {
    const namaHari = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    const statusHari = ['work', 'work', 'work', 'active', 'work', 'off', 'work'];
    final tanggal = _awalPekan.add(Duration(days: index));
    return {
      'day': namaHari[index],
      'date': tanggal.day,
      'status': statusHari[index],
    };
  });

  DateTime get _tanggalTerpilih =>
      _awalPekan.add(Duration(days: _selectedDayIndex));

  String get _rentangPekan {
    final akhirPekan = _awalPekan.add(const Duration(days: 6));
    final awal = DateFormat('d MMM', 'id_ID').format(_awalPekan);
    final akhir = DateFormat('d MMM yyyy', 'id_ID').format(akhirPekan);
    return 'Pekan ini ($awal - $akhir)';
  }

  final Color primary = const Color(0xFF2563EB);
  final Color primaryDark = const Color(0xFF1D4ED8);
  final Color primaryLight = const Color(0xFFDBEAFE);
  final Color secondary = const Color(0xFF64748B);
  final Color surface = const Color(0xFFF4F6FB);
  final Color surfaceContainerLowest = const Color(0xFFFFFFFF);
  final Color surfaceContainerLow = const Color(0xFFEFF6FF);
  final Color surfaceContainer = const Color(0xFFE0EDFF);
  final Color surfaceContainerHigh = const Color(0xFFDBEAFE);
  final Color surfaceContainerHighest = const Color(0xFFBFDBFE);
  final Color onSurface = const Color(0xFF0F172A);
  final Color onSurfaceVariant = const Color(0xFF475569);
  final Color onPrimary = const Color(0xFFFFFFFF);
  final Color borderLight = const Color(0xFFE2E8F0);

  void _showSwapModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        String selectedReplacement = 'Dimas Arya';
        TextEditingController reasonController = TextEditingController();

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateModal) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 12,
              ),
              decoration: BoxDecoration(
                color: surfaceContainerLowest,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 30,
                    offset: const Offset(0, -5),
                  )
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 6,
                        decoration: BoxDecoration(
                          color: borderLight,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.sync_alt, color: primary, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  'FORMULIR INTERNAL',
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: primary,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Ajukan Tukar Shift',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: onSurface,
                              ),
                            ),
                            Text(
                              'Shift Pagi • ${DateFormat('EEEE, d MMM', 'id_ID').format(_tanggalTerpilih)} (08.00 - 16.00 ${LayananWaktu.zonaWaktu(_tanggalTerpilih)})',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: secondary,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          style: IconButton.styleFrom(
                            backgroundColor: surfaceContainerLow,
                            foregroundColor: onSurfaceVariant,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Pilih Rekan Kerja Pengganti',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: surfaceContainerLow,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderLight, width: 1),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search, color: secondary, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Cari nama barista / kasir...',
                                hintStyle: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  color: secondary.withOpacity(0.6),
                                ),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Rekomendasi Staf Hari Ini (Off):',
                      style: GoogleFonts.plusJakartaSans(fontSize: 11, color: secondary),
                    ),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: () => setStateModal(() => selectedReplacement = 'Dimas Arya'),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: surfaceContainerLow,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: borderLight, width: 1),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: primaryLight,
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'DA',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: primary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Dimas Arya',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: onSurface,
                                      ),
                                    ),
                                    Text(
                                      'Barista • Status: Off',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Radio<String>(
                              value: 'Dimas Arya',
                              groupValue: selectedReplacement,
                              activeColor: primary,
                              onChanged: (val) => setStateModal(() => selectedReplacement = val!),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => setStateModal(() => selectedReplacement = 'Siti Sarah'),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: surfaceContainerLow,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: borderLight, width: 1),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: surfaceContainerHigh,
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'SS',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: secondary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Siti Sarah',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: onSurface,
                                      ),
                                    ),
                                    Text(
                                      'Floor Staff • Status: Off',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11,
                                        color: secondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Radio<String>(
                              value: 'Siti Sarah',
                              groupValue: selectedReplacement,
                              activeColor: primary,
                              onChanged: (val) => setStateModal(() => selectedReplacement = val!),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Alasan Pergantian',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: ['Urusan Keluarga', 'Jadwal Kuliah / Ujian', 'Kurang Sehat']
                          .map((reason) => ActionChip(
                                label: Text(reason),
                                labelStyle: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: onSurfaceVariant,
                                ),
                                backgroundColor: surfaceContainerLow,
                                side: BorderSide(color: borderLight, width: 1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                onPressed: () {
                                  reasonController.text = reason;
                                },
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: reasonController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: 'Tuliskan catatan tambahan untuk Supervisor...',
                        hintStyle: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: secondary.withOpacity(0.6),
                        ),
                        filled: true,
                        fillColor: surfaceContainerLow,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: borderLight, width: 1),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: borderLight, width: 1),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: surfaceContainerHigh.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: primaryLight, width: 1),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: primary, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Pengajuan akan diteruskan ke Supervisor Outlet untuk disetujui paling lambat H-1 shift.',
                              style: GoogleFonts.plusJakartaSans(fontSize: 11, color: secondary),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              backgroundColor: surfaceContainerLow,
                              foregroundColor: onSurface,
                              side: BorderSide(color: borderLight, width: 1),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'Batal',
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
                              foregroundColor: onPrimary,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Pengajuan tukar shift berhasil dikirim!'),
                                ),
                              );
                            },
                            child: Text(
                              'Kirim Pengajuan',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primary,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 12, 16, 20),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                    onPressed: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      } else {
                        Navigator.pushReplacementNamed(context, '/home');
                      }
                    },
                  ),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.35),
                        width: 1.2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(13),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Image.asset(
                          'assets/images/logo_cak_kebo_transparent.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'CAK KEBO',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                            height: 1.1,
                            color: Colors.white.withOpacity(0.85),
                          ),
                        ),
                        Text(
                          'Jadwal Staf',
                          style: GoogleFonts.poppins(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            height: 1.15,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.35),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: Color(0xFF4ADE80),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'SHIFT AKTIF',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.8,
                          ),
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
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: const BorderRadius.only(
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
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Cak Kebo Senopati',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: primary,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Jadwal Kerja Saya',
                                  style: GoogleFonts.poppins(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: onSurface,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: surfaceContainerLowest,
                                shape: BoxShape.circle,
                                border: Border.all(color: borderLight, width: 1),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              child: Icon(Icons.event_available, color: primary, size: 22),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: borderLight, width: 1),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Row(
                                  children: [
                                    Icon(Icons.calendar_today, size: 16, color: primary),
                                    const SizedBox(width: 8),
                                    Text(
                                      LayananWaktu.formatBulanIndonesia(_hariIni),
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: surfaceContainerLowest,
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.04),
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        'Minggu Ini',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: primary,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      child: Text(
                                        'Bulan',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: secondary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _rentangPekan,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: onSurfaceVariant,
                              ),
                            ),
                            Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(color: primary, shape: BoxShape.circle),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '5 Hari Kerja',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: primary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: List.generate(_weekDays.length, (index) {
                            final item = _weekDays[index];
                            bool isSelected = _selectedDayIndex == index;
                            bool isOff = item['status'] == 'off';

                            return Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _selectedDayIndex = index),
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 2),
                                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? primary
                                        : isOff
                                            ? surfaceContainerLow.withOpacity(0.7)
                                            : surfaceContainerLowest,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isSelected ? primary : borderLight,
                                      width: 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: isSelected
                                            ? primary.withOpacity(0.25)
                                            : Colors.black.withOpacity(0.02),
                                        blurRadius: isSelected ? 8 : 4,
                                        offset: Offset(0, isSelected ? 3 : 1),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        item['day'],
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: isSelected
                                              ? onPrimary.withOpacity(0.9)
                                              : isOff
                                                  ? secondary.withOpacity(0.6)
                                                  : secondary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item['date'].toString(),
                                        style: GoogleFonts.poppins(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: isSelected
                                              ? onPrimary
                                              : isOff
                                                  ? secondary.withOpacity(0.6)
                                                  : onSurface,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? surfaceContainerLowest
                                              : isOff
                                                  ? Colors.transparent
                                                  : primary,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: borderLight, width: 1.2),
                            boxShadow: [
                              BoxShadow(
                                color: primary.withOpacity(0.06),
                                blurRadius: 20,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _selectedDayIndex == _hariIni.weekday - 1
                                          ? 'HARI INI'
                                          : 'JADWAL TERPILIH',
                                        style: GoogleFonts.poppins(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: secondary,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                      Text(
                                        LayananWaktu.formatTanggalIndonesia(
                                          _tanggalTerpilih,
                                        ),
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: onSurface,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: primaryLight,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 7,
                                          height: 7,
                                          decoration: BoxDecoration(
                                            color: primary,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          'Shift Aktif',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: primary,
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
                                  color: surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: borderLight, width: 1),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: surfaceContainerLowest,
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: borderLight, width: 0.8),
                                          ),
                                          child: Icon(Icons.local_cafe, color: primary, size: 20),
                                        ),
                                        const SizedBox(width: 12),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Shift Pagi',
                                              style: GoogleFonts.poppins(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                                color: onSurface,
                                              ),
                                            ),
                                            Text(
                                              'Opening Floor & Barista Lead',
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 12,
                                                color: secondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.baseline,
                                      textBaseline: TextBaseline.alphabetic,
                                      children: [
                                        Text(
                                          '08.00',
                                          style: GoogleFonts.poppins(
                                            fontSize: 28,
                                            fontWeight: FontWeight.w700,
                                            color: primary,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 6),
                                          child: Text(
                                            '-',
                                            style: GoogleFonts.poppins(
                                              fontSize: 20,
                                              color: secondary,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          '16.00',
                                          style: GoogleFonts.poppins(
                                            fontSize: 28,
                                            fontWeight: FontWeight.w700,
                                            color: primary,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          LayananWaktu.zonaWaktu(_hariIni),
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: secondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(Icons.storefront, color: primary, size: 16),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Cak Kebo - Outlet Senopati • Bar Station 01',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'REKAN SHIFT SEJADWAL (2)',
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: secondary,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: surfaceContainerLow,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: borderLight, width: 0.8),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 30,
                                            height: 30,
                                            decoration: BoxDecoration(
                                              color: primaryLight,
                                              shape: BoxShape.circle,
                                            ),
                                            alignment: Alignment.center,
                                            child: Text(
                                              'BP',
                                              style: GoogleFonts.poppins(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                                color: primary,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Bagas P.',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w700,
                                                  color: onSurface,
                                                ),
                                              ),
                                              Text(
                                                'Kasir',
                                                style: GoogleFonts.plusJakartaSans(
                                                  fontSize: 10,
                                                  color: secondary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: surfaceContainerLow,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: borderLight, width: 0.8),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 30,
                                            height: 30,
                                            decoration: BoxDecoration(
                                              color: surfaceContainerHigh,
                                              shape: BoxShape.circle,
                                            ),
                                            alignment: Alignment.center,
                                            child: Text(
                                              'RK',
                                              style: GoogleFonts.poppins(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                                color: primaryDark,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Rina K.',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w700,
                                                  color: onSurface,
                                                ),
                                              ),
                                              Text(
                                                'Kitchen',
                                                style: GoogleFonts.plusJakartaSans(
                                                  fontSize: 10,
                                                  color: secondary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () => _showSwapModal(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primary,
                                  foregroundColor: onPrimary,
                                  elevation: 0,
                                  minimumSize: const Size(double.infinity, 52),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.swap_horizontal_circle, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Ajukan Pergantian Shift',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Shift Mendatang',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: onSurface,
                              ),
                            ),
                            Text(
                              'Pekan Ini',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Column(
                          children: [
                            _buildUpcomingShiftCard(
                              _weekDays[4]['day'] as String,
                              _weekDays[4]['date'].toString(),
                              'Shift Siang (Closing)',
                              '14.00 - 22.00 ${LayananWaktu.zonaWaktu(_hariIni)} • Bar Station',
                              false,
                            ),
                            const SizedBox(height: 8),
                            _buildUpcomingShiftCard(
                              _weekDays[5]['day'] as String,
                              _weekDays[5]['date'].toString(),
                              'Hari Libur Mingguan',
                              'Day Off Terjadwal',
                              true,
                            ),
                            const SizedBox(height: 8),
                            _buildUpcomingShiftCard(
                              _weekDays[6]['day'] as String,
                              _weekDays[6]['date'].toString(),
                              'Shift Pagi (Weekend)',
                              '07.30 - 15.30 ${LayananWaktu.zonaWaktu(_hariIni)} • Cashier Lead',
                              false,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
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
        unselectedItemColor: secondary,
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

  Widget _buildUpcomingShiftCard(
    String day,
    String date,
    String title,
    String subtitle,
    bool isOff,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderLight, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isOff ? surfaceContainerLow : primaryLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      day,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: isOff ? secondary.withOpacity(0.6) : primary,
                      ),
                    ),
                    Text(
                      date,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isOff ? secondary.withOpacity(0.6) : onSurface,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: secondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          isOff
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Off',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: secondary,
                    ),
                  ),
                )
              : Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: surfaceContainerLow,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.chevron_right, color: primary, size: 18),
                ),
        ],
      ),
    );
  }
}
