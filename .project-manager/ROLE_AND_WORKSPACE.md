# Role dan Workspace

Empat role aplikasi memiliki workspace tersendiri: Employee, Cashier, Admin, dan Owner. Registry masing-masing terisolasi.

- **Employee:** nantinya Home, Presensi, Profile. Registry contoh tahap ini hanya menunjukkan metadata nav dan placeholder preview; tidak ada data atau alur absensi.
- **Cashier:** setelah login masuk ke Rest/Standby. Employee yang sedang bertugas mengisi PIN dan jadwal/identitasnya diverifikasi server Laravel sebelum POS. Akun Cashier dan employee bertugas adalah entitas berbeda.
- **Admin:** struktur workspace khusus; fitur administrasi belum dibuat.
- **Owner:** struktur workspace khusus; konten, permission, dan akses data belum dibuat.

Client tidak menjadi sumber kebenaran role atau permission. Route guard produksi belum dibuat dan tidak boleh dianggap tercakup oleh metadata nav.
