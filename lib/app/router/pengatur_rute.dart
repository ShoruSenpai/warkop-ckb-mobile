import 'package:flutter/widgets.dart';

import '../../models/bukti_absensi.dart';
import '../../features/owner/halaman_owner.dart';
import '../../features/employee/attendance/halaman_pengaturan_presensi.dart';
import '../../models/lokasi_absensi.dart';
import '../../features/auth/presentation/halaman_masuk.dart';
import '../../features/cashier/orders/halaman_pesanan_berhasil.dart';
import '../../features/cashier/pos/halaman_kasir.dart';
import '../../features/cashier/shift/halaman_ganti_shift.dart';
import '../../features/employee/attendance/halaman_absen_berhasil.dart';
import '../../features/employee/attendance/halaman_absensi.dart';
import '../../features/employee/attendance/halaman_verifikasi_lokasi.dart';
import '../../features/employee/attendance/halaman_verifikasi_wajah.dart';
import '../../features/employee/profile/halaman_profil_karyawan.dart';
import '../../features/employee/schedule/halaman_jadwal_kerja.dart';

abstract final class AppRouter {
  static const initialRoute = '/login';

  static final Map<String, WidgetBuilder> routes = {
    '/': (context) => const HomeScreen(),
    '/login': (context) => const LoginScreen(),
    '/home': (context) => const HomeScreen(),
    '/owner': (context) => const OwnerScreen(),
    '/pengaturan_presensi': (context) => const PengaturanPresensiScreen(),
    '/verifikasi_lokasi': (context) => const VerifikasiLokasiScreen(),
    '/verifikasi_wajah': (context) {
      final lokasi = ModalRoute.of(context)?.settings.arguments;
      return lokasi is LokasiAbsensi
          ? VerifikasiWajahScreen(lokasi: lokasi)
          : const VerifikasiLokasiScreen();
    },
    '/absen_sukses': (context) {
      final bukti = ModalRoute.of(context)?.settings.arguments;
      return bukti is BuktiAbsensi
          ? AbsenSuksesScreen(bukti: bukti)
          : const VerifikasiLokasiScreen();
    },
    '/profil': (context) => const ProfilScreen(),
    '/kasir': (context) => const KasirScreen(),
    '/pesanan_berhasil': (context) {
      final sale = ModalRoute.of(context)?.settings.arguments;
      return sale is Map<String, dynamic>
          ? PesananBerhasilPage(sale: sale)
          : const KasirScreen();
    },
    '/jadwal': (context) => const JadwalScreen(),
    '/shift': (context) => const ShiftScreen(),
  };
}
