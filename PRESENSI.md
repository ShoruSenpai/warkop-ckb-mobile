# Presensi wajah dan lokasi

Aplikasi ini menggunakan API Laravel di `C:\laragon\www\warkop_ckb`. Panduan backend ada di `PRESENSI.md` pada repository tersebut.

## Menjalankan

### Memakai ngrok (ponsel atau browser)

1. Di komputer backend, jalankan MySQL dan `php artisan serve --host=0.0.0.0 --port=8000`.
2. Pada terminal lain jalankan `ngrok http 8000`.
3. Jalankan aplikasi dengan `flutter run` (atau `flutter run -d chrome` untuk web).
4. Pada halaman login, ketuk **Alamat server**, tempel URL HTTPS **Forwarding** ngrok, lalu **Cek & simpan**. Masukkan URL, bukan authtoken ngrok. `/api` ditambahkan otomatis.
5. Login memakai akun Laravel. Alamat tersimpan pada perangkat/browser ini; jika domain ngrok berubah, ubah dari halaman login tanpa build ulang. Perubahan alamat meminta login kembali.

Kedua perangkat cukup mempunyai internet; tidak harus menggunakan Wi-Fi/hotspot yang sama. Komputer backend, MySQL, Laravel, dan ngrok tetap harus menyala. Database hanya diakses Laravel, bukan langsung oleh Flutter. Kloning baru tetap perlu setup backend dan dependensi.

Default opsional untuk pengembang ada pada `lib/core/config/konfigurasi_api.dart`, melalui `flutter run --dart-define=API_BASE_URL=https://nama.ngrok-free.app/api`. Alamat tersimpan dari halaman login mengalahkan default ini. Endpoint `/api/mobile/server-info` harus tersedia pada backend terbaru.

### Emulator atau LAN

```powershell
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api
```

Alamat di atas untuk emulator Android. Ponsel fisik perlu alamat IP LAN komputer dan jaringan Wi-Fi yang sama, atau URL server HTTPS. Jalankan backend dengan `php artisan serve --host=0.0.0.0 --port=8000`.

Owner login memakai akun yang dibuat di backend. Tombol **Atur presensi** di beranda membuka pengaturan lokasi outlet dan pendaftaran wajah karyawan. Hak ini diperiksa berdasarkan `users.role = owner` di server.

Tetapkan titik outlet memakai **Gunakan lokasi saat ini**, isi radius, dan simpan. Daftarkan wajah setiap karyawan sebelum mencoba presensi. Akun karyawan memakai email/kata sandi yang terdaftar pada backend, bukan akun contoh aplikasi.

Presensi memeriksa lokasi, mengambil foto kamera, mengirim lokasi terbaru dan foto ke server, lalu membuka bukti sukses setelah server mengonfirmasi. Foto dan koordinat saja tidak menghasilkan status berhasil. Presensi masuk dan pulang dibatasi masing-masing satu kali per hari WIB.

Pencocokan wajah dijalankan server dengan OpenCV YuNet/SFace. Belum termasuk liveness/anti-foto atau attestation perangkat. GPS `isMocked` ditolak pada aplikasi, tetapi klien yang dimodifikasi masih dapat memalsukan data; fitur ini belum menjamin anti-kecurangan.

HTTP tersedia hanya untuk debug Android. Gunakan HTTPS untuk release dan iOS.

## Pengujian

```powershell
flutter test --dart-define=API_BASE_URL=http://localhost/api
flutter analyze
```

Uji perangkat langsung tetap diperlukan: izin kamera/lokasi ditolak, GPS mati, di dalam/luar radius, wajah cocok/tidak cocok, foto tanpa/banyak wajah, koneksi putus saat mengirim, serta percobaan presensi masuk dan pulang.
