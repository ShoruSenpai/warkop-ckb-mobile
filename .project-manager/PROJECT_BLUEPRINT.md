# Project Blueprint

## Arsitektur

Gunakan Feature-First + MVVM + Repository Pattern. Presentation menampung halaman, widget fitur, dan ViewModel; Domain menampung entity, kontrak repository, serta use case saat dibutuhkan; Data menampung model, datasource, dan implementasi repository. Layer dibuat saat ada fitur yang memerlukannya, bukan sebagai file kosong.

Riverpod adalah satu-satunya state-management standar. `ProviderScope` berada di root; provider ditempatkan sesuai tanggung jawab. GoRouter membuat route dari `WorkspaceRouteDefinition` pada navigation registry. Metadata workspace dan navigasi berada di satu definisi route.

## Workspace

- Employee: contoh registry Home, Presensi, Profile. Tahap 1 hanya menampilkan preview navigasi generik.
- Cashier: ruang modul disiapkan; akun kasir dan employee bertugas akan dipisahkan pada tahap fitur.
- Admin dan Owner: ruang modul terpisah dengan kerangka yang dapat berbagi UI, tanpa fitur akses atau pemantauan pada Tahap 1.

## Responsive

Klasifikasi menggunakan `shortestSide`: di bawah 600 dp smartphone, 600 dp atau lebih tablet. Smartphone dikunci portrait; tablet mengizinkan portrait dan landscape. Renderer memilih bottom navigation untuk phone dan navigation rail untuk tablet. Isi menyesuaikan batas ruang, bukan hanya ukuran teks.

## Design

Referensi yang tersedia: `reference/Screenshot 2026-11-25 192449.png`. Referensi menonjolkan cobalt, permukaan putih, latar biru pucat, hierarki judul tegas, dan kartu dengan radius bertingkat. Tema tahap awal mengambil isyarat warna dan hierarki tersebut, tanpa membawa konten atau alur Employee ke halaman preview.

Keputusan yang belum diberikan developer: font brand khusus dan spesifikasi visual tablet lengkap. Tahap 1 memakai font sistem Flutter dan menetapkan token minimum yang mudah disesuaikan.

## Integrasi dan data

Tidak ada request HTTP atau konfigurasi endpoint. Tahap API menunggu audit Laravel read-only dan persetujuan developer sebagaimana dirinci di `API_INTEGRATION_GATE.md`. Desain outbox, retensi, dan file privat dicatat di `OFFLINE_STORAGE_PLAN.md`; tidak ada dependency penyimpanan offline diinstal pada Tahap 1.
