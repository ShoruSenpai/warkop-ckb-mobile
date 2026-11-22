import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppNotification {
  final String id;
  final String type;
  final int notifiableId;
  final String title;
  final String message;
  final String category; // 'swap', 'reminder', 'outlet', 'info'
  final String actionType; // 'swap_request', 'attendance', 'announcement', 'none'
  final String? partnerName;
  final String? targetDate;
  final String? targetShift;
  final String? swapWith;
  final String? reason;
  String status; // 'pending', 'accepted', 'declined'
  DateTime? readAt;
  final DateTime createdAt;
  final Map<String, dynamic> rawData;

  AppNotification({
    required this.id,
    required this.type,
    required this.notifiableId,
    required this.title,
    required this.message,
    required this.category,
    required this.actionType,
    this.partnerName,
    this.targetDate,
    this.targetShift,
    this.swapWith,
    this.reason,
    this.status = 'pending',
    this.readAt,
    required this.createdAt,
    required this.rawData,
  });

  bool get isRead => readAt != null;

  String get relativeTime {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inSeconds < 60) {
      return 'Baru saja';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes} mnt lalu';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} jam lalu';
    } else if (diff.inDays == 1) {
      final hour = createdAt.toLocal().hour.toString().padLeft(2, '0');
      final minute = createdAt.toLocal().minute.toString().padLeft(2, '0');
      return 'Kemarin, $hour:$minute';
    } else {
      return '${createdAt.day}/${createdAt.month}';
    }
  }

  factory AppNotification.fromSupabase(Map<String, dynamic> map) {
    Map<String, dynamic> data = {};
    final rawData = map['data'];
    if (rawData is Map) {
      data = Map<String, dynamic>.from(rawData);
    } else if (rawData is String && rawData.isNotEmpty) {
      try {
        data = Map<String, dynamic>.from(jsonDecode(rawData) as Map);
      } catch (_) {
        data = {'message': rawData};
      }
    }

    final createdAtStr = map['created_at']?.toString() ?? '';
    final createdAt = DateTime.tryParse(createdAtStr)?.toLocal() ?? DateTime.now();

    final readAtStr = map['read_at']?.toString();
    final readAt = readAtStr != null ? DateTime.tryParse(readAtStr)?.toLocal() : null;

    final typeStr = map['type']?.toString() ?? '';
    String category = data['category']?.toString() ?? 'info';
    String actionType = data['action_type']?.toString() ?? 'none';

    if (typeStr.contains('ShiftSwap')) {
      category = 'swap';
      actionType = 'swap_request';
    } else if (typeStr.contains('ShiftReminder')) {
      category = 'reminder';
      actionType = 'attendance';
    } else if (typeStr.contains('Announcement')) {
      category = 'outlet';
      actionType = 'announcement';
    } else if (typeStr.contains('ShiftExpired')) {
      category = 'alfa';
      actionType = 'none';
    } else if (typeStr.contains('ShiftLate')) {
      category = 'late';
      actionType = 'attendance';
    }

    return AppNotification(
      id: map['id']?.toString() ?? '',
      type: typeStr,
      notifiableId: int.tryParse(map['notifiable_id']?.toString() ?? '') ?? 0,
      title: data['title']?.toString() ?? 'Notifikasi Cak Kebo',
      message: data['message']?.toString() ?? '',
      category: category,
      actionType: actionType,
      partnerName: data['partner_name']?.toString(),
      targetDate: data['target_date']?.toString(),
      targetShift: data['target_shift']?.toString(),
      swapWith: data['swap_with']?.toString(),
      reason: data['reason']?.toString(),
      status: data['status']?.toString() ?? 'pending',
      readAt: readAt,
      createdAt: createdAt,
      rawData: data,
    );
  }
}

class NotificationService {
  static final SupabaseClient _client = Supabase.instance.client;

  /// Ambil daftar notifikasi untuk user tertentu
  static Future<List<AppNotification>> fetchNotifications(int userId) async {
    try {
      final res = await _client
          .from('notifications')
          .select()
          .eq('notifiable_id', userId)
          .order('created_at', ascending: false)
          .limit(30);

      final list = (res as List)
          .map((item) => AppNotification.fromSupabase(Map<String, dynamic>.from(item)))
          .toList();

      if (list.isEmpty) {
        // Buat sampel awal jika notifikasi masih kosong
        await ensureSampleNotifications(userId);
        return await fetchNotifications(userId);
      }

      return list;
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
      return [];
    }
  }

  /// Hitung total notifikasi belum dibaca
  static Future<int> getUnreadCount(int userId) async {
    try {
      final res = await _client
          .from('notifications')
          .select('id')
          .eq('notifiable_id', userId)
          .isFilter('read_at', null);

      return (res as List).length;
    } catch (e) {
      debugPrint('Error getting unread count: $e');
      return 0;
    }
  }

  /// Tandai 1 notifikasi sudah dibaca
  static Future<bool> markAsRead(String id) async {
    try {
      final nowUtc = DateTime.now().toUtc().toIso8601String();
      await _client
          .from('notifications')
          .update({'read_at': nowUtc, 'updated_at': nowUtc})
          .eq('id', id);
      return true;
    } catch (e) {
      debugPrint('Error marking notif as read: $e');
      return false;
    }
  }

  /// Tandai semua notifikasi milik user sudah dibaca
  static Future<bool> markAllAsRead(int userId) async {
    try {
      final nowUtc = DateTime.now().toUtc().toIso8601String();
      await _client
          .from('notifications')
          .update({'read_at': nowUtc, 'updated_at': nowUtc})
          .eq('notifiable_id', userId)
          .isFilter('read_at', null);
      return true;
    } catch (e) {
      debugPrint('Error marking all as read: $e');
      return false;
    }
  }

  /// Tanggapi permintaan tukar shift (Setujui / Tolak)
  static Future<bool> respondToSwapRequest({
    required AppNotification notif,
    required bool accept,
    required int currentUserId,
  }) async {
    try {
      final nowUtc = DateTime.now().toUtc().toIso8601String();
      final updatedData = Map<String, dynamic>.from(notif.rawData);
      updatedData['status'] = accept ? 'accepted' : 'declined';

      // Update notifikasi asli
      await _client.from('notifications').update({
        'data': jsonEncode(updatedData),
        'read_at': nowUtc,
        'updated_at': nowUtc,
      }).eq('id', notif.id);

      notif.status = accept ? 'accepted' : 'declined';
      notif.readAt = DateTime.now();

      return true;
    } catch (e) {
      debugPrint('Error responding to swap request: $e');
      return false;
    }
  }

  /// Buat sampel notifikasi awal jika user belum punya notifikasi sama sekali
  static Future<void> ensureSampleNotifications(int userId) async {
    try {
      final now = DateTime.now().toUtc();

      // Ambil nama rekan kerja lain dari database
      String partnerName = 'Alisa Yasmin';
      String targetShift = 'Shift Siang (12:00 - 20:00 WIB)';
      String swapWith = 'Shift Pagi (08:00 - 16:00 WIB)';
      try {
        final coworkers = await _client
            .from('employees')
            .select('full_name, position')
            .neq('user_id', userId)
            .limit(1);
        if ((coworkers as List).isNotEmpty) {
          final first = coworkers.first;
          partnerName = first['full_name']?.toString() ?? 'Alisa Yasmin';
        }
      } catch (_) {}

      final sampleList = [
        {
          'type': 'App\\Notifications\\ShiftSwapRequest',
          'notifiable_type': 'App\\Models\\User',
          'notifiable_id': userId,
          'data': jsonEncode({
            'title': 'Permintaan Tukar Shift',
            'message': '$partnerName ingin menukar $targetShift dengan shift kamu untuk hari Minggu, 22 Nov.',
            'category': 'swap',
            'action_type': 'swap_request',
            'partner_name': partnerName,
            'target_date': 'Minggu, 22 Nov 2026',
            'target_shift': targetShift,
            'swap_with': swapWith,
            'reason': 'Ada jadwal praktikum kuliah mendadak jam 13.00, minta tolong gantikan shift siang.',
            'status': 'pending',
          }),
          'read_at': null,
          'created_at': now.subtract(const Duration(minutes: 15)).toIso8601String(),
          'updated_at': now.subtract(const Duration(minutes: 15)).toIso8601String(),
        },
        {
          'type': 'App\\Notifications\\ShiftReminder',
          'notifiable_type': 'App\\Models\\User',
          'notifiable_id': userId,
          'data': jsonEncode({
            'title': 'Shift Segera Dimulai',
            'message': 'Shift kerja kamu segera aktif. Lakukan presensi foto selfie & GPS di outlet Cak Kebo.',
            'category': 'reminder',
            'action_type': 'attendance',
          }),
          'read_at': null,
          'created_at': now.subtract(const Duration(minutes: 40)).toIso8601String(),
          'updated_at': now.subtract(const Duration(minutes: 40)).toIso8601String(),
        },
        {
          'type': 'App\\Notifications\\BranchAnnouncement',
          'notifiable_type': 'App\\Models\\User',
          'notifiable_id': userId,
          'data': jsonEncode({
            'title': 'Restock Bahan Baku Cabang',
            'message': 'Biji kopi robusta house blend, fresh milk & sirup aren telah diperbarui di storage bar.',
            'category': 'outlet',
            'action_type': 'announcement',
          }),
          'read_at': now.subtract(const Duration(hours: 3)).toIso8601String(),
          'created_at': now.subtract(const Duration(hours: 3)).toIso8601String(),
          'updated_at': now.subtract(const Duration(hours: 3)).toIso8601String(),
        },
      ];

      for (final item in sampleList) {
        await _client.from('notifications').insert(item);
      }
    } catch (e) {
      debugPrint('Error inserting sample notifications: $e');
    }
  }

  /// Peringatan otomatis jika shift berakhir (Alfa) atau terlambat
  static Future<void> checkAndCreateShiftWarnings({
    required int userId,
    required bool isShiftExpired,
    required bool isLateNow,
    required String shiftName,
    required String shiftStartStr,
    required String shiftEndStr,
    required String lateStr,
  }) async {
    try {
      final now = DateTime.now();
      final todayStr = '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      if (isShiftExpired) {
        final existing = await _client
            .from('notifications')
            .select('id, data')
            .eq('notifiable_id', userId)
            .ilike('type', '%ShiftExpired%')
            .limit(10);

        bool alreadyCreated = false;
        for (final item in (existing as List)) {
          final data = item['data'];
          if (data is Map && data['date_key'] == todayStr) {
            alreadyCreated = true;
            break;
          } else if (data is String && data.contains(todayStr)) {
            alreadyCreated = true;
            break;
          }
        }

        if (!alreadyCreated) {
          await _client.from('notifications').insert({
            'type': 'App\\Notifications\\ShiftExpiredWarning',
            'notifiable_type': 'App\\Models\\User',
            'notifiable_id': userId,
            'data': jsonEncode({
              'title': 'Peringatan: Shift Berakhir (Alfa)',
              'message': '$shiftName telah berakhir pada pukul $shiftEndStr WIB. Presensi masuk telah ditutup dan sistem mencatat status Tidak Hadir (Alfa).',
              'category': 'alfa',
              'action_type': 'none',
              'date_key': todayStr,
            }),
            'read_at': null,
            'created_at': now.toUtc().toIso8601String(),
            'updated_at': now.toUtc().toIso8601String(),
          });
        }
      } else if (isLateNow) {
        final existing = await _client
            .from('notifications')
            .select('id, data')
            .eq('notifiable_id', userId)
            .ilike('type', '%ShiftLate%')
            .limit(10);

        bool alreadyCreated = false;
        for (final item in (existing as List)) {
          final data = item['data'];
          if (data is Map && data['date_key'] == todayStr) {
            alreadyCreated = true;
            break;
          } else if (data is String && data.contains(todayStr)) {
            alreadyCreated = true;
            break;
          }
        }

        if (!alreadyCreated) {
          await _client.from('notifications').insert({
            'type': 'App\\Notifications\\ShiftLateWarning',
            'notifiable_type': 'App\\Models\\User',
            'notifiable_id': userId,
            'data': jsonEncode({
              'title': 'Peringatan: Keterlambatan Shift',
              'message': '$shiftName telah dimulai pukul $shiftStartStr WIB (lewat $lateStr). Segera lakukan presensi agar keterlambatan tidak bertambah!',
              'category': 'late',
              'action_type': 'attendance',
              'date_key': todayStr,
            }),
            'read_at': null,
            'created_at': now.toUtc().toIso8601String(),
            'updated_at': now.toUtc().toIso8601String(),
          });
        }
      }
    } catch (e) {
      debugPrint('Error creating shift warning notification: $e');
    }
  }
}
