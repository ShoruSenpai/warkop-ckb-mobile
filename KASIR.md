# Kasir terhubung ke web

Gunakan backend Laravel Warkop CKB yang sama dengan presensi. Panduan lengkap ada pada `INTEGRASI-KASIR.md` di repository backend.

- Katalog contoh dan keranjang awal tidak dipakai pada layar kasir. Menu aktif, harga, foto, ketersediaan, dan pajak berasal dari server.
- Resep dan stok dikelola Owner lewat web. Kasir mengirim ID menu/jumlah; server menghitung total dan memotong stok sesuai resep.
- Pembayaran dikonfirmasi manual oleh kasir. QRIS/EDC belum terhubung payment gateway.
- Jika pengiriman tidak terkonfirmasi, gunakan **Cek / kirim ulang**. Pesanan disimpan per akun dengan ID yang sama agar tidak tercatat dua kali setelah restart aplikasi.
- Owner membuka **Pusat Owner** dari beranda untuk melihat seluruh data operasional dan membuka halaman web pengelolaan dengan login Owner.
- HTTP debug emulator memakai `--dart-define=API_BASE_URL=http://10.0.2.2:8000/api`. HP fisik perlu IP LAN komputer atau server HTTPS.

Tes: `flutter test --dart-define=API_BASE_URL=http://localhost/api`.
