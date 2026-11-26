# Tahap 1 — Implementation Plan

> Plan dikerjakan langsung di workspace yang ditentukan. Repo belum memiliki commit dan scaffold-nya untracked, sehingga pembuatan worktree akan mengharuskan commit awal atas seluruh scaffold.

**Goal:** Menyiapkan fondasi Flutter yang dapat dijalankan, diperiksa, dan diteruskan tanpa menambahkan fitur bisnis atau integrasi API.

**Architecture:** Pertahankan project Flutter yang ada. Tambahkan konfigurasi tema, Riverpod, route registry per workspace, shell navigasi berbasis metadata, utilitas responsive, dan satu halaman preview sementara.

**Tech Stack:** Flutter 3.47.2, Dart 3.13.2, flutter_riverpod, go_router, flutter_test, flutter_lints.

**Spec:** Instruksi Tahap 1 dari developer.

## Batasan

- Jangan mengubah application ID yang sudah ada.
- Jangan memasang Dio, sqflite, secure storage, atau preference storage pada tahap ini.
- Jangan membuat autentikasi, koneksi API, atau fitur Employee/POS.
- Klasifikasi perangkat memakai `shortestSide` dengan breakpoint 600 dp.
- Registrasi route dan metadata navigasi disimpan pada satu definisi per workspace.

## Fokus Review

1. Batas 599/600 dp dan rotasi tidak boleh salah mengklasifikasikan perangkat.
2. Registry dan renderer tidak boleh mencampur workspace atau menampilkan item tersembunyi.
3. Route detail tidak boleh ikut tampil di navigasi utama.
4. Halaman preview harus reflow untuk ponsel dan tablet.
5. Android build bergantung pada kesiapan lisensi SDK dan Gradle environment.

## Task

1. Periksa SDK, Git, dependency, Android toolchain, dan referensi; catat hambatan environment.
2. Tambahkan tes untuk klasifikasi responsive dan registry navigasi.
3. Tambahkan dependency Riverpod/GoRouter dan implementasikan model registry serta router.
4. Bangun design tokens, komponen global, responsive container, shell, dan preview sementara.
5. Siapkan direktori modul berikutnya dengan README, tanpa file Dart kosong atau business feature.
6. Lengkapi dokumen project manager dan checklist Tahap 1.
7. Jalankan format, analyze, test, dan Android debug build; laporkan setiap hambatan tanpa mengubah konfigurasi sistem.
