# Offline Storage Plan

Ini rancangan untuk tahap selanjutnya. Tahap 1 belum memasang sqflite, secure storage, HTTP client, atau sinkronisasi.

## Kandidat dan kepemilikan data

- SQLite/sqflite menyimpan antrean lokal sementara dan metadata minimum, bukan salinan permanen seluruh server.
- Outbox records: event presensi, pesanan/transaksi POS, status pengiriman, waktu, dan unique event ID/idempotency key.
- File foto presensi berada di private app storage; database menyimpan path/metadata, bukan blob foto.
- Laravel tetap sumber kebenaran dan tujuan sinkronisasi.

## Outbox lifecycle

1. Bentuk aktivitas dan event ID.
2. Simpan sebagai pending secara lokal sebelum mencoba kirim.
3. Kirim ke Laravel dengan kunci idempotensi yang disepakati API.
4. Tandai synced hanya setelah konfirmasi server.
5. Kegagalan jaringan tetap pending dan dapat dicoba ulang.
6. Failed harus memiliki klasifikasi dan kebijakan penanganan; jangan dibuang tanpa aturan.

## Retensi dan cleanup

Retention period dikonfigurasi sebelum implementasi. Jangan hapus pending. Data synced dapat dibersihkan setelah retensi terpenuhi; foto yang telah diterima server dapat dihapus menurut kebijakan. Data failed hanya dibersihkan sesuai keputusan eksplisit. Cleanup harus konsisten antara record dan file serta dapat diaudit.
