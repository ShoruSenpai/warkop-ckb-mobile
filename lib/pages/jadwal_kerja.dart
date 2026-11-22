import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Session;

import '../services/session.dart';
import '../theme/app_theme.dart';
import 'main_tab_screen.dart';

class JadwalScreen extends StatefulWidget {
  const JadwalScreen({super.key});

  @override
  State<JadwalScreen> createState() => _JadwalScreenState();
}

class _JadwalScreenState extends State<JadwalScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  static const List<String> _daysFull = [
    '',
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];

  static const List<String> _monthsFull = [
    '',
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  static const List<String> _monthsShort = [
    '',
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  late DateTime _currentWeekMonday;
  late List<Map<String, dynamic>> _weekDays;
  late int _selectedDayIndex;
  List<Map<String, dynamic>> _coworkers = [];
  String _viewMode = 'minggu'; // 'minggu' or 'bulan'
  DateTime _selectedMonthDate = DateTime.now();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _pendingSwaps = [];
  Map<String, Map<String, dynamic>> _schedulesByDate = {};
  Map<String, Map<String, dynamic>> _attendancesByDate = {};

  Map<String, dynamic>? _getAttendanceFor(DateTime date) {
    final key = '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return _attendancesByDate[key];
  }

  bool _isShiftExpiredForDate(DateTime date, Map<String, dynamic>? sched) {
    if (sched == null || sched['is_off'] == true) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(date.year, date.month, date.day);
    if (d.isBefore(today)) return true;
    if (d.isAfter(today)) return false;
    final rawEnd = (sched['raw_end'] ?? sched['end_time'] ?? '').toString();
    if (rawEnd.isEmpty) return now.hour >= 16;
    final parts = rawEnd.replaceAll('.', ':').split(':');
    final eh = int.tryParse(parts[0]) ?? 16;
    final em = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
    final shiftEnd = DateTime(now.year, now.month, now.day, eh, em);
    return now.isAfter(shiftEnd);
  }

  Map<String, dynamic>? _getScheduleFor(DateTime date) {
    final key = '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    if (_schedulesByDate.containsKey(key)) {
      return _schedulesByDate[key];
    }
    return null;
  }

  Future<void> _loadSchedules() async {
    try {
      final client = Supabase.instance.client;
      final startRange = _currentWeekMonday.subtract(const Duration(days: 90));
      final endRange = _currentWeekMonday.add(const Duration(days: 90));
      final startStr = '${startRange.year.toString().padLeft(4, '0')}-${startRange.month.toString().padLeft(2, '0')}-${startRange.day.toString().padLeft(2, '0')}';
      final endStr = '${endRange.year.toString().padLeft(4, '0')}-${endRange.month.toString().padLeft(2, '0')}-${endRange.day.toString().padLeft(2, '0')}';

      final rows = await client
          .from('employee_schedules')
          .select('id, employee_id, schedule_date, shift_name, start_time, end_time')
          .eq('employee_id', Session.employeeId)
          .gte('schedule_date', startStr)
          .lte('schedule_date', endStr);

      final attRows = await client
          .from('attendances')
          .select('attendance_date, clock_in, clock_out, status')
          .eq('employee_id', Session.employeeId)
          .gte('attendance_date', startStr)
          .lte('attendance_date', endStr);

      final Map<String, Map<String, dynamic>> attMap = {};
      for (final a in attRows) {
        final d = (a['attendance_date'] ?? '').toString();
        if (d.isNotEmpty) attMap[d] = a;
      }

      final Map<String, Map<String, dynamic>> loaded = {};
      for (final r in rows) {
        final dateStr = (r['schedule_date'] ?? '').toString();
        final rawShift = (r['shift_name'] ?? '').toString();
        final rawStart = (r['start_time'] ?? '').toString();
        final rawEnd = (r['end_time'] ?? '').toString();
        final isOff = rawShift.toLowerCase().contains('libur') ||
            rawShift.toLowerCase().contains('off') ||
            rawStart.isEmpty ||
            rawStart.startsWith('00:00');

        String fmtTime(String raw) {
          if (raw.isEmpty) return '';
          final parts = raw.split(':');
          if (parts.length >= 2) return '${parts[0]}.${parts[1]}';
          return raw;
        }

        loaded[dateStr] = {
          'is_off': isOff,
          'shift_name': rawShift.isNotEmpty ? rawShift : (isOff ? 'Hari Libur (Day Off)' : 'Shift Terjadwal'),
          'start_time': isOff ? null : fmtTime(rawStart),
          'end_time': isOff ? null : fmtTime(rawEnd),
          'raw_start': rawStart,
          'raw_end': rawEnd,
          'is_custom_db': true,
          'raw': r,
        };
      }

      if (mounted) {
        setState(() {
          _schedulesByDate = loaded;
          _attendancesByDate = attMap;
          _initWeekDays();
        });
      }
    } catch (e) {
      debugPrint('Error loading employee_schedules: $e');
    }
  }

  static final List<Map<String, dynamic>> _defaultCoworkers = [
    {'full_name': 'Dimas Anggara', 'position': 'Barista'},
    {'full_name': 'Cece Kasir', 'position': 'Kasir Senior'},
    {'full_name': 'Siti Nurhaliza', 'position': 'Kasir'},
    {'full_name': 'Budi Santoso', 'position': 'Kitchen Staff'},
    {'full_name': 'Pricil', 'position': 'Kasir'},
    {'full_name': 'Rian Pratama', 'position': 'Barista'},
    {'full_name': 'Alisa Yasmin', 'position': 'Barista Lead'},
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentWeekMonday = now.subtract(Duration(days: now.weekday - 1));
    _selectedDayIndex = now.weekday - 1;
    _initWeekDays();
    _loadCoworkers();
    _loadSchedules();
  }

  Future<void> _loadCoworkers() async {
    try {
      final client = Supabase.instance.client;
      final rows = await client
          .from('employees')
          .select('id, full_name, position')
          .eq('is_active', true)
          .order('full_name', ascending: true);
      if (mounted) {
        setState(() {
          _coworkers = List<Map<String, dynamic>>.from(rows)
              .where((e) =>
                  (e['full_name'] ?? '').toString().toLowerCase() !=
                  Session.name.toLowerCase())
              .toList();
        });
      }
    } catch (e) {
      debugPrint('Error loading coworkers: $e');
    }
  }

  void _initWeekDays() {
    const dayLabels = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    _weekDays = List.generate(7, (i) {
      final date = _currentWeekMonday.add(Duration(days: i));
      final d = DateTime(date.year, date.month, date.day);
      final isToday = d.isAtSameMomentAs(todayDate);
      final sched = _getScheduleFor(date);
      final att = _getAttendanceFor(date);
      final hasAtt = att != null && att['clock_in'] != null;
      final isExpired = _isShiftExpiredForDate(date, sched);

      final String status;
      if (sched == null) {
        status = 'unscheduled';
      } else if (sched['is_off'] == true) {
        status = 'off';
      } else if (hasAtt) {
        status = att['status'] == 'late' ? 'late' : 'present';
      } else if (isExpired) {
        status = 'alfa';
      } else {
        status = isToday ? 'active' : 'work';
      }
      return {
        'day': dayLabels[i],
        'date': date.day,
        'fullDate': date,
        'status': status,
        'schedule': sched,
        'attendance': att,
      };
    });
  }

  void _prevWeek() {
    setState(() {
      _currentWeekMonday = _currentWeekMonday.subtract(const Duration(days: 7));
      _initWeekDays();
      _selectedDayIndex = 0;
    });
  }

  void _nextWeek() {
    setState(() {
      _currentWeekMonday = _currentWeekMonday.add(const Duration(days: 7));
      _initWeekDays();
      _selectedDayIndex = 0;
    });
  }

  void _resetToCurrentWeek() {
    final now = DateTime.now();
    setState(() {
      _currentWeekMonday = now.subtract(Duration(days: now.weekday - 1));
      _initWeekDays();
      _selectedDayIndex = now.weekday - 1;
      _selectedMonthDate = DateTime(now.year, now.month, 1);
    });
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  Future<void> _pickCustomDate() async {
    final now = DateTime.now();
    final selectedDate = _weekDays[_selectedDayIndex]['fullDate'] as DateTime;
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(now.year - 1, 1, 1),
      lastDate: DateTime(now.year + 2, 12, 31),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primary,
              onPrimary: Colors.white,
              onSurface: onSurface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        final monday = picked.subtract(Duration(days: picked.weekday - 1));
        _currentWeekMonday = monday;
        _initWeekDays();
        _selectedDayIndex = picked.weekday - 1;
        _selectedMonthDate = DateTime(picked.year, picked.month, 1);
      });
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
        );
      }
    }
  }

  String _getDutyTitle(DateTime date) {
    final isClosing = date.weekday == DateTime.friday || date.weekday == DateTime.sunday;
    final role = Session.role.toLowerCase();
    if (role.contains('kasir')) {
      return isClosing ? 'Closing Cashier & Reconciliation' : 'Opening Cashier & Billing Lead';
    } else if (role.contains('server') || role.contains('waiter') || role.contains('pelayan')) {
      return isClosing ? 'Dining Area & Floor Closing Lead' : 'Table Service & Opening Server';
    } else if (role.contains('kitchen') || role.contains('koki')) {
      return isClosing ? 'Kitchen Closing & Inventory Check' : 'Food Preparation & Kitchen Station';
    } else {
      return isClosing ? 'Bar Closing & Espresso Machine Lead' : 'Opening Floor & Barista Lead';
    }
  }

  String _getStationName() {
    final role = Session.role.toLowerCase();
    if (role.contains('kasir')) {
      return 'Warkop Cak Kebo • POS & Cashier Station';
    } else if (role.contains('server') || role.contains('waiter') || role.contains('pelayan')) {
      return 'Warkop Cak Kebo • Dining & Floor Area';
    } else if (role.contains('kitchen') || role.contains('koki')) {
      return 'Warkop Cak Kebo • Kitchen & Snack Station';
    } else {
      return 'Warkop Cak Kebo • Bar & Coffee Station';
    }
  }

  final Color primary = AppColors.primary;
  final Color primaryDark = AppColors.primaryDark;
  final Color primaryLight = AppColors.primaryLight;
  final Color secondary = AppColors.secondary;
  final Color surface = AppColors.surface;
  final Color surfaceContainerLowest = AppColors.surfaceContainerLowest;
  final Color surfaceContainerLow = AppColors.surfaceContainerLow;
  final Color surfaceContainer = const Color(0xFFE0EDFF);
  final Color surfaceContainerHigh = const Color(0xFFDBEAFE);
  final Color surfaceContainerHighest = const Color(0xFFBFDBFE);
  final Color onSurface = AppColors.onSurface;
  final Color onSurfaceVariant = AppColors.onSurfaceVariant;
  final Color onPrimary = const Color(0xFFFFFFFF);
  final Color borderLight = AppColors.borderLight;

  void _showSwapModal(BuildContext context) {
    final selectedItem = _weekDays[_selectedDayIndex];
    final selectedDate = selectedItem['fullDate'] as DateTime;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    if (targetDate.isBefore(today) || selectedItem['status'] == 'alfa') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak dapat mengajukan pergantian shift untuk shift yang telah lewat atau tercatat Alfa.')),
      );
      return;
    }
    final dateStr = '${_daysFull[selectedDate.weekday]}, ${selectedDate.day} ${_monthsShort[selectedDate.month]}';

    final sched = _getScheduleFor(selectedDate);
    final isOff = sched?['is_off'] == true;
    final shiftTitle = sched?['shift_name'] ?? 'Shift Belum Dijadwalkan';
    final shiftHours = isOff
        ? 'Day Off (Libur)'
        : (sched != null ? '${sched['start_time']} - ${sched['end_time']} WIB' : 'Menunggu SPV');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final source = _coworkers.isNotEmpty ? _coworkers : _defaultCoworkers;
        String selectedReplacement = (source.first['full_name'] ?? 'Dimas Anggara').toString();
        String searchQuery = '';
        TextEditingController reasonController = TextEditingController();

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateModal) {
            final displayedCoworkers = source.where((c) {
              final name = (c['full_name'] ?? '').toString().toLowerCase();
              final pos = (c['position'] ?? '').toString().toLowerCase();
              final q = searchQuery.toLowerCase();
              return q.isEmpty || name.contains(q) || pos.contains(q);
            }).toList();

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
                                  style: AppTextStyles.overline.copyWith(color: primary, letterSpacing: 1),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Ajukan Tukar Shift',
                              style: AppTextStyles.h2,
                            ),
                            Text(
                              '$shiftTitle • $dateStr ($shiftHours)',
                              style: AppTextStyles.body,
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
                      style: AppTextStyles.bodyBold,
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
                              onChanged: (val) => setStateModal(() => searchQuery = val),
                              decoration: InputDecoration(
                                hintText: 'Cari nama rekan barista / kasir...',
                                hintStyle: AppTextStyles.body.copyWith(color: secondary.withOpacity(0.6)),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Daftar Staf Tersedia (${displayedCoworkers.length}):',
                      style: AppTextStyles.caption,
                    ),
                    const SizedBox(height: 6),
                    Container(
                      constraints: const BoxConstraints(maxHeight: 220),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: displayedCoworkers.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, idx) {
                          final c = displayedCoworkers[idx];
                          final name = (c['full_name'] ?? '').toString();
                          final pos = (c['position'] ?? 'Staff').toString();
                          final initials = name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase();
                          final isSelected = selectedReplacement == name;

                          return InkWell(
                            onTap: () => setStateModal(() => selectedReplacement = name),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSelected ? primaryLight.withOpacity(0.4) : surfaceContainerLow,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected ? primary : borderLight,
                                  width: isSelected ? 1.5 : 1,
                                ),
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
                                          color: isSelected ? primary : surfaceContainerHigh,
                                          shape: BoxShape.circle,
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          initials,
                                          style: AppTextStyles.cardTitle.copyWith(color: isSelected ? Colors.white : secondary),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            name,
                                            style: AppTextStyles.h4,
                                          ),
                                          Text(
                                            '$pos • Siap Pengganti',
                                            style: AppTextStyles.caption,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Radio<String>(
                                    value: name,
                                    groupValue: selectedReplacement,
                                    activeColor: primary,
                                    onChanged: (val) => setStateModal(() => selectedReplacement = val!),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Alasan Pergantian',
                      style: AppTextStyles.bodyBold,
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: ['Urusan Keluarga', 'Jadwal Kuliah / Ujian', 'Kurang Sehat']
                          .map((reason) => ActionChip(
                                label: Text(reason),
                                labelStyle: AppTextStyles.captionBold.copyWith(color: onSurfaceVariant),
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
                        hintStyle: AppTextStyles.body.copyWith(color: secondary.withOpacity(0.6)),
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
                              style: AppTextStyles.caption,
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
                              style: AppTextStyles.button.copyWith(color: onSurface),
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
                              if (selectedReplacement.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Pilih rekan pengganti terlebih dahulu')),
                                );
                                return;
                              }
                              setState(() {
                                _pendingSwaps.add({
                                  'date': selectedDate,
                                  'dateStr': dateStr,
                                  'targetShift': shiftTitle,
                                  'hours': shiftHours,
                                  'replacement': selectedReplacement,
                                  'reason': reasonController.text.isNotEmpty ? reasonController.text : 'Keperluan Pribadi',
                                  'status': 'Menunggu Rekan',
                                  'createdAt': DateTime.now(),
                                });
                              });
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: primaryDark,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  content: Text('Pengajuan tukar shift ke $selectedReplacement berhasil dikirim!'),
                                ),
                              );
                            },
                            child: Text(
                              'Kirim Pengajuan',
                              style: AppTextStyles.button,
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
    super.build(context);
    final weekOfMonth = ((_currentWeekMonday.day - 1) ~/ 7) + 1;
    final endOfWeek = _currentWeekMonday.add(const Duration(days: 6));
    final monthStr = '${_monthsFull[_currentWeekMonday.month]} ${_currentWeekMonday.year}';
    final weekRangeStr = 'Pekan Ke-$weekOfMonth (${_currentWeekMonday.day} - ${endOfWeek.day} ${_monthsShort[endOfWeek.month]})';

    final selectedItem = _weekDays[_selectedDayIndex];
    final selectedDate = selectedItem['fullDate'] as DateTime;
    final now = DateTime.now();
    final isTodaySelected = selectedDate.year == now.year &&
        selectedDate.month == now.month &&
        selectedDate.day == now.day;
    final selectedDateFullStr = '${_daysFull[selectedDate.weekday]}, ${selectedDate.day} ${_monthsFull[selectedDate.month]} ${selectedDate.year}';

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
                      final tabScope = TabNavigationScope.of(context);
                      if (tabScope != null && tabScope.currentIndex != 0) {
                        tabScope.switchTo(0);
                      } else if (Navigator.canPop(context)) {
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
                          style: AppTextStyles.overline.copyWith(color: Colors.white.withOpacity(0.85), height: 1.1),
                        ),
                        Text(
                          'Jadwal Staf',
                          style: AppTextStyles.h2.copyWith(color: Colors.white, height: 1.15),
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
                    child: Builder(builder: (context) {
                      final today = DateTime.now();
                      final todayDate = DateTime(today.year, today.month, today.day);
                      final todayItem = _weekDays.firstWhere(
                        (w) => (w['fullDate'] as DateTime).isAtSameMomentAs(todayDate),
                        orElse: () => {'status': 'active'},
                      );
                      final ts = todayItem['status'];
                      final String pText;
                      final Color pColor;
                      if (ts == 'alfa') {
                        pText = 'SHIFT BERAKHIR (ALFA)';
                        pColor = const Color(0xFFEF4444);
                      } else if (ts == 'present' || ts == 'late') {
                        pText = 'PRESENSI SELESAI';
                        pColor = const Color(0xFF4ADE80);
                      } else if (ts == 'off') {
                        pText = 'HARI LIBUR';
                        pColor = const Color(0xFF94A3B8);
                      } else {
                        pText = 'SHIFT AKTIF';
                        pColor = const Color(0xFF4ADE80);
                      }

                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: pColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            pText,
                            style: AppTextStyles.overline.copyWith(color: Colors.white, letterSpacing: 0.8),
                          ),
                        ],
                      );
                    }),
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
                    controller: _scrollController,
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
                                  'Warkop Cak Kebo',
                                  style: AppTextStyles.captionBold.copyWith(color: primary, letterSpacing: 0.5),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Jadwal Kerja Saya',
                                  style: AppTextStyles.h1,
                                ),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (!isTodaySelected) ...[
                                  InkWell(
                                    onTap: _resetToCurrentWeek,
                                    borderRadius: BorderRadius.circular(20),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: primaryLight,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: primary.withOpacity(0.25)),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.today, size: 14, color: primary),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Hari Ini',
                                            style: AppTextStyles.captionBold.copyWith(color: primary),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                InkWell(
                                  onTap: _pickCustomDate,
                                  borderRadius: BorderRadius.circular(22),
                                  child: Container(
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
                                ),
                              ],
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
                                      monthStr,
                                      style: AppTextStyles.cardTitle,
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
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          _viewMode = 'minggu';
                                          _resetToCurrentWeek();
                                        });
                                      },
                                      borderRadius: BorderRadius.circular(16),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: _viewMode == 'minggu' ? surfaceContainerLowest : Colors.transparent,
                                          borderRadius: BorderRadius.circular(16),
                                          boxShadow: _viewMode == 'minggu'
                                              ? [
                                                  BoxShadow(
                                                    color: Colors.black.withOpacity(0.04),
                                                    blurRadius: 4,
                                                  ),
                                                ]
                                              : null,
                                        ),
                                        child: Text(
                                          'Minggu Ini',
                                          style: AppTextStyles.captionBold.copyWith(color: _viewMode == 'minggu' ? primary : secondary),
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          _viewMode = 'bulan';
                                        });
                                      },
                                      borderRadius: BorderRadius.circular(16),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: _viewMode == 'bulan' ? surfaceContainerLowest : Colors.transparent,
                                          borderRadius: BorderRadius.circular(16),
                                          boxShadow: _viewMode == 'bulan'
                                              ? [
                                                  BoxShadow(
                                                    color: Colors.black.withOpacity(0.04),
                                                    blurRadius: 4,
                                                  ),
                                                ]
                                              : null,
                                        ),
                                        child: Text(
                                          'Bulan',
                                          style: AppTextStyles.captionBold.copyWith(color: _viewMode == 'bulan' ? primary : secondary),
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
                        if (_viewMode == 'bulan') ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        _selectedMonthDate = DateTime(_selectedMonthDate.year, _selectedMonthDate.month - 1, 1);
                                      });
                                    },
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: surfaceContainerLowest,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: borderLight, width: 1),
                                      ),
                                      child: Icon(Icons.chevron_left, size: 18, color: onSurfaceVariant),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${_monthsFull[_selectedMonthDate.month]} ${_selectedMonthDate.year}',
                                    style: AppTextStyles.cardTitle.copyWith(color: onSurfaceVariant),
                                  ),
                                  const SizedBox(width: 8),
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        _selectedMonthDate = DateTime(_selectedMonthDate.year, _selectedMonthDate.month + 1, 1);
                                      });
                                    },
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: surfaceContainerLowest,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: borderLight, width: 1),
                                      ),
                                      child: Icon(Icons.chevron_right, size: 18, color: onSurfaceVariant),
                                    ),
                                  ),
                                ],
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
                                    'Kalender Bulanan',
                                    style: AppTextStyles.captionBold.copyWith(color: primary),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildMonthGrid(selectedDate),
                        ] else ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  InkWell(
                                    onTap: _prevWeek,
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: surfaceContainerLowest,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: borderLight, width: 1),
                                      ),
                                      child: Icon(Icons.chevron_left, size: 18, color: onSurfaceVariant),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    weekRangeStr,
                                    style: AppTextStyles.bodyBold.copyWith(color: onSurfaceVariant),
                                  ),
                                  const SizedBox(width: 8),
                                  InkWell(
                                    onTap: _nextWeek,
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: surfaceContainerLowest,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: borderLight, width: 1),
                                      ),
                                      child: Icon(Icons.chevron_right, size: 18, color: onSurfaceVariant),
                                    ),
                                  ),
                                ],
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
                                    style: AppTextStyles.captionBold.copyWith(color: primary),
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
                                        style: AppTextStyles.overline.copyWith(
                                          color: isSelected
                                              ? onPrimary.withOpacity(0.9)
                                              : (isOff
                                                  ? secondary.withOpacity(0.6)
                                                  : secondary),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item['date'].toString(),
                                        style: AppTextStyles.h3.copyWith(color: isSelected ? onPrimary : (isOff ? secondary.withOpacity(0.6) : onSurface)),
                                      ),
                                      const SizedBox(height: 6),
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? surfaceContainerLowest
                                              : (isOff || item['status'] == 'unscheduled'
                                                  ? Colors.transparent
                                                  : (item['status'] == 'alfa'
                                                      ? const Color(0xFFDC2626)
                                                      : (item['status'] == 'present'
                                                          ? const Color(0xFF16A34A)
                                                          : (item['status'] == 'late'
                                                              ? const Color(0xFFEA580C)
                                                              : primary)))),
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
                      ],
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
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          isTodaySelected ? 'HARI INI' : 'DETAIL JADWAL',
                                          style: AppTextStyles.overline.copyWith(letterSpacing: 1),
                                        ),
                                        Text(
                                          selectedDateFullStr,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTextStyles.h3,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Builder(builder: (context) {
                                    final st = selectedItem['status'];
                                    final String bText;
                                    final Color bColor;
                                    final Color bBg;
                                    switch (st) {
                                      case 'alfa':
                                        bText = isTodaySelected ? 'Shift Berakhir (Alfa)' : 'Alfa (Tidak Hadir)';
                                        bColor = const Color(0xFFDC2626);
                                        bBg = const Color(0xFFFEF2F2);
                                        break;
                                      case 'present':
                                        bText = 'Hadir (Tepat Waktu)';
                                        bColor = const Color(0xFF16A34A);
                                        bBg = const Color(0xFFDCFCE7);
                                        break;
                                      case 'late':
                                        bText = 'Hadir (Terlambat)';
                                        bColor = const Color(0xFFEA580C);
                                        bBg = const Color(0xFFFFF7ED);
                                        break;
                                      case 'off':
                                        bText = 'Libur';
                                        bColor = secondary;
                                        bBg = surfaceContainerLow;
                                        break;
                                      case 'unscheduled':
                                        bText = 'Belum Ada Jadwal';
                                        bColor = secondary.withOpacity(0.8);
                                        bBg = surfaceContainerLow;
                                        break;
                                      case 'active':
                                        bText = 'Shift Aktif';
                                        bColor = primary;
                                        bBg = primaryLight;
                                        break;
                                      default:
                                        bText = 'Terjadwal';
                                        bColor = secondary;
                                        bBg = surfaceContainerLow;
                                    }

                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: bBg,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: st == 'alfa' ? const Color(0xFFFECACA) : Colors.transparent,
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 7,
                                            height: 7,
                                            decoration: BoxDecoration(
                                              color: bColor,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            bText,
                                            style: AppTextStyles.captionBold.copyWith(color: bColor),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                ],
                              ),
                              const SizedBox(height: 16),
                              if (selectedItem['status'] == 'unscheduled') ...[
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                                  decoration: BoxDecoration(
                                    color: surfaceContainerLow,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: borderLight, width: 1),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 58,
                                        height: 58,
                                        decoration: BoxDecoration(
                                          color: surfaceContainerHigh,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: borderLight),
                                        ),
                                        child: Icon(
                                          Icons.event_busy_rounded,
                                          color: secondary,
                                          size: 28,
                                        ),
                                      ),
                                      const SizedBox(height: 14),
                                      Text(
                                        'Belum Ada Jadwal Kerja',
                                        style: AppTextStyles.h2,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Jadwal shift untuk tanggal ini belum diatur oleh Supervisor / Admin outlet Cak Kebo.',
                                        textAlign: TextAlign.center,
                                        style: AppTextStyles.body,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () {
                                          _loadSchedules();
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Memperbarui jadwal dari server...'),
                                              duration: Duration(seconds: 1),
                                            ),
                                          );
                                        },
                                        icon: Icon(Icons.refresh_rounded, size: 18, color: primary),
                                        label: Text(
                                          'Refresh',
                                          style: AppTextStyles.captionBold.copyWith(color: primary),
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(vertical: 14),
                                          side: BorderSide(color: primary, width: 1.2),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Silakan hubungi SPV/Manager outlet untuk konfirmasi jadwal.'),
                                            ),
                                          );
                                        },
                                        icon: const Icon(Icons.support_agent_rounded, size: 18, color: Colors.white),
                                        label: Text(
                                          'Hubungi SPV',
                                          style: AppTextStyles.captionBold.copyWith(color: Colors.white),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: primary,
                                          padding: const EdgeInsets.symmetric(vertical: 14),
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ] else if (selectedItem['status'] == 'off') ...[
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                                  decoration: BoxDecoration(
                                    color: surfaceContainerLow,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: borderLight, width: 1),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 58,
                                        height: 58,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFEF3C7),
                                          shape: BoxShape.circle,
                                          border: Border.all(color: const Color(0xFFFDE68A)),
                                        ),
                                        child: const Icon(
                                          Icons.beach_access_rounded,
                                          color: Color(0xFFD97706),
                                          size: 30,
                                        ),
                                      ),
                                      const SizedBox(height: 14),
                                      Text(
                                        'Hari Libur (Day Off)',
                                        style: AppTextStyles.h2,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Tidak ada jadwal kerja hari ini.',
                                        textAlign: TextAlign.center,
                                        style: AppTextStyles.body,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                OutlinedButton.icon(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Belum ada permintaan tukar shift lembur hari ini.'),
                                      ),
                                    );
                                  },
                                  icon: Icon(Icons.add_task_rounded, size: 18, color: primary),
                                  label: Text(
                                    'Ajukan Shift Lembur / Ekstra',
                                    style: AppTextStyles.button.copyWith(color: primary),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size(double.infinity, 50),
                                    side: BorderSide(color: primary, width: 1.2),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                ),
                              ] else ...[
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
                                            child: Icon(
                                              Session.role.toLowerCase().contains('kasir')
                                                  ? Icons.point_of_sale
                                                  : (Session.role.toLowerCase().contains('server')
                                                      ? Icons.table_restaurant
                                                      : Icons.local_cafe),
                                              color: primary,
                                              size: 20,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                _getScheduleFor(selectedDate)?['shift_name'] ?? 'Shift Kerja',
                                                style: AppTextStyles.h3,
                                              ),
                                              Text(
                                                _getDutyTitle(selectedDate),
                                                style: AppTextStyles.body,
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
                                            _getScheduleFor(selectedDate)?['start_time'] ?? '08.00',
                                            style: AppTextStyles.h1.copyWith(fontSize: 28, color: primary),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 6),
                                            child: Text(
                                              '-',
                                              style: AppTextStyles.h1.copyWith(fontSize: 20, color: secondary),
                                            ),
                                          ),
                                          Text(
                                            _getScheduleFor(selectedDate)?['end_time'] ?? '16.00',
                                            style: AppTextStyles.h1.copyWith(fontSize: 28, color: primary),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            'WIB',
                                            style: AppTextStyles.bodyBold.copyWith(color: secondary),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(Icons.storefront, color: primary, size: 16),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              _getStationName(),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: AppTextStyles.subtitle.copyWith(color: onSurfaceVariant),
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
                                  style: AppTextStyles.overline.copyWith(letterSpacing: 1),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Builder(
                                      builder: (context) {
                                        final source = _coworkers.isNotEmpty ? _coworkers : _defaultCoworkers;
                                        final working = source.where((c) {
                                          final cId = int.tryParse(c['id']?.toString() ?? '') ?? 1;
                                          return selectedDate.weekday != (1 + (cId % 7));
                                        }).toList();
                                        final listToShow = working.isNotEmpty ? working : source;
                                        final c1 = listToShow.isNotEmpty ? listToShow[0] : {'full_name': 'Cece Kasir', 'position': 'Kasir'};
                                        final c2 = listToShow.length > 1 ? listToShow[1] : {'full_name': 'Dimas Anggara', 'position': 'Barista'};
                                        String initials(String name) {
                                          final p = name.trim().split(' ');
                                          if (p.length >= 2) return '${p[0][0]}${p[1][0]}'.toUpperCase();
                                          return name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'CK';
                                        }

                                        return Row(
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
                                                        initials(c1['full_name'] ?? 'CK'),
                                                        style: AppTextStyles.captionBold.copyWith(color: primary),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            c1['full_name'] ?? 'Cece Kasir',
                                                            maxLines: 1,
                                                            overflow: TextOverflow.ellipsis,
                                                            style: AppTextStyles.cardTitle,
                                                          ),
                                                          Text(
                                                            c1['position'] ?? 'Staf',
                                                            style: AppTextStyles.caption,
                                                          ),
                                                        ],
                                                      ),
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
                                                        initials(c2['full_name'] ?? 'DA'),
                                                        style: AppTextStyles.captionBold.copyWith(color: primaryDark),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            c2['full_name'] ?? 'Dimas Anggara',
                                                            maxLines: 1,
                                                            overflow: TextOverflow.ellipsis,
                                                            style: AppTextStyles.cardTitle,
                                                          ),
                                                          Text(
                                                            c2['position'] ?? 'Barista',
                                                            style: AppTextStyles.caption,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                if (selectedItem['status'] == 'alfa') ...[
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFEF2F2),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: const Color(0xFFFECACA)),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.block_rounded, color: Color(0xFFDC2626), size: 20),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            isTodaySelected
                                                ? 'Shift hari ini telah berakhir dan presensi masuk telah ditutup (Alfa). Hubungi supervisor jika perlu penyesuaian.'
                                                : 'Shift telah berakhir dan tercatat Alfa. Tanggal lampau tidak dapat diubah atau ditukar shift.',
                                            style: AppTextStyles.captionBold.copyWith(color: const Color(0xFFDC2626)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ] else if (selectedItem['status'] == 'present' || selectedItem['status'] == 'late') ...[
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF0FDF4),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: const Color(0xFFBBF7D0)),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF16A34A), size: 20),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            'Presensi shift ini telah selesai tercatat (' + (selectedItem['status'] == 'late' ? 'Terlambat' : 'Tepat Waktu') + ').',
                                            style: AppTextStyles.captionBold.copyWith(color: const Color(0xFF15803D)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ] else if (isTodaySelected && selectedItem['status'] == 'active') ...[
                                  ElevatedButton(
                                    onPressed: () {
                                      final nav = TabNavigationScope.of(context);
                                      if (nav != null) {
                                        nav.switchTo(0);
                                      } else {
                                        Navigator.pushReplacementNamed(context, '/home');
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primary,
                                      foregroundColor: onPrimary,
                                      elevation: 0,
                                      minimumSize: const Size(double.infinity, 50),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.qr_code_scanner, size: 20),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Mulai Absensi Hari Ini',
                                          style: AppTextStyles.button,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  OutlinedButton(
                                    onPressed: () => _showSwapModal(context),
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: surfaceContainerLow,
                                      foregroundColor: onSurface,
                                      side: BorderSide(color: borderLight, width: 1.2),
                                      minimumSize: const Size(double.infinity, 48),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.swap_horizontal_circle_outlined, size: 18, color: primary),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Ajukan Pergantian Shift',
                                          style: AppTextStyles.button.copyWith(color: onSurface),
                                        ),
                                      ],
                                    ),
                                  ),
                                ] else if (selectedItem['status'] == 'work') ...[
                                  ElevatedButton(
                                    onPressed: () => _showSwapModal(context),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primary,
                                      foregroundColor: onPrimary,
                                      elevation: 0,
                                      minimumSize: const Size(double.infinity, 50),
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
                                          style: AppTextStyles.button,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ],
                          ),
                        ),
                        if (_pendingSwaps.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFBEB),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFFFDE68A), width: 1.2),
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
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF59E0B).withOpacity(0.15),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.sync_alt, color: Color(0xFFD97706), size: 16),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Pengajuan Tukar Shift',
                                          style: AppTextStyles.cardTitle.copyWith(color: AppColors.warning),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFDE68A),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        'Menunggu Rekan',
                                        style: AppTextStyles.overline.copyWith(color: AppColors.warning),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                for (final swap in _pendingSwaps) ...[
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    margin: const EdgeInsets.only(bottom: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: const Color(0xFFFEEBC8)),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.schedule, size: 16, color: Color(0xFFD97706)),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            '${swap['targetShift']} (${swap['dateStr']}) ➔ Pengganti: ${swap['replacement']}',
                                            style: AppTextStyles.bodyBold.copyWith(color: AppColors.warning),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Shift Mendatang',
                              style: AppTextStyles.h2,
                            ),
                            Text(
                              'Pekan Ini',
                              style: AppTextStyles.subtitle.copyWith(color: primary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Column(
                          children: [
                            for (int i = 1; i <= 3; i++) ...[
                              Builder(
                                builder: (context) {
                                  const dayLabels = ['', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
                                  final targetDate = DateTime.now().add(Duration(days: i));
                                  final sched = _getScheduleFor(targetDate);
                                  final isUnscheduled = sched == null;
                                  final isOff = sched != null && sched['is_off'] == true;
                                  final dayLabel = dayLabels[targetDate.weekday];
                                  final title = isUnscheduled
                                      ? 'Belum Dijadwalkan'
                                      : sched['shift_name'];
                                  final subtitle = isUnscheduled
                                      ? 'Menunggu jadwal dari SPV'
                                      : (isOff
                                          ? 'Day Off Terjadwal'
                                          : '${sched['start_time']} - ${sched['end_time']} WIB • ${_getStationName().replaceFirst("Warkop Cak Kebo • ", "")}');

                                  return Padding(
                                    padding: EdgeInsets.only(bottom: i < 3 ? 8 : 0),
                                    child: _buildUpcomingShiftCard(
                                      dayLabel,
                                      targetDate.day.toString(),
                                      title,
                                      subtitle,
                                      isOff,
                                      onTap: () {
                                        setState(() {
                                          final monday = targetDate.subtract(Duration(days: targetDate.weekday - 1));
                                          _currentWeekMonday = monday;
                                          _initWeekDays();
                                          _selectedDayIndex = targetDate.weekday - 1;
                                          _selectedMonthDate = DateTime(targetDate.year, targetDate.month, 1);
                                        });
                                        if (_scrollController.hasClients) {
                                          _scrollController.animateTo(
                                            0,
                                            duration: const Duration(milliseconds: 350),
                                            curve: Curves.easeOutCubic,
                                          );
                                        }
                                      },
                                    ),
                                  );
                                },
                              ),
                            ],
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
      bottomNavigationBar: TabNavigationScope.of(context) != null
          ? null
          : BottomNavigationBar(
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
              selectedLabelStyle: AppTextStyles.captionBold,
              unselectedLabelStyle: AppTextStyles.caption,
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
    bool isOff, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
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
            Expanded(
              child: Row(
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
                          style: AppTextStyles.overline.copyWith(color: isOff ? secondary.withOpacity(0.6) : primary),
                        ),
                        Text(
                          date,
                          style: AppTextStyles.h3.copyWith(color: isOff ? secondary.withOpacity(0.6) : onSurface, height: 1.1),
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
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.h4,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.body,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            isOff
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Off',
                      style: AppTextStyles.captionBold.copyWith(color: secondary),
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
      ),
    );
  }

  Widget _buildMonthGrid(DateTime selectedDate) {
    const dayNames = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    final year = _selectedMonthDate.year;
    final month = _selectedMonthDate.month;
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final firstWeekday = DateTime(year, month, 1).weekday; // 1 = Sen, 7 = Min
    final leadingEmpty = firstWeekday - 1;
    final totalCells = leadingEmpty + daysInMonth;
    final now = DateTime.now();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderLight, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header nama hari
          Row(
            children: dayNames.map((d) {
              final isWeekend = d == 'Sab' || d == 'Min';
              return Expanded(
                child: Center(
                  child: Text(
                    d,
                    style: AppTextStyles.captionBold.copyWith(color: isWeekend ? primaryDark : secondary),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          // Grid tanggal
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 4,
              mainAxisSpacing: 6,
              childAspectRatio: 1.0,
            ),
            itemCount: totalCells,
            itemBuilder: (context, idx) {
              if (idx < leadingEmpty) {
                return const SizedBox();
              }
              final dayNumber = idx - leadingEmpty + 1;
              final date = DateTime(year, month, dayNumber);
              final isToday = date.year == now.year && date.month == now.month && date.day == now.day;
              final isSelected = date.year == selectedDate.year &&
                  date.month == selectedDate.month &&
                  date.day == selectedDate.day;
              final sched = _getScheduleFor(date);
              final isUnscheduled = sched == null;
              final isOff = sched != null && sched['is_off'] == true;

              return InkWell(
                onTap: () {
                  setState(() {
                    final monday = date.subtract(Duration(days: date.weekday - 1));
                    _currentWeekMonday = monday;
                    _initWeekDays();
                    _selectedDayIndex = date.weekday - 1;
                  });
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? primary
                        : (isToday
                            ? primaryLight.withOpacity(0.4)
                            : (isOff ? surfaceContainerLow.withOpacity(0.7) : Colors.transparent)),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? primary
                          : (isToday ? primary : borderLight.withOpacity(0.5)),
                      width: isSelected || isToday ? 1.2 : 0.8,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$dayNumber',
                        style: AppTextStyles.cardTitle.copyWith(fontWeight: isSelected || isToday ? FontWeight.w700 : FontWeight.w600, color: isSelected ? Colors.white : (isOff ? secondary.withOpacity(0.7) : onSurface)),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white
                              : (isUnscheduled
                                  ? Colors.transparent
                                  : (isOff
                                      ? const Color(0xFFF59E0B)
                                      : (_isShiftExpiredForDate(date, sched) && (_getAttendanceFor(date) == null || _getAttendanceFor(date)!['clock_in'] == null)
                                          ? const Color(0xFFDC2626)
                                          : (_getAttendanceFor(date) != null && _getAttendanceFor(date)!['clock_in'] != null
                                              ? const Color(0xFF16A34A)
                                              : primary)))),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
