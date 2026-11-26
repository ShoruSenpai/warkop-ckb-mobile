# Design System

## Audit referensi

Satu file desain ditemukan: `reference/Screenshot 2026-11-25 192449.png`, preview Home Employee smartphone. Ciri utamanya header cobalt, latar biru pucat, permukaan putih, judul gelap tegas, ikon fungsional kecil, kartu dengan radius lembut, dan aksi utama cobalt. Screenshot juga memuat konten Employee yang tidak dibawa ke preview Tahap 1.

Karena hanya satu referensi yang tersedia, konsistensi antarhalaman atau duplikasi komponen belum dapat dibandingkan. Belum ada referensi tablet, typography specification, atau font asset. Asumsi tahap awal memakai font sistem Flutter, mempertahankan file referensi, dan menampilkan preview komponen netral.

## Token

- Palet terang: cobalt `#2458D3`, ink `#17243A`, slate `#63738F`, canvas `#F4F6FB`, putih, garis `#E2E7F0`; amber `#E2A33B` sebagai aksen kecil.
- Palet gelap memakai surface `#192333`, canvas `#101723`, teks `#F1F4FA`, cobalt terang `#9AB6FF`, dan garis `#344157`.
- Typography: sans sistem; display 32, headline 24, title 18/16, body 16/14; line height mendukung baca ponsel.
- Spacing: 4, 8, 12, 16, 20, 24, 32, 40 dp.
- Radius: kontrol 12, kartu 20, panel feature 28 dp. Tingkat radius membedakan jenis permukaan.
- Elevation: permukaan datar dengan garis tipis; tidak ada shadow dekoratif umum.

## Komponen lintas fitur

`AppButton`, `AppTextField`, `AppDialog`, `AppLoading`, `AppErrorView`, `AppEmptyState`, dan `ResponsiveContainer`. Contoh field memiliki label terlihat; tombol memiliki target minimal 48 dp; aksi retry hanya tampil jika callback tersedia.

## Preview dan theme

Preview sementara berada di `features/foundation_preview` dan memiliki toggle terang/gelap yang state-nya dikelola provider Riverpod. Kedua theme menggunakan skema warna dan typography sesuai brightness. Test memeriksa perubahan brightness saat toggle berpindah dua arah. Referensi awal tetap menjadi arah tampilan default.

Tombol dialog berfungsi. Route Employee lain hanya placeholder untuk memeriksa shell dan nav; tidak menampilkan status atau data Employee produksi.

Design Read untuk preview: **ENERGY 2 / RHYTHM 2 / MOTION 1**. Energi datang dari bidang cobalt yang diambil dari referensi; variasi ritme berasal dari panel pengenalan dan dua permukaan kerja dengan hirarki berbeda; motion dibatasi pada feedback interaksi bawaan agar preview operasional tetap tenang. Motif identitas yang dipertahankan adalah bidang cobalt dengan sudut panel yang lebar.
