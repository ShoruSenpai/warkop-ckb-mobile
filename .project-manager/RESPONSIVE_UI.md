# Responsive UI

- Klasifikasi memakai `MediaQuery.size.shortestSide`, bukan model perangkat atau orientasi: `<600 dp` phone, `>=600 dp` tablet.
- Phone memakai orientasi portrait. Tablet mengizinkan portraitUp dan landscape kiri/kanan agar dapat berputar otomatis.
- Layout menyesuaikan ruang yang tersedia melalui `LayoutBuilder`, breakpoint konten, dan `ResponsiveContainer`.
- Phone merender bottom navigation; tablet merender navigation rail dengan seluruh destination yang sama.
- Tablet portrait dan landscape mempertahankan route dan fitur; hanya susunan konten yang berubah.
- Ukuran jendela/split-screen memicu klasifikasi berdasarkan shortest side yang sedang tersedia. Rebuild mengikuti ruang terbaru.

Tahap 1 belum memiliki halaman bisnis. Android 16 dapat mengabaikan batas orientasi untuk app yang dianggap besar pada perangkat tertentu; policy diterapkan pada kelas phone, sedangkan tablet membebaskan rotasi. Perilaku device nyata masih perlu diuji ketika emulator/perangkat tersedia.
