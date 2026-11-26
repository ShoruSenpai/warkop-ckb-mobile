# API Integration Gate

Tahap 1 tidak mengirim request dan tidak menghubungkan endpoint Laravel. Flutter hanya klien; Laravel tetap sumber kebenaran autentikasi, role, permission, PIN, jadwal, presensi/geofence, harga/diskon, stok, transaksi, dan pembayaran.

Sebelum menulis integrasi API pada tahap berikutnya:

1. Identifikasi fitur Flutter dan kebutuhan endpoint.
2. Temukan direktori Laravel yang diberikan developer. Jika tidak diketahui/akses tidak ada, laporkan dan jangan menebak lokasi.
3. Audit read-only route, controller, FormRequest, API Resource, middleware, autentikasi/permission, dan dependency database.
4. Catat method, parameter, format request/response aktual, auth/permission, readiness, dan gap.
5. Sampaikan laporan API readiness untuk ditinjau.
6. Berhenti sebelum mengubah atau menulis integrasi sampai developer menyetujui.

Jangan membuat login produksi, mock endpoint yang dianggap nyata, respons yang diasumsikan, atau mengubah proyek Laravel.
