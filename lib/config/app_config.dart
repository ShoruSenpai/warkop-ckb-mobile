/// SEMUA pengaturan koneksi ada di file ini.
/// Kalau alamat server atau nama endpoint website-mu berbeda, cukup ubah di sini.
class AppConfig {
  // Alamat API milik website/backend-mu (akhiri TANPA tanda "/").
  //  - Emulator Android : http://10.0.2.2:8000/api
  //  - HP asli (1 WiFi) : http://192.168.x.x:8000/api   (IP laptop yang menjalankan server)
  //  - Produksi         : https://domain-kamu.com/api   (wajib https)
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  static const Duration timeout = Duration(seconds: 20);

  // ----- Nama endpoint (ubah sesuai route backend-mu) -----
  static const String epLogin = '/login';                   // POST
  static const String epProducts = '/products';             // GET
  static const String epOrders = '/orders';                 // POST
  static const String epCheckIn = '/attendance/check-in';   // POST (multipart)

  // ----- Lokasi outlet (dipakai untuk cek radius di HP) -----
  // GANTI dengan koordinat outlet asli. Server tetap harus memeriksa ulang.
  static const double outletLat = -7.2654;
  static const double outletLng = 112.7483;
  static const double maxRadiusMeter = 50;

  // Pajak (PB1). Server tetap yang menentukan total akhir.
  static const double taxRate = 0.10;
}
