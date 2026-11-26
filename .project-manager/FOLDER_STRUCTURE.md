# Folder Structure

```text
lib/
├── main.dart
├── app/                    # bootstrap-level router, workspace, navigation, responsive
├── core/                   # batas infrastruktur bersama yang akan dipakai saat diperlukan
├── shared/                 # theme, widgets, components, utilities lintas fitur
└── features/
    ├── foundation_preview/ # development preview sementara
    ├── auth/               # ruang modul, belum diimplementasikan
    ├── employee/            # home, attendance, schedule, profile
    ├── cashier/             # standby, employee PIN, POS, transaksi
    ├── admin/
    └── owner/
```

Folder untuk modul yang belum dikerjakan berisi README tanggung jawab dan pola penempatan, bukan file Dart kosong. Struktur mengikuti feature-first. Di dalam fitur, gunakan `data/`, `domain/`, dan `presentation/` hanya ketika ada kode yang memerlukan lapisan tersebut. `app/` menyimpan wiring aplikasi; `core/` menyimpan infrastruktur; `shared/` hanya untuk kode lintas fitur.
