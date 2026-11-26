# Navigation System

GoRouter membuat route dari `WorkspaceRouteDefinition` pada `NavigationRegistry`. Definisi itu memuat `NavigationItem` yang menyimpan path, label, icon, urutan, workspace, status tampil, dan permission metadata opsional. Page builder dan nama route tersimpan bersama sehingga route dan nav tidak didaftarkan dua kali.

`NavigationRegistry.visibleFor(workspace)` mengambil dan mengurutkan item untuk satu workspace. `NavigationRenderer` hanya menerima metadata; renderer tidak memiliki daftar halaman. Ia menampilkan bottom bar untuk phone atau navigation rail untuk tablet. `WorkspaceShell` mempertahankan renderer pada route utama. Route dengan `useWorkspaceShell: false` dibuka tanpa shell.

Tahap 1 mengisi registry contoh Employee (Home, Presensi, Profile) untuk membuktikan mekanisme. Item detail tersembunyi menguji bahwa sebuah route tidak harus menjadi navigasi utama. Registry Cashier/Admin/Owner disediakan sebagai batas workspace kosong; navigasi operasional belum ditentukan.

Permission metadata belum ditegakkan. Jangan menganggap visibility UI sebagai kontrol akses. Guard otorisasi harus mengikuti data Laravel pada tahap berikutnya.
