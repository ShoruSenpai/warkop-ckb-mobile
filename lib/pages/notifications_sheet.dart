import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../services/session.dart';
import '../theme/app_theme.dart';

class NotificationsBottomSheet extends StatefulWidget {
  final VoidCallback? onNotificationsChanged;

  const NotificationsBottomSheet({
    super.key,
    this.onNotificationsChanged,
  });

  static Future<void> show(BuildContext context, {VoidCallback? onChanged}) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => NotificationsBottomSheet(onNotificationsChanged: onChanged),
    );
  }

  @override
  State<NotificationsBottomSheet> createState() => _NotificationsBottomSheetState();
}

class _NotificationsBottomSheetState extends State<NotificationsBottomSheet> {
  bool _isLoading = true;
  String _activeFilter = 'all'; // 'all' or 'unread'
  List<AppNotification> _notifications = [];
  String? _processingId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final data = await NotificationService.fetchNotifications(Session.userId);
    if (mounted) {
      setState(() {
        _notifications = data;
        _isLoading = false;
      });
      widget.onNotificationsChanged?.call();
    }
  }

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  List<AppNotification> get _filteredList {
    if (_activeFilter == 'unread') {
      return _notifications.where((n) => !n.isRead).toList();
    }
    return _notifications;
  }

  Future<void> _markAllAsRead() async {
    final success = await NotificationService.markAllAsRead(Session.userId);
    if (success && mounted) {
      setState(() {
        for (var n in _notifications) {
          n.readAt ??= DateTime.now();
        }
      });
      widget.onNotificationsChanged?.call();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Semua notifikasi ditandai sudah dibaca'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _markSingleAsRead(AppNotification notif) async {
    if (notif.isRead) return;
    setState(() {
      notif.readAt = DateTime.now();
    });
    await NotificationService.markAsRead(notif.id);
    widget.onNotificationsChanged?.call();
  }

  Future<void> _handleSwapAction(AppNotification notif, bool accept) async {
    setState(() => _processingId = notif.id);
    final success = await NotificationService.respondToSwapRequest(
      notif: notif,
      accept: accept,
      currentUserId: Session.userId,
    );
    if (mounted) {
      setState(() => _processingId = null);
      if (success) {
        widget.onNotificationsChanged?.call();
        final partner = notif.partnerName ?? 'Rekan';
        final msg = accept
            ? '✓ Berhasil menyetujui tukar shift dengan $partner!'
            : '✕ Permintaan tukar shift ditolak.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: accept ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.84;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 36,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Indikator drag
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'PUSAT NOTIFIKASI',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                  color: Color(0xFF2563EB),
                                ),
                              ),
                            ),
                            if (_unreadCount > 0) ...[
                              const SizedBox(width: 6),
                              Container(
                                width: 7,
                                height: 7,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFEF4444),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Warkop Cak Kebo',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.3,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Tombol tandai sudah dibaca
                  if (_unreadCount > 0)
                    GestureDetector(
                      onTap: _markAllAsRead,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2563EB).withValues(alpha: 0.25),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          'Baca ($_unreadCount)',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        '✓ Lengkap',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ),

                  const SizedBox(width: 8),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.close_rounded, size: 22, color: Color(0xFF94A3B8)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Filter status
              Row(
                children: [
                  _buildBentoFilterChip('all', 'Semua (${_notifications.length})'),
                  const SizedBox(width: 8),
                  _buildBentoFilterChip('unread', 'Belum Dibaca ($_unreadCount)'),
                ],
              ),
              const SizedBox(height: 12),

              // Daftar notifikasi
              Flexible(
                child: _isLoading
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        ),
                      )
                    : _filteredList.isEmpty
                        ? _buildEmptyState()
                        : ListView.separated(
                            shrinkWrap: true,
                            physics: const BouncingScrollPhysics(),
                            itemCount: _filteredList.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final item = _filteredList[index];
                              return _buildBentoCard(item);
                            },
                          ),
              ),

              const SizedBox(height: 14),

              // Tombol tutup
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF1F5F9),
                    foregroundColor: AppColors.onSurface,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                  ),
                  child: Text(
                    'Tutup',
                    style: AppTextStyles.button.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w800,
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

  Widget _buildBentoFilterChip(String filterKey, String label) {
    final isSelected = _activeFilter == filterKey;
    return GestureDetector(
      onTap: () => setState(() => _activeFilter = filterKey),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              size: 30,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _activeFilter == 'unread'
                ? 'Tidak ada notifikasi belum dibaca'
                : 'Belum ada notifikasi baru',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Informasi jadwal & aktivitas warkop akan tampil di sini',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBentoCard(AppNotification item) {
    if (item.category == 'swap') {
      return _buildHeroSwapBentoCard(item);
    } else if (item.category == 'alfa' || item.category == 'warning') {
      return _buildAlfaWarningBentoCard(item);
    } else if (item.category == 'late') {
      return _buildLateWarningBentoCard(item);
    } else if (item.category == 'reminder') {
      return _buildReminderBentoCard(item);
    } else {
      return _buildAnnouncementBentoCard(item);
    }
  }

  /// Card peringatan shift berakhir (alfa)
  Widget _buildAlfaWarningBentoCard(AppNotification item) {
    final isUnread = !item.isRead;

    return InkWell(
      onTap: () => _markSingleAsRead(item),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isUnread ? const Color(0xFFFEF2F2) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isUnread ? const Color(0xFFFECACA) : const Color(0xFFE2E8F0),
            width: isUnread ? 1.6 : 1.0,
          ),
          boxShadow: [
            if (isUnread)
              BoxShadow(
                color: const Color(0xFFDC2626).withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFECACA)),
              ),
              child: const Icon(
                Icons.block_rounded,
                size: 24,
                color: Color(0xFFDC2626),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDC2626),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'ALFA',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.6,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Text(
                        item.relativeTime,
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isUnread ? FontWeight.w800 : FontWeight.w700,
                      color: const Color(0xFF991B1B),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.message,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF475569),
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Card peringatan keterlambatan shift
  Widget _buildLateWarningBentoCard(AppNotification item) {
    final isUnread = !item.isRead;

    return InkWell(
      onTap: () => _markSingleAsRead(item),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isUnread ? const Color(0xFFFFF7ED) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isUnread ? const Color(0xFFFED7AA) : const Color(0xFFE2E8F0),
            width: isUnread ? 1.6 : 1.0,
          ),
          boxShadow: [
            if (isUnread)
              BoxShadow(
                color: const Color(0xFFEA580C).withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFFFEDD5),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFED7AA)),
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                size: 24,
                color: Color(0xFFEA580C),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEA580C),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'TERLAMBAT',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.6,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Text(
                        item.relativeTime,
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isUnread ? FontWeight.w800 : FontWeight.w700,
                      color: const Color(0xFF9A3412),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.message,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF475569),
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Card permintaan tukar shift
  Widget _buildHeroSwapBentoCard(AppNotification item) {
    final isUnread = !item.isRead;
    final isProcessing = _processingId == item.id;
    final partnerName = item.partnerName ?? 'Rekan Kerja';

    return InkWell(
      onTap: () => _markSingleAsRead(item),
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFFAF5FF),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isUnread ? const Color(0xFFC084FC) : const Color(0xFFE9D5FF),
            width: isUnread ? 1.8 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF9333EA).withValues(alpha: isUnread ? 0.08 : 0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badge status dan waktu
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF9333EA),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'TUKAR SHIFT REKAN',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.6,
                      color: Colors.white,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  item.relativeTime,
                  style: const TextStyle(
                    fontSize: 11,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF7E22CE),
                  ),
                ),
                if (isUnread) ...[
                  const SizedBox(width: 6),
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFF9333EA),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 10),

            // Ringkasan permohonan
            Text(
              partnerName,
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1E1B4B),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Mengajukan tukar shift untuk tanggal ${item.targetDate ?? 'besok'}.',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 10),

            // Perbandingan shift
            Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE9D5FF)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Shift Rekan:',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      Text(
                        item.targetShift ?? 'Shift Pagi (08:00 - 16:00)',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF9333EA),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Shift Kamu:',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      Text(
                        item.swapWith ?? 'Shift Malam (02:00 - 10:00)',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFD97706),
                        ),
                      ),
                    ],
                  ),
                  if (item.reason != null && item.reason!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAF5FF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '"${item.reason}"',
                        style: const TextStyle(
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                          color: Color(0xFF6B21A8),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Tombol aksi
            if (item.status == 'pending') ...[
              if (isProcessing)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                )
              else
                Row(
                  children: [
                    // Tombol tolak
                    Expanded(
                      child: SizedBox(
                        height: 42,
                        child: OutlinedButton(
                          onPressed: () => _handleSwapAction(item, false),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: const Color(0xFFFEF2F2),
                            foregroundColor: const Color(0xFFDC2626),
                            side: const BorderSide(color: Color(0xFFFECACA), width: 1.2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Tolak',
                            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Tombol setujui
                    Expanded(
                      child: SizedBox(
                        height: 42,
                        child: ElevatedButton.icon(
                          onPressed: () => _handleSwapAction(item, true),
                          icon: const Icon(Icons.check_rounded, size: 17),
                          label: const Text(
                            'Setujui',
                            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF16A34A),
                            foregroundColor: Colors.white,
                            elevation: 2,
                            shadowColor: const Color(0xFF16A34A).withValues(alpha: 0.4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ] else if (item.status == 'accepted') ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF16A34A),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF16A34A).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_rounded, size: 18, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      '✓ Jadwal Berhasil Ditukar',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (item.status == 'declined') ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cancel_rounded, size: 16, color: Color(0xFFDC2626)),
                    SizedBox(width: 6),
                    Text(
                      '✕ Permintaan Tukar Shift Ditolak',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Card pengingat presensi
  Widget _buildReminderBentoCard(AppNotification item) {
    final isUnread = !item.isRead;

    return InkWell(
      onTap: () => _markSingleAsRead(item),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUnread ? const Color(0xFFFFFBEB) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isUnread ? const Color(0xFFFDE68A) : const Color(0xFFE2E8F0),
            width: isUnread ? 1.5 : 1,
          ),
          boxShadow: [
            if (isUnread)
              BoxShadow(
                color: const Color(0xFFD97706).withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.bolt_rounded,
                size: 24,
                color: Color(0xFFD97706),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isUnread ? FontWeight.w800 : FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF64748B),
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Absen',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFD97706),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Card pengumuman outlet
  Widget _buildAnnouncementBentoCard(AppNotification item) {
    final isUnread = !item.isRead;

    return InkWell(
      onTap: () => _markSingleAsRead(item),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUnread ? const Color(0xFFEFF6FF) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isUnread ? const Color(0xFFBFDBFE) : const Color(0xFFE2E8F0),
            width: isUnread ? 1.5 : 1,
          ),
          boxShadow: [
            if (isUnread)
              BoxShadow(
                color: const Color(0xFF2563EB).withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.inventory_2_rounded,
                size: 22,
                color: Color(0xFF2563EB),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isUnread ? FontWeight.w800 : FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF64748B),
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Cabang',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF2563EB),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
