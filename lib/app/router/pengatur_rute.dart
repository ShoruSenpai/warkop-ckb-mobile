import 'package:flutter/widgets.dart';

import '../../models/bukti_absensi.dart';
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
    '/pesanan_berhasil': (context) => const PesananBerhasilPage(),
    '/jadwal': (context) => const JadwalScreen(),
    '/shift': (context) => const ShiftScreen(),
  };
}