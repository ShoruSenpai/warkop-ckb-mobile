import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Session;

import '../services/session.dart';
import '../theme/app_theme.dart';
import 'main_tab_screen.dart';

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  bool _isUploadingAvatar = false;
  String _fullName = Session.name;
  String _position = Session.role;
  String _phone = (Session.user['phone_number'] != null && Session.user['phone_number'].toString().isNotEmpty)
      ? Session.user['phone_number'].toString()
      : '-';
  String _employeeCode = Session.employeeCode;
  String? _avatarUrl = Session.avatarUrl.isNotEmpty ? Session.avatarUrl : null;
  int _attendanceCount = Session.attendanceCount ?? 0;
  bool _isAttendanceLoaded = Session.attendanceCount != null;

  final Color primary = AppColors.primary;
  final Color primaryDark = AppColors.primaryDark;
  final Color primaryLight = AppColors.primaryLight;
  final Color secondary = AppColors.secondary;
  final Color surface = AppColors.surface;
  final Color surfaceContainerLowest = AppColors.surfaceContainerLowest;
  final Color surfaceContainerLow = AppColors.surfaceContainerLow;
  final Color onSurface = AppColors.onSurface;
  final Color onSurfaceVariant = AppColors.onSurfaceVariant;
  final Color borderLight = AppColors.borderLight;
  final Color errorContainer = AppColors.errorBg;
  final Color onErrorContainer = AppColors.error;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    try {
      final client = Supabase.instance.client;
      final emp = await client
          .from('employees')
          .select()
          .eq('id', Session.employeeId)
          .maybeSingle();

      final attendances = await client
          .from('attendances')
          .select('id')
          .eq('employee_id', Session.employeeId);

      if (mounted) {
        setState(() {
          if (emp != null) {
            _fullName = emp['full_name'] ?? _fullName;
            _position = emp['position'] ?? _position;
            _phone = (emp['phone_number'] != null && emp['phone_number'].toString().isNotEmpty)
                ? emp['phone_number'].toString()
                : _phone;
            _employeeCode = emp['employee_code'] ?? _employeeCode;
            _avatarUrl = emp['avatar_url'] ?? _avatarUrl;
          }
          final count = (attendances as List).length;
          _attendanceCount = count;
          _isAttendanceLoaded = true;
          Session.setAttendanceCount(count);
        });

        if (emp != null) {
          final u = Map<String, dynamic>.from(Session.user);
          if (emp['avatar_url'] != null) u['avatar_url'] = emp['avatar_url'];
          if (emp['phone_number'] != null) u['phone_number'] = emp['phone_number'];
          if (emp['full_name'] != null) u['name'] = emp['full_name'];
          Session.save(Session.token, u);
        }
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
    }
  }

  Future<void> _pickAndUploadAvatar(ImageSource source) async {
    Navigator.pop(context);
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (picked == null) return;

      setState(() => _isUploadingAvatar = true);
      final client = Supabase.instance.client;
      final file = File(picked.path);
      final ext = picked.path.split('.').last;
      final fileName = 'avatar_${Session.employeeId}_${DateTime.now().millisecondsSinceEpoch}.$ext';

      await client.storage.from('avatars').upload(fileName, file);
      final publicUrl = client.storage.from('avatars').getPublicUrl(fileName);

      try {
        await client
            .from('employees')
            .update({'avatar_url': publicUrl})
            .eq('id', Session.employeeId);
      } catch (e) {
        debugPrint('Catatan: kolom avatar_url belum ada di tabel employees DB: $e');
      }

      final updatedUser = Map<String, dynamic>.from(Session.user);
      updatedUser['avatar_url'] = publicUrl;
      await Session.save(Session.token, updatedUser);

      if (mounted) {
        setState(() {
          _avatarUrl = publicUrl;
          _isUploadingAvatar = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto profil berhasil diperbarui!')),
        );
      }
    } catch (e) {
      debugPrint('Gagal upload avatar: $e');
      if (mounted) {
        setState(() => _isUploadingAvatar = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengganti foto: $e')),
        );
      }
    }
  }

  void _showAvatarOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ubah Foto Profil',
                  style: AppTextStyles.h2,
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.camera_alt_rounded, color: AppColors.primary),
                  ),
                  title: Text(
                    'Ambil Foto dari Kamera',
                    style: AppTextStyles.subtitle,
                  ),
                  onTap: () => _pickAndUploadAvatar(ImageSource.camera),
                ),
                ListTile(
                  leading: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.photo_library_rounded, color: AppColors.primary),
                  ),
                  title: Text(
                    'Pilih dari Galeri',
                    style: AppTextStyles.subtitle,
                  ),
                  onTap: () => _pickAndUploadAvatar(ImageSource.gallery),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditBiodataDialog() {
    final nameCtrl = TextEditingController(text: _fullName);
    final phoneCtrl = TextEditingController(text: _phone == '-' ? '' : _phone);
    bool saving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Edit Biodata Karyawan',
                        style: AppTextStyles.h2,
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nama Lengkap',
                    style: AppTextStyles.bodyBold.copyWith(color: AppColors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      hintText: 'Masukkan nama lengkap',
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: AppColors.borderLight),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: AppColors.borderLight),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: AppColors.primary, width: 1.5),
                      ),
                      prefixIcon: const Icon(Icons.person_outline, size: 20),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nomor WhatsApp / Telepon',
                    style: AppTextStyles.bodyBold.copyWith(color: AppColors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: 'Contoh: 08123456789',
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: AppColors.borderLight),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: AppColors.borderLight),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: AppColors.primary, width: 1.5),
                      ),
                      prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      onPressed: saving
                          ? null
                          : () async {
                              final newName = nameCtrl.text.trim();
                              final newPhone = phoneCtrl.text.trim();
                              if (newName.isEmpty) return;

                              final messenger = ScaffoldMessenger.of(context);
                              setModalState(() => saving = true);
                              try {
                                final client = Supabase.instance.client;
                                await client.from('employees').update({
                                  'full_name': newName,
                                  'phone_number': newPhone,
                                }).eq('id', Session.employeeId);

                                final updatedUser = Map<String, dynamic>.from(Session.user);
                                updatedUser['name'] = newName;
                                updatedUser['phone_number'] = newPhone;
                                await Session.save(Session.token, updatedUser);

                                if (mounted) {
                                  setState(() {
                                    _fullName = newName;
                                    _phone = newPhone;
                                  });
                                }
                                if (ctx.mounted) Navigator.pop(ctx);
                                messenger.showSnackBar(
                                  const SnackBar(content: Text('Biodata berhasil diperbarui!')),
                                );
                              } catch (e) {
                                setModalState(() => saving = false);
                                messenger.showSnackBar(
                                  SnackBar(content: Text('Gagal menyimpan: $e')),
                                );
                              }
                            },
                      child: saving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Text(
                              'Simpan Perubahan',
                              style: AppTextStyles.button,
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: surfaceContainerLowest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Keluar Akun?',
            style: AppTextStyles.h2,
          ),
          content: Text(
            'Apakah Anda yakin ingin keluar dari sesi $_fullName?',
            style: AppTextStyles.body,
          ),
          actions: [
            TextButton(
              child: Text(
                'Batal',
                style: AppTextStyles.bodyBold.copyWith(color: onSurfaceVariant),
              ),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: onErrorContainer,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await Session.clear();
                if (!mounted) return;
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              },
              child: Text(
                'Ya, Keluar',
                style: AppTextStyles.bodyBold,
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: primary,
      body: SafeArea(
        bottom: false,
        child: Container(
          color: surface,
          child: RefreshIndicator(
            onRefresh: _loadProfileData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.topCenter,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 52),
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
                                width: 180,
                                height: 180,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.08),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              left: -40,
                              child: Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.06),
                                ),
                              ),
                            ),
                            Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.arrow_back_ios_new,
                                        color: Colors.white,
                                        size: 20,
                                      ),
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
                                    Text('Profil Karyawan', style: AppTextStyles.h3.copyWith(color: Colors.white)),
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
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Stack(
                                  alignment: Alignment.bottomRight,
                                  children: [
                                    GestureDetector(
                                      onTap: _showAvatarOptions,
                                      child: Container(
                                        width: 110,
                                        height: 110,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.white, width: 4),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.2),
                                              blurRadius: 12,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                          image: DecorationImage(
                                            image: (_avatarUrl != null && _avatarUrl!.isNotEmpty)
                                                ? NetworkImage(_avatarUrl!) as ImageProvider
                                                : const AssetImage('assets/images/logo_cak_kebo.png'),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        child: _isUploadingAvatar
                                            ? Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.black.withOpacity(0.5),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Center(
                                                  child: CircularProgressIndicator(
                                                    color: Colors.white,
                                                    strokeWidth: 2.5,
                                                  ),
                                                ),
                                              )
                                            : null,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: _showAvatarOptions,
                                      child: Container(
                                        width: 34,
                                        height: 34,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF2563EB),
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.white, width: 2.5),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.15),
                                              blurRadius: 4,
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.camera_alt,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(_fullName, style: AppTextStyles.h1.copyWith(color: Colors.white)),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.18),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.white.withValues(alpha: 0.28),
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        _position,
                                        style: AppTextStyles.badge.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '•',
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.5),
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      Session.outlet,
                                      style: AppTextStyles.body.copyWith(
                                        color: Colors.white.withValues(alpha: 0.95),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: -32,
                        left: 20,
                        right: 20,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                          decoration: BoxDecoration(
                            color: surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: borderLight, width: 1),
                            boxShadow: [
                              BoxShadow(
                                color: primary.withOpacity(0.12),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 38,
                                      height: 38,
                                      decoration: BoxDecoration(
                                        color: primaryLight,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(Icons.verified, color: primary, size: 20),
                                    ),
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _isAttendanceLoaded ? '$_attendanceCount Kali' : '... Kali',
                                          style: AppTextStyles.h3,
                                        ),
                                        Text('Total Kehadiran', style: AppTextStyles.caption),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Container(width: 1, height: 34, color: borderLight),
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 38,
                                      height: 38,
                                      decoration: BoxDecoration(
                                        color: AppColors.successBg,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.check_circle_outline,
                                        color: Color(0xFF15803D),
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Aktif', style: AppTextStyles.h3),
                                        Text('Status Akun', style: AppTextStyles.caption),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        // Card biodata karyawan
                        _buildDigitalStaffPass(),
                        const SizedBox(height: 14),

                        // Menu navigasi dan bantuan
                        Container(
                          decoration: BoxDecoration(
                            color: surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: borderLight, width: 1),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              ListTile(
                                onTap: () => Navigator.pushNamed(context, '/jadwal'),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                leading: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: primaryLight,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.calendar_month, color: primary, size: 20),
                                ),
                                title: Text('Jadwal & Shift Kerja', style: AppTextStyles.cardTitle),
                                subtitle: Text('Lihat kalender kerja dan shift', style: AppTextStyles.body),
                                trailing: Icon(Icons.chevron_right, color: secondary),
                              ),
                              Divider(color: borderLight, height: 1),
                              ListTile(
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Bantuan: Hubungi Manajer Outlet di 0812-3456-7890'),
                                    ),
                                  );
                                },
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                leading: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: primaryLight,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.support_agent, color: primary, size: 20),
                                ),
                                title: Text('Bantuan Operasional', style: AppTextStyles.cardTitle),
                                subtitle: Text('Kontak Manager Outlet & panduan', style: AppTextStyles.body),
                                trailing: Icon(Icons.chevron_right, color: secondary),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        ElevatedButton(
                          onPressed: _handleLogout,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: errorContainer,
                            foregroundColor: onErrorContainer,
                            elevation: 0,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.logout, size: 18),
                              const SizedBox(width: 8),
                              Text('Keluar Akun', style: AppTextStyles.bodyBold),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Column(
                          children: [
                            Text('Versi 1.0.0 • Cak Kebo POS & Attendance', style: AppTextStyles.overline),
                            const SizedBox(height: 4),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: TabNavigationScope.of(context) != null
          ? null
          : BottomNavigationBar(
              currentIndex: 3,
              onTap: (index) {
                if (index == 0) {
                  Navigator.pushReplacementNamed(context, '/home');
                } else if (index == 1) {
                  Navigator.pushReplacementNamed(context, '/jadwal');
                } else if (index == 2) {
                  Navigator.pushReplacementNamed(context, '/kasir');
                }
              },
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              selectedItemColor: primary,
              unselectedItemColor: secondary,
              selectedLabelStyle: AppTextStyles.captionBold,
              unselectedLabelStyle: AppTextStyles.captionBold,
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

  Widget _buildDigitalStaffPass() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFF0F7FF),
            Color(0xFFFFFFFF),
            Color(0xFFF8FAFC),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFBFDBFE), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/images/logo_cak_kebo.png',
                    width: 32,
                    height: 32,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 10),
                Text('WARKOP CAK KEBO', style: AppTextStyles.cardTitle.copyWith(letterSpacing: 0.5, fontWeight: FontWeight.w800)),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(color: AppColors.borderLight, height: 1),
          ),

          // ID dan tombol edit profil
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ID KARYAWAN', style: AppTextStyles.overline),
                    const SizedBox(height: 2),
                    Text(_employeeCode, style: AppTextStyles.h2.copyWith(letterSpacing: 2.0, fontWeight: FontWeight.w800, color: AppColors.primaryDark)),
                  ],
                ),
                InkWell(
                  onTap: _showEditBiodataDialog,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: surfaceContainerLow,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: borderLight),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.edit_outlined, size: 13, color: primary),
                        const SizedBox(width: 4),
                        Text('Edit', style: AppTextStyles.captionBold.copyWith(color: AppColors.primary)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Detail informasi karyawan
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                Expanded(
                  child: _buildPassFieldTile(
                    label: 'Nama Lengkap',
                    value: _fullName,
                    icon: Icons.person_outline_rounded,
                    iconColor: primary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildPassFieldTile(
                    label: 'Jabatan / Role',
                    value: _position,
                    icon: Icons.coffee_rounded,
                    iconColor: const Color(0xFFD97706),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                Expanded(
                  child: _buildPassFieldTile(
                    label: 'Nomor WhatsApp',
                    value: _phone,
                    icon: Icons.phone_android_rounded,
                    iconColor: AppColors.success,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildPassFieldTile(
                    label: 'Outlet Penugasan',
                    value: Session.outlet,
                    icon: Icons.storefront_outlined,
                    iconColor: const Color(0xFF7C3AED),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildPassFieldTile({
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.015),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 13, color: iconColor),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.overline,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.cardTitle.copyWith(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
