# Architecture

## Pola modul

Struktur yang dituju untuk modul yang memiliki implementasi:

```text
feature_name/
├── data/         # datasources, models, repository implementations
├── domain/       # entities, repository contracts, use cases when needed
└── presentation/ # pages, widgets, viewmodels
```

Lapisan hanya ditambahkan ketika ada tanggung jawab nyata. Halaman mempresentasikan state; ViewModel kelak memegang logika presentasi; repository menjadi batas akses data. Jangan memanggil HTTP/database langsung dari widget.

## Kondisi Tahap 1

- Riverpod dipasang sebagai state management; `ProviderScope` membungkus root.
- `appRouterProvider` adalah provider dependency yang menyediakan GoRouter dan melepas router saat provider ditutup.
- Navigation registry menyatukan path, workspace, label, ikon, urutan, visibility, permission metadata, nama route, dan page builder.
- `WorkspaceShell` mempertahankan navigation renderer pada halaman tingkat utama. Route detail dapat melepas shell melalui metadata route.
- `FoundationPreviewPage` hanyalah halaman development preview dan bukan dashboard operasional.

## Aturan dependency

Provider untuk dependency statis; gunakan Notifier/AsyncNotifier saat suatu fitur benar-benar memiliki state yang berubah. Tidak ada provider state bisnis pada Tahap 1. Repository/use case dibuat per fitur saat dibutuhkan.
