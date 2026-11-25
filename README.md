# mobile_ckb

Aplikasi Flutter Warkop CKB, terhubung ke backend Laravel.

## Panduan PDF

[Kode integrasi, face recognition, dan cara mencoba (18 halaman)](docs/Panduan-Integrasi-dan-Presensi-Warkop-CKB.pdf).

PDF berisi peta berkas/endpoint, potongan kode asli, penjelasan sesi dan ngrok, stok resep, YuNet/SFace, konfigurasi server, serta langkah uji di browser. Untuk membuat ulang dari checkout Flutter dan Laravel:

```powershell
python -m pip install reportlab
python tools/docs/generate_guide.py --backend ../warkop_ckb
```

## Hasil integrasi branch shoru

Entry point sekarang memakai `lib/app/app.dart`, router, sesi tersimpan, dan navigasi per peran dari `shoru`. Nama package tetap `mobile_ckb` agar kode dan pengujian aplikasi yang sudah berjalan tetap kompatibel.

Login memakai kontrak Laravel `POST /api/mobile/login` dengan `email` dan `password`. Pilihan **Alamat server** di login tetap tersedia untuk link ngrok. HTTP layer baru memakai alamat tersimpan yang sama, header ngrok, serta token `presensi_token` yang sama dengan layanan presensi/kasir.

Navigasi Owner menyediakan dashboard/data Owner, presensi, POS, jadwal, dan profil. Kasir membuka POS lebih dulu dan dapat melakukan presensi. Karyawan membuka presensi. Rute lama Indonesia dialihkan ke router baru dan diperiksa hak aksesnya.

Alur presensi dan checkout yang aktif tetap memakai `LayananPresensi` dan `LayananKasir`, melalui halaman yang sudah terhubung dengan Laravel. Ini mempertahankan verifikasi wajah/lokasi di server, pendaftaran wajah/titik outlet oleh Owner, stok resep, pajak server, dan pemulihan transaksi idempoten. Halaman presensi lama dipasang tanpa footer sendiri di shell baru. Repository/order/attendance dan halaman prototipe lain dari shoru tetap disimpan sebagai bahan migrasi; kontrak `/products`, `/orders`, dan `/attendance/check-in` di sana **bukan** jalur produksi Laravel ini. Jadwal dan tukar shift masih berisi data contoh dari branch sumber.

Panduan menjalankan aplikasi, backend, dan ngrok ada di [PRESENSI.md](PRESENSI.md). Integrasi menu/resep dan stok dijelaskan di [KASIR.md](KASIR.md).

```powershell
flutter pub get
flutter test --dart-define=API_BASE_URL=http://localhost/api
flutter run -d chrome --dart-define=API_BASE_URL=http://127.0.0.1:8000/api
```

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
