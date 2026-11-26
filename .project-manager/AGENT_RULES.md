# Agent Rules

- Pada awal tahap, baca berurutan dokumen inti di README folder ini, lalu periksa kode aktual, Git status, dan SDK.
- Patuhi ROADMAP delapan tahap yang telah ditentukan. Jangan mulai tahap setelahnya tanpa instruksi developer.
- Jangan menimpa aset atau konfigurasi yang ada tanpa alasan. Jangan mengganti application ID scaffold tanpa keputusan.
- Jangan membuat fitur Employee, Cashier/POS, autentikasi, atau API pada Tahap 1.
- Riverpod menjadi state management tunggal. Hindari provider global yang mencampur fitur.
- Route dan nav metadata harus berasal dari registry per workspace. Tidak ada daftar nav hardcoded di renderer.
- Klasifikasi responsive berdasarkan shortestSide dan breakpoint 600 dp.
- Jangan memasang dependency tahap depan sampai digunakan.
- Sebelum integrasi API, audit Laravel secara read-only, kirim API readiness report, lalu menunggu persetujuan developer.
- Simpan status akurat: rencana tidak sama dengan implementasi; implementasi tidak sama dengan pengujian lulus.
- Jalankan format, analyze, test, dan build yang relevan; laporkan perintah dan hasil aktual, termasuk yang terblokir environment.
- Jika menemukan isu di luar scope, dokumentasikan; jangan memperbaikinya diam-diam.
