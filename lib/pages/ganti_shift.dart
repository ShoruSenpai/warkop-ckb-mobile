import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Session;

import '../services/session.dart';
import '../theme/app_theme.dart';

class ShiftScreen extends StatefulWidget {
  const ShiftScreen({super.key});

  @override
  State<ShiftScreen> createState() => _ShiftScreenState();
}

class _ShiftScreenState extends State<ShiftScreen> {
  String _activeFilter = 'all'; // 'all', 'pending', 'completed'
  final DateTime _now = DateTime.now();

  final Color primary = AppColors.primary;
  final Color primaryDark = AppColors.primaryDark;
  final Color primaryLight = AppColors.primaryLight;
  final Color secondary = AppColors.onSurfaceVariant;
  final Color surface = const Color(0xFFF8FAFC);
  final Color surfaceWhite = AppColors.surfaceContainerLowest;
  final Color textPrimary = AppColors.onSurface;
  final Color textSecondary = AppColors.secondary;
  final Color borderLight = AppColors.borderLight;
  final Color successBg = AppColors.successBg;
  final Color successText = const Color(0xFF15803D);
  final Color warningBg = AppColors.warningBg;
  final Color warningText = const Color(0xFFB45309);
  final Color dangerBg = AppColors.errorBg;
  final Color dangerText = const Color(0xFFB91C1C);

  bool _isLoading = true;
  List<Map<String, dynamic>> _coworkers = [];
  List<Map<String, dynamic>> _myUpcomingSchedules = [];

  // Permintaan masuk dari rekan kerja (bisa diterima / ditolak)
  List<Map<String, dynamic>> _incomingRequests = [];

  // Riwayat permohonan tukar shift
  List<Map<String, dynamic>> _swapHistory = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  String _formatDate(DateTime dt) {
    const days = ['', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${days[dt.weekday]}, ${dt.day} ${months[dt.month]} ${dt.year}';
  }

  String _formatFriendlyDate(String raw) {
    if (raw.isEmpty) return '';
    if (raw.contains(',')) return raw; // sudah diformat
    try {
      final parts = raw.split('-');
      if (parts.length == 3) {
        final dt = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
        return _formatDate(dt);
      }
    } catch (_) {}
    return raw;
  }

  String _fmtTime(String raw) {
    if (raw.isEmpty) return '';
    final parts = raw.split(':');
    if (parts.length >= 2) return '${parts[0]}.${parts[1]}';
    return raw;
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      final client = Supabase.instance.client;

      // Ambil data rekan kerja dari employees
      final empRows = await client
          .from('employees')
          .select('id, full_name, position, avatar_url')
          .eq('is_active', true)
          .order('full_name', ascending: true);

      final coworkers = List<Map<String, dynamic>>.from(empRows).where((e) {
        final id = int.tryParse(e['id'].toString()) ?? 0;
        final name = (e['full_name'] ?? '').toString().toLowerCase();
        return id != Session.employeeId && name != Session.name.toLowerCase();
      }).toList();

      // Ambil jadwal shift mendatang
      final todayStr = '${_now.year.toString().padLeft(4, '0')}-${_now.month.toString().padLeft(2, '0')}-${_now.day.toString().padLeft(2, '0')}';
      final endTarget = _now.add(const Duration(days: 21));
      final endStr = '${endTarget.year}-${endTarget.month.toString().padLeft(2, '0')}-${endTarget.day.toString().padLeft(2, '0')}';

      final schedRows = await client
          .from('employee_schedules')
          .select('id, schedule_date, shift_name, start_time, end_time')
          .eq('employee_id', Session.employeeId)
          .gte('schedule_date', todayStr)
          .lte('schedule_date', endStr)
          .order('schedule_date', ascending: true);

      final mySchedules = List<Map<String, dynamic>>.from(schedRows).where((s) {
        final sName = (s['shift_name'] ?? '').toString().toLowerCase();
        final sStart = (s['start_time'] ?? '').toString();
        return !sName.contains('libur') && !sName.contains('off') && !sStart.startsWith('00:00');
      }).toList();

      final firstPartner = coworkers.isNotEmpty
          ? coworkers.first
          : {'full_name': 'Budi Santoso', 'position': 'Floor Staff & Kasir'};
      final tomorrow = _now.add(const Duration(days: 1));

      setState(() {
        _coworkers = coworkers;
        _myUpcomingSchedules = mySchedules;
        _incomingRequests = [
          {
            'id': 'inc-1',
            'partner_name': firstPartner['full_name'] ?? 'Budi Santoso',
            'partner_role': firstPartner['position'] ?? 'Floor Staff & Kasir',
            'date': _formatDate(tomorrow),
            'target_shift': 'Shift Siang (12.00 - 20.00 WIB)',
            'swap_with': 'Shift Pagi Maya (08.00 - 16.00 WIB)',
            'reason': 'Ada jadwal praktikum kuliah mendadak jam 13.00, minta tolong gantikan shift siang.',
            'created_at': 'Baru saja',
            'status': 'pending', // 'pending', 'accepted', 'declined'
          }
        ];
        _swapHistory = [
          {
            'id': 'hist-1',
            'date': _formatDate(_now.subtract(const Duration(days: 3))),
            'time': '08.00 - 16.00 WIB',
            'shiftType': 'Shift Pagi',
            'status': 'Disetujui',
            'statusBg': successBg,
            'statusText': successText,
            'partner': 'Dimas Anggara (Barista Lead)',
            'reason': 'Jadwal bimbingan skripsi / magang',
            'footerText': 'Disetujui bersama Dimas Anggara (Jadwal Langsung Ditukar)',
            'icon': Icons.coffee_rounded,
            'isError': false,
            'category': 'completed',
          },
          {
            'id': 'hist-2',
            'date': _formatDate(_now.subtract(const Duration(days: 6))),
            'time': '12.00 - 20.00 WIB',
            'shiftType': 'Shift Siang',
            'status': 'Disetujui',
            'statusBg': successBg,
            'statusText': successText,
            'partner': 'Siti Rahma (Barista & Server)',
            'reason': 'Keperluan keluarga di luar kota',
            'footerText': 'Disetujui bersama Siti Rahma (Jadwal Langsung Ditukar)',
            'icon': Icons.wb_sunny_rounded,
            'isError': false,
            'category': 'completed',
          },
        ];
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading shift swap data: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleIncomingAction(String id, bool accept) {
    setState(() {
      final idx = _incomingRequests.indexWhere((r) => r['id'] == id);
      if (idx != -1) {
        _incomingRequests[idx]['status'] = accept ? 'accepted' : 'declined';

        final item = _incomingRequests[idx];
        _swapHistory.insert(0, {
          'id': 'hist-${DateTime.now().millisecondsSinceEpoch}',
          'date': item['date'],
          'time': item['target_shift'],
          'shiftType': 'Tukar Shift',
          'status': accept ? 'Disetujui' : 'Ditolak',
          'statusBg': accept ? successBg : dangerBg,
          'statusText': accept ? successText : dangerText,
          'partner': item['partner_name'],
          'reason': item['reason'],
          'footerText': accept
              ? 'Telah disetujui & disinkronkan ke jadwal outlet'
              : 'Permintaan telah ditolak oleh Anda',
          'icon': accept ? Icons.sync_rounded : Icons.cancel_outlined,
          'isError': !accept,
          'category': 'completed',
        });
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          accept
              ? 'Permintaan berhasil disetujui! Jadwal shift otomatis disinkronkan.'
              : 'Permintaan pergantian shift telah ditolak.',
        ),
        backgroundColor: accept ? successText : dangerText,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showCreateSwapModal() {
    if (_coworkers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Memuat data rekan kerja, silakan coba sesaat lagi...')),
      );
      return;
    }

    Map<String, dynamic>? selectedSchedule = _myUpcomingSchedules.isNotEmpty ? _myUpcomingSchedules.first : null;
    Map<String, dynamic> selectedPartner = _coworkers.first;
    final TextEditingController reasonController = TextEditingController();
    String quickReason = 'Keperluan Keluarga Mendesak';

    final quickChips = [
      'Keperluan Keluarga Mendesak',
      'Jadwal Kuliah / Praktikum',
      'Kondisi Medis / Kurang Sehat',
      'Kendala Transportasi',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateModal) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                left: 20,
                right: 20,
                top: 16,
              ),
              decoration: BoxDecoration(
                color: surfaceWhite,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 28,
                    offset: const Offset(0, -6),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 42,
                        height: 5,
                        decoration: BoxDecoration(
                          color: borderLight,
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
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: primaryLight,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.sync_alt_rounded, color: primary, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('FORMULIR PENGAJUAN', style: AppTextStyles.overline.copyWith(color: primary, letterSpacing: 1)),
                                Text('Ajukan Tukar Shift', style: AppTextStyles.h2),
                              ],
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, size: 22),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Pilihan shift sendiri
                    Text('1. Shift Saya yang Ingin Ditukar', style: AppTextStyles.bodyBold),
                    const SizedBox(height: 8),
                    if (_myUpcomingSchedules.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(
                          color: surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: borderLight),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<Map<String, dynamic>>(
                            value: selectedSchedule,
                            isExpanded: true,
                            icon: Icon(Icons.keyboard_arrow_down_rounded, color: primary),
                            items: _myUpcomingSchedules.map((s) {
                              final dRaw = (s['schedule_date'] ?? '').toString();
                              final dFmt = _formatFriendlyDate(dRaw);
                              final sName = (s['shift_name'] ?? 'Shift Kerja').toString();
                              final sStart = _fmtTime(s['start_time']?.toString() ?? '');
                              final sEnd = _fmtTime(s['end_time']?.toString() ?? '');
                              return DropdownMenuItem<Map<String, dynamic>>(
                                value: s,
                                child: Text(
                                  '$dFmt • $sName ($sStart - $sEnd)',
                                  style: AppTextStyles.body,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setStateModal(() => selectedSchedule = val);
                            },
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: borderLight),
                        ),
                        child: Text(
                          'Jadwal Shift Pagi/Siang/Malam Anda dalam 14 hari ke depan',
                          style: AppTextStyles.body.copyWith(color: secondary),
                        ),
                      ),

                    const SizedBox(height: 18),

                    // Pilihan rekan pengganti
                    Text('2. Pilih Rekan Kerja Pengganti', style: AppTextStyles.bodyBold),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderLight),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<Map<String, dynamic>>(
                          value: selectedPartner,
                          isExpanded: true,
                          icon: Icon(Icons.keyboard_arrow_down_rounded, color: primary),
                          items: _coworkers.map((c) {
                            final name = (c['full_name'] ?? 'Rekan Kerja').toString();
                            final pos = (c['position'] ?? 'Staff').toString();
                            return DropdownMenuItem<Map<String, dynamic>>(
                              value: c,
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 12,
                                    backgroundColor: primaryLight,
                                    child: Text(
                                      name.isNotEmpty ? name[0] : 'C',
                                      style: AppTextStyles.captionBold.copyWith(color: primary, fontSize: 11),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      '$name • $pos',
                                      style: AppTextStyles.body,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setStateModal(() => selectedPartner = val);
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Alasan tukar shift
                    Text('3. Alasan Permohonan Tukar Shift', style: AppTextStyles.bodyBold),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: quickChips.map((chip) {
                        final isSelected = quickReason == chip;
                        return ChoiceChip(
                          label: Text(chip),
                          selected: isSelected,
                          onSelected: (val) {
                            if (val) {
                              setStateModal(() {
                                quickReason = chip;
                                reasonController.text = chip;
                              });
                            }
                          },
                          selectedColor: primaryLight,
                          backgroundColor: surface,
                          labelStyle: AppTextStyles.captionBold.copyWith(
                            color: isSelected ? primary : textSecondary,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: isSelected ? primary : borderLight),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: reasonController..text = (reasonController.text.isEmpty ? quickReason : reasonController.text),
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: 'Tuliskan alasan detail...',
                        hintStyle: AppTextStyles.body.copyWith(color: secondary.withOpacity(0.6)),
                        filled: true,
                        fillColor: surface,
                        contentPadding: const EdgeInsets.all(14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: borderLight),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: primary, width: 1.5),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Tombol kirim
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          final partnerName = (selectedPartner['full_name'] ?? 'Rekan Kerja').toString();
                          final reasonText = reasonController.text.trim().isNotEmpty
                              ? reasonController.text.trim()
                              : quickReason;

                          final schedDateRaw = selectedSchedule != null
                              ? (selectedSchedule!['schedule_date'] ?? '')
                              : '';
                          final schedDateFmt = _formatFriendlyDate(schedDateRaw.toString());
                          final schedName = selectedSchedule != null
                              ? (selectedSchedule!['shift_name'] ?? 'Shift Kerja')
                              : 'Shift Kerja';

                          setState(() {
                            _swapHistory.insert(0, {
                              'id': 'hist-${DateTime.now().millisecondsSinceEpoch}',
                              'date': schedDateFmt.isNotEmpty ? schedDateFmt : _formatDate(_now.add(const Duration(days: 1))),
                              'time': 'Menunggu konfirmasi rekan',
                              'shiftType': schedName.toString(),
                              'status': 'Menunggu',
                              'statusBg': warningBg,
                              'statusText': warningText,
                              'partner': partnerName,
                              'reason': reasonText,
                              'footerText': 'Permintaan diajukan ke $partnerName, menunggu persetujuan rekan',
                              'icon': Icons.hourglass_top_rounded,
                              'isError': false,
                              'category': 'pending',
                            });
                          });

                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Permintaan tukar shift berhasil dikirim ke $partnerName!'),
                              backgroundColor: primary,
                              duration: const Duration(seconds: 3),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'Kirim Permohonan Tukar Shift',
                          style: AppTextStyles.button.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
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
    // Filter riwayat
    final filteredHistory = _swapHistory.where((item) {
      if (_activeFilter == 'all') return true;
      if (_activeFilter == 'pending') return item['category'] == 'pending';
      if (_activeFilter == 'completed') return item['category'] == 'completed';
      return true;
    }).toList();

    final pendingCount = _incomingRequests.where((r) => r['status'] == 'pending').length +
        _swapHistory.where((r) => r['category'] == 'pending').length;
    final completedCount = _swapHistory.where((r) => r['category'] == 'completed').length;
    final totalCount = _incomingRequests.length + _swapHistory.length;

    final showIncoming = _activeFilter != 'completed';

    return Scaffold(
      backgroundColor: primary,
      body: SafeArea(
        top: false,
        bottom: false,
        child: Container(
          color: Colors.white,
          child: Column(
          children: [
            // Header halaman
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 12,
                left: 20,
                right: 20,
                bottom: 24,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primary, primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
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
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.35),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.arrow_back_ios_new_rounded, size: 14, color: Colors.white),
                              const SizedBox(width: 6),
                              Text(
                                'Kembali',
                                style: AppTextStyles.subtitle.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.35),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.event_note_rounded, size: 14, color: Colors.white),
                            const SizedBox(width: 6),
                            Text(
                              _formatDate(_now),
                              style: AppTextStyles.subtitle.copyWith(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: (Session.avatarUrl.isNotEmpty)
                              ? Image.network(
                                  Session.avatarUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(Icons.person, color: Colors.grey, size: 32),
                                )
                              : Image.asset(
                                  'assets/images/logo_cak_kebo.png',
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(Icons.person, color: Colors.grey, size: 32),
                                ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Halo, ${Session.name.isNotEmpty ? Session.name.split(' ').first : 'Karyawan'}!',
                              style: AppTextStyles.h1.copyWith(color: Colors.white, fontSize: 22),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Kelola permohonan & jadwal tukar shift Anda',
                              style: AppTextStyles.body.copyWith(color: Colors.white.withOpacity(0.92)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Konten halaman
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
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Tab filter
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: surface,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: borderLight, width: 1),
                                ),
                                child: Row(
                                  children: [
                                    _buildTabButton('Semua', 'all', totalCount),
                                    _buildTabButton('Menunggu', 'pending', pendingCount),
                                    _buildTabButton('Selesai', 'completed', completedCount),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Tombol ajukan tukar shift
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [primaryLight.withOpacity(0.7), primaryLight.withOpacity(0.25)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(color: primary.withOpacity(0.2), width: 1.2),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 44,
                                            height: 44,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.06),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Icon(Icons.sync_alt_rounded, color: primary, size: 24),
                                          ),
                                          const SizedBox(width: 14),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text('Perlu Tukar Shift?', style: AppTextStyles.h3.copyWith(fontSize: 15)),
                                                const SizedBox(height: 2),
                                                Text(
                                                  'Tukar jadwal rekan',
                                                  style: AppTextStyles.body.copyWith(fontSize: 12, color: textSecondary),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: _showCreateSwapModal,
                                      icon: const Icon(Icons.add_rounded, size: 16),
                                      label: Text(
                                        'Ajukan',
                                        style: AppTextStyles.captionBold.copyWith(color: Colors.white),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: primary,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Daftar permintaan masuk
                              if (showIncoming && _incomingRequests.isNotEmpty) ...[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'PERMINTAAN MASUK',
                                          style: AppTextStyles.cardTitle.copyWith(letterSpacing: 0.5),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: primaryLight,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            '${_incomingRequests.where((r) => r['status'] == 'pending').length} Baru',
                                            style: AppTextStyles.captionBold.copyWith(color: primary, fontSize: 11),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      'Warkop Cak Kebo',
                                      style: AppTextStyles.caption.copyWith(color: textSecondary),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                ..._incomingRequests.map((req) {
                                  final reqStatus = req['status'] as String;
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    padding: const EdgeInsets.all(18),
                                    decoration: BoxDecoration(
                                      color: surfaceWhite,
                                      borderRadius: BorderRadius.circular(22),
                                      border: Border.all(color: borderLight, width: 1.2),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.03),
                                          blurRadius: 10,
                                          offset: const Offset(0, 3),
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
                                                CircleAvatar(
                                                  radius: 20,
                                                  backgroundColor: primaryLight,
                                                  child: Text(
                                                    (req['partner_name'] ?? 'B')[0],
                                                    style: AppTextStyles.h3.copyWith(color: primary, fontSize: 16),
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(req['partner_name'] ?? 'Budi Santoso', style: AppTextStyles.h3),
                                                    Text(req['partner_role'] ?? 'Floor Staff & Kasir', style: AppTextStyles.body.copyWith(fontSize: 13)),
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
                                                  Icon(Icons.schedule_rounded, size: 12, color: textSecondary),
                                                  const SizedBox(width: 4),
                                                  Text(req['created_at'] ?? 'Baru saja', style: AppTextStyles.caption),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 14),
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(14),
                                          decoration: BoxDecoration(
                                            color: surface,
                                            borderRadius: BorderRadius.circular(16),
                                            border: Border.all(color: borderLight, width: 0.8),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Icon(Icons.event_repeat_rounded, color: primary, size: 16),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    'Shift yang ingin ditukar:',
                                                    style: AppTextStyles.captionBold.copyWith(color: primary),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                '${req['date']} • ${req['target_shift']}',
                                                style: AppTextStyles.bodyBold,
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Icon(Icons.format_quote_rounded, size: 15, color: primary.withOpacity(0.5)),
                                                  const SizedBox(width: 6),
                                                  Expanded(
                                                    child: Text(
                                                      '“${req['reason']}”',
                                                      style: AppTextStyles.body.copyWith(
                                                        fontStyle: FontStyle.italic,
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 14),
                                        if (reqStatus == 'pending')
                                          Row(
                                            children: [
                                              Expanded(
                                                child: OutlinedButton(
                                                  style: OutlinedButton.styleFrom(
                                                    backgroundColor: surface,
                                                    foregroundColor: textPrimary,
                                                    side: BorderSide(color: borderLight, width: 1.2),
                                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(14),
                                                    ),
                                                  ),
                                                  onPressed: () => _handleIncomingAction(req['id'], false),
                                                  child: Text(
                                                    'Tolak',
                                                    style: AppTextStyles.button.copyWith(color: dangerText),
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
                                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(14),
                                                    ),
                                                  ),
                                                  onPressed: () => _handleIncomingAction(req['id'], true),
                                                  child: Text(
                                                    'Terima',
                                                    style: AppTextStyles.button.copyWith(color: Colors.white),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )
                                        else
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                            decoration: BoxDecoration(
                                              color: reqStatus == 'accepted' ? successBg : dangerBg,
                                              borderRadius: BorderRadius.circular(14),
                                            ),
                                            alignment: Alignment.center,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  reqStatus == 'accepted' ? Icons.check_circle_rounded : Icons.cancel_rounded,
                                                  size: 16,
                                                  color: reqStatus == 'accepted' ? successText : dangerText,
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    reqStatus == 'accepted'
                                                        ? 'Permintaan telah disetujui! Jadwal shift otomatis disinkronkan.'
                                                        : 'Permintaan pergantian shift telah ditolak.',
                                                    style: AppTextStyles.bodyBold.copyWith(
                                                      color: reqStatus == 'accepted' ? successText : dangerText,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                  );
                                }),
                                const SizedBox(height: 12),
                              ],

                              // Daftar riwayat pengajuan
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'RIWAYAT PENGAJUAN',
                                        style: AppTextStyles.cardTitle.copyWith(letterSpacing: 0.5),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '(${filteredHistory.length})',
                                        style: AppTextStyles.body.copyWith(color: textSecondary),
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
                                        Icon(Icons.calendar_month_rounded, size: 13, color: primary),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Bulan Ini',
                                          style: AppTextStyles.captionBold.copyWith(color: primary),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              if (filteredHistory.isEmpty)
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                                  decoration: BoxDecoration(
                                    color: surface,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: borderLight),
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(Icons.inbox_outlined, size: 36, color: secondary.withOpacity(0.5)),
                                      const SizedBox(height: 10),
                                      Text(
                                        'Belum ada riwayat pada kategori ini',
                                        style: AppTextStyles.body.copyWith(color: secondary),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                Column(
                                  children: filteredHistory.map((item) {
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 12),
                                      child: _buildHistoryCard(
                                        date: _formatFriendlyDate(item['date'] ?? ''),
                                        time: item['time'] ?? '',
                                        shiftType: item['shiftType'] ?? 'Shift Kerja',
                                        status: item['status'] ?? 'Menunggu',
                                        statusBg: item['statusBg'] ?? warningBg,
                                        statusText: item['statusText'] ?? warningText,
                                        partner: item['partner'] ?? '-',
                                        reason: item['reason'] ?? '-',
                                        footerText: item['footerText'] ?? '',
                                        icon: (item['icon'] as IconData?) ?? Icons.coffee_rounded,
                                        isError: item['isError'] == true,
                                      ),
                                    );
                                  }).toList(),
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
      ),
    );
  }

  Widget _buildTabButton(String title, String filterKey, int count) {
    bool isActive = _activeFilter == filterKey;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeFilter = filterKey),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: (isActive ? AppTextStyles.bodyBold : AppTextStyles.subtitle).copyWith(
                  color: isActive ? primary : textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                decoration: BoxDecoration(
                  color: isActive ? primaryLight : borderLight.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: AppTextStyles.captionBold.copyWith(
                    color: isActive ? primary : textSecondary,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Row(
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            date,
                            style: AppTextStyles.h4.copyWith(fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 1),
                          Text(
                            '$shiftType • $time',
                            style: AppTextStyles.caption.copyWith(fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
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
                      style: AppTextStyles.captionBold.copyWith(color: statusText, fontSize: 11),
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
              border: Border.all(color: borderLight, width: 0.8),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Partner:',
                      style: AppTextStyles.body.copyWith(color: textSecondary, fontSize: 13),
                    ),
                    Flexible(
                      child: Text(
                        partner,
                        style: AppTextStyles.bodyBold.copyWith(fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Alasan:',
                      style: AppTextStyles.body.copyWith(color: textSecondary, fontSize: 13),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        reason,
                        textAlign: TextAlign.right,
                        style: AppTextStyles.body.copyWith(color: textPrimary, fontSize: 13),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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
                isError ? Icons.error_outline_rounded : Icons.verified_user_outlined,
                size: 15,
                color: isError ? dangerText : primary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  footerText,
                  style: AppTextStyles.caption.copyWith(
                    color: isError ? dangerText : textSecondary,
                    fontSize: 11,
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
