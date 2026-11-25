"""Build the Indonesian integration guide from the checked-out source.

Requires reportlab. Example:
python tools/docs/generate_guide.py --backend C:/laragon/www/warkop_ckb
"""
import argparse
import html
import textwrap
from pathlib import Path

from reportlab.lib import colors
from reportlab.lib.enums import TA_LEFT
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.platypus import (
    SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle,
    Preformatted, PageBreak, Flowable,
)

APP = Path(__file__).resolve().parents[2]
parser = argparse.ArgumentParser()
parser.add_argument('--backend', type=Path, required=True)
parser.add_argument('--output', type=Path, default=APP / 'docs/Panduan-Integrasi-dan-Presensi-Warkop-CKB.pdf')
args = parser.parse_args()
BACK = args.backend.resolve()
OUT = args.output.resolve()
OUT.parent.mkdir(parents=True, exist_ok=True)

font_dir = Path('C:/Windows/Fonts')
if (font_dir / 'arial.ttf').exists():
    font_files = [('Body', 'arial.ttf'), ('Bold', 'arialbd.ttf'), ('Mono', 'consola.ttf')]
    for name, file in font_files:
        pdfmetrics.registerFont(TTFont(name, str(font_dir / file)))
else:
    import reportlab
    font_dir = Path(reportlab.__file__).parent / 'fonts'
    for name, file in [('Body', 'Vera.ttf'), ('Bold', 'VeraBd.ttf'), ('Mono', 'VeraMono.ttf')]:
        pdfmetrics.registerFont(TTFont(name, str(font_dir / file)))
pdfmetrics.registerFontFamily('Body', normal='Body', bold='Bold')

NAVY = colors.HexColor('#142A43')
BLUE = colors.HexColor('#2563EB')
TEAL = colors.HexColor('#087F8C')
MUTED = colors.HexColor('#536577')
PALE = colors.HexColor('#F0F5FB')
LINE = colors.HexColor('#D9E2EE')
W, H = A4
MARGIN = 43
WIDTH = W - 2 * MARGIN
BODY_H = H - 121
styles = {
    'title': ParagraphStyle('title', fontName='Bold', fontSize=27, leading=33, textColor=NAVY, spaceAfter=16),
    'h': ParagraphStyle('h', fontName='Bold', fontSize=20, leading=25, textColor=NAVY, spaceAfter=14),
    'sub': ParagraphStyle('sub', fontName='Bold', fontSize=11, leading=15, textColor=TEAL, spaceBefore=8, spaceAfter=7),
    'p': ParagraphStyle('p', fontName='Body', fontSize=10.4, leading=14.6, textColor=NAVY, spaceAfter=8),
    'small': ParagraphStyle('small', fontName='Body', fontSize=8.1, leading=11, textColor=MUTED, spaceAfter=6),
    'cell': ParagraphStyle('cell', fontName='Body', fontSize=8.7, leading=11.8, textColor=NAVY),
    'th': ParagraphStyle('th', fontName='Bold', fontSize=8.5, leading=11.5, textColor=colors.white),
    'code': ParagraphStyle('code', fontName='Mono', fontSize=8, leading=10.7, textColor=NAVY, alignment=TA_LEFT),
}
pages = []
current = []

def p(text, kind='p'):
    current.append(Paragraph(text, styles[kind]))

def heading(text):
    global current
    if current:
        pages.append(current)
    current = []
    p(text, 'h')

def sub(text):
    p(text, 'sub')

def note(text):
    box = Table([[Paragraph(text, styles['p'])]], colWidths=[WIDTH])
    box.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, -1), PALE),
        ('BOX', (0, 0), (-1, -1), 0.6, LINE),
        ('LEFTPADDING', (0, 0), (-1, -1), 11),
        ('RIGHTPADDING', (0, 0), (-1, -1), 11),
        ('TOPPADDING', (0, 0), (-1, -1), 9),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 4),
    ]))
    current.extend([box, Spacer(1, 9)])

def table(headers, rows, widths):
    values = [[Paragraph(html.escape(str(x)), styles['th']) for x in headers]]
    values.extend([[Paragraph(html.escape(str(x)), styles['cell']) for x in row] for row in rows])
    obj = Table(values, colWidths=[WIDTH * f for f in widths], repeatRows=1, hAlign='LEFT')
    obj.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), NAVY),
        ('ROWBACKGROUNDS', (0, 1), (-1, -1), [colors.white, PALE]),
        ('VALIGN', (0, 0), (-1, -1), 'TOP'),
        ('GRID', (0, 0), (-1, -1), 0.4, LINE),
        ('LEFTPADDING', (0, 0), (-1, -1), 8),
        ('RIGHTPADDING', (0, 0), (-1, -1), 8),
        ('TOPPADDING', (0, 0), (-1, -1), 7),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 7),
    ]))
    current.extend([obj, Spacer(1, 9)])

def code(text, label='Contoh perintah'):
    p(html.escape(label), 'small')
    wrapped = []
    # Printed wrapping is for reading; the repository is the copyable source.
    for line in text.strip('\n').splitlines():
        wrapped.extend(textwrap.wrap(line.expandtabs(4), width=105, subsequent_indent='    ',
                                     replace_whitespace=False, drop_whitespace=False,
                                     break_long_words=True, break_on_hyphens=False) or [''])
    obj = Table([[Preformatted('\n'.join(wrapped), styles['code'])]], colWidths=[WIDTH])
    obj.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, -1), PALE),
        ('BOX', (0, 0), (-1, -1), 0.5, LINE),
        ('LEFTPADDING', (0, 0), (-1, -1), 10),
        ('RIGHTPADDING', (0, 0), (-1, -1), 10),
        ('TOPPADDING', (0, 0), (-1, -1), 9),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 9),
    ]))
    current.extend([obj, Spacer(1, 8)])

def excerpt(repo, path, start, end, occurrence=0):
    base = APP if repo == 'Flutter' else BACK
    lines = (base / path).read_text(encoding='utf-8-sig').splitlines()
    matches = [i for i, line in enumerate(lines) if start in line]
    if not matches:
        raise ValueError(f'Missing source marker: {path}: {start}')
    first = matches[occurrence]
    last = next(i for i in range(first, len(lines)) if end in lines[i])
    code(textwrap.dedent('\n'.join(lines[first:last + 1])), f'{repo} | {path} | baris {first + 1}-{last + 1}')

class Architecture(Flowable):
    def __init__(self):
        super().__init__()
        self.width, self.height = WIDTH, 122

    def draw(self):
        c = self.canv
        items = [('FLUTTER', 'Login, kamera, GPS, POS'), ('LARAVEL', 'API, aturan, verifikasi'), ('MYSQL', 'Data operasional bersama')]
        bw = 150
        for i, (title, desc) in enumerate(items):
            x = i * (WIDTH - bw) / 2
            c.setFillColor(NAVY if i == 1 else PALE)
            c.roundRect(x, 39, bw, 64, 9, fill=1, stroke=0)
            c.setFillColor(colors.white if i == 1 else NAVY)
            c.setFont('Bold', 10)
            c.drawCentredString(x + bw / 2, 79, title)
            c.setFont('Body', 7.6)
            c.drawCentredString(x + bw / 2, 60, desc)
            if i < 2:
                sx = x + bw + 4
                ex = (i + 1) * (WIDTH - bw) / 2 - 4
                c.setStrokeColor(TEAL)
                c.line(sx, 72, ex, 72)
                c.line(ex - 4, 76, ex, 72)
                c.line(ex - 4, 68, ex, 72)
        c.setFont('Body', 8)
        c.setFillColor(MUTED)
        c.drawString(0, 16, 'HTTPS ngrok membawa permintaan ke Laravel lokal; Python memproses wajah di server.')


# 1
p('WARKOP CKB / DOKUMENTASI TEKNIS', 'sub')
p('Integrasi web, aplikasi\n&amp; presensi wajah', 'title')
p('Kode yang dibuat, penjelasan alur, dan panduan mencoba', 'sub')
p('Edisi 25 November 2026 | Branch distribusi: <b>update-ainul</b>')
current.append(Architecture())
note('<b>Intinya:</b> Flutter berbicara ke REST API Laravel. Hanya Laravel yang mengakses MySQL. Menu, resep, penjualan, stok, dan presensi menggunakan sumber data backend yang sama.')
sub('Cara memakai dokumen')
table(['Bagian', 'Halaman'], [
    ('Peta kode Flutter, Laravel, dan endpoint', '2-4'),
    ('Kode koneksi, login, kasir, lokasi, dan wajah', '5-10'),
    ('Database dan akses Owner', '11'),
    ('Setup setelah clone dan menjalankan di web/ngrok', '12-14'),
    ('Uji presensi, kasir, dan penanganan masalah', '15-17'),
    ('Bukti pengujian, batasan, dan referensi', '18'),
], [.78, .22])
p('Potongan kode diambil dari checkout yang diperiksa. Baris panjang dibungkus agar terbaca; gunakan berkas repository sebagai sumber kode lengkap. Dokumen tidak berisi kredensial atau foto karyawan.', 'small')

# 2
heading('01 / Peta kode Flutter')
p('Repository: ShoruSenpai/warkop-ckb-mobile. Nama package Dart tetap <b>mobile_ckb</b>. Entry point sekarang memakai struktur sesi dan navigasi dari branch shoru.')
table(['Berkas / folder', 'Yang dikerjakan'], [
    ('lib/services/layanan_presensi.dart', 'Alamat server tersimpan, pengecekan server-info, token, JSON, unggah foto multipart, UUID, status presensi.'),
    ('lib/features/auth/presentation/halaman_masuk.dart', 'Form login dan dialog Alamat server / Cek & simpan. Tetap dipakai oleh halaman login baru.'),
    ('lib/features/auth/presentation/pages/login_page.dart', 'Penghubung form login dengan AuthRepository dan sesi baru.'),
    ('lib/features/auth/data/repositories/auth_repository.dart', 'POST email/password ke Laravel, simpan token dan identitas; logout.'),
    ('lib/core/network/http_api_client.dart', 'HTTP layer baru memakai alamat runtime dan header ngrok yang sama.'),
    ('lib/app/app.dart; app_dependencies.dart; router/; session/', 'Restore sesi, route guards, alias rute lama, pemetaan peran Owner/kasir/karyawan.'),
    ('lib/app/navigation/; lib/app/shells/', 'Footer per peran dan IndexedStack untuk mempertahankan keadaan tab.'),
    ('lib/services/layanan_kasir.dart; layanan_keranjang.dart', 'Snapshot checkout dan retry per server/akun; estimasi keranjang mengikuti pajak katalog.'),
    ('lib/services/layanan_lokasi.dart; layanan_kamera.dart', 'GPS dengan batas waktu, pemeriksaan akurasi/mock, pemilihan kamera native atau preview webcam.'),
], [.49, .51])
note('<b>Jalur aktif:</b> kasir dan presensi memakai layanan Laravel yang sudah diuji. Prototype repository dari shoru dengan /products, /orders, atau /attendance/check-in tetap ada sebagai bahan migrasi, tetapi bukan endpoint operasional yang dipakai layar aktif ini.')

# 3
heading('02 / Peta kode Laravel dan layar')
table(['Berkas / folder Laravel', 'Tanggung jawab'], [
    ('routes/api.php; routes/web.php', 'Endpoint mobile, autentikasi Sanctum, pembatasan frekuensi, serta halaman web Owner.'),
    ('app/Http/Controllers/AttendanceController.php', 'Login, status, outlet, daftar karyawan, enroll wajah, dan simpan presensi.'),
    ('app/Services/AttendanceFaceVerifier.php; AttendanceLocation.php', 'Proses Python, cosine similarity, Haversine, dan validasi radius/akurasi.'),
    ('tools/face/recognize.py; setup_models.py; requirements.txt', 'Deteksi YuNet, embedding SFace, pengunduhan model terverifikasi, dependensi Python.'),
    ('config/attendance.php; config/cors.php; app/Http/Middleware/TrustProxies.php', 'Lokasi model/Python, threshold, CORS API/gambar, dan HTTPS dari proxy lokal.'),
    ('app/Http/Controllers/PosController.php; app/Services/CheckoutService.php', 'Katalog, validasi pesanan, harga/pajak server, kunci stok, transaksi dan struk.'),
    ('app/Services/InventoryUnits.php; InventoryLedger.php', 'Konversi satuan, presisi stok, dan pencatatan mutasi sebelum/sesudah.'),
    ('app/Http/Controllers/OwnerController.php; app/Http/Middleware/RequireOwner.php', 'Dashboard/data lintas modul, pengaturan, tiket login web sekali pakai.'),
    ('app/Http/Controllers/PostController.php; resources/views/posts/', 'Kelola menu, foto, status aktif, dan resep per porsi di web.'),
    ('database/migrations/2026_11_18_000001...000003...', 'Tabel presensi, role Owner, resep, penjualan, mutasi stok, pembelian dan tiket web.'),
], [.54, .46])
p('<b>Layar Flutter aktif:</b> halaman_pengaturan_presensi.dart, halaman_verifikasi_lokasi.dart, halaman_verifikasi_wajah.dart, halaman_kamera_wajah.dart, halaman_kasir.dart, halaman_pesanan_berhasil.dart, dan features/owner/halaman_owner.dart. Semua berada di lib/features/.', 'small')

# 4
heading('03 / Kontrak API yang dipakai')
p('Seluruh path di tabel diawali <b>/api/mobile</b>. Permintaan terautentikasi membawa <b>Authorization: Bearer &lt;token&gt;</b>. Foto dikirim sebagai multipart field <b>photo</b>, bukan JSON base64.')
table(['Metode / path', 'Akses', 'Isi / hasil utama'], [
    ('GET /server-info', 'Publik', 'app=warkop-ckb, protocol=1, instance_id; tanpa data karyawan.'),
    ('POST /login', 'Publik', 'email, password -> token dan user.'),
    ('POST /logout', 'Login', 'Mencabut access token saat ini.'),
    ('GET /attendance/status', 'Login', 'user, face_enrolled, outlet, next_type, records.'),
    ('POST /attendance/location', 'Login', 'latitude, longitude, accuracy -> jarak dan outlet.'),
    ('GET /attendance/employees', 'Owner', 'Daftar akun untuk pendaftaran wajah.'),
    ('POST /attendance/outlet', 'Owner', 'name, latitude, longitude, accuracy, radius_meters.'),
    ('POST /attendance/faces/{user}', 'Owner', 'photo -> template untuk akun terpilih.'),
    ('POST /attendance', 'Login', 'request_id, type, latitude, longitude, accuracy, photo.'),
    ('GET /pos/catalog', 'Login', 'products, settings; stok tersedia dan pajak toko.'),
    ('POST /pos/checkout', 'Login', 'request_id, order_type, payment_method, expected_tax_percent, items.'),
    ('GET /pos/sales/{sale}', 'Kasir terkait / Owner', 'Struk; Owner juga melihat pemakaian stok.'),
    ('GET /owner/overview; /owner/data/{section}', 'Owner', 'Ringkasan dan daftar data lintas modul.'),
    ('POST /owner/web-ticket', 'Owner', 'target -> URL login web sekali pakai, 60 detik.'),
], [.39, .18, .43])
p('Item checkout memakai product_id, quantity, expected_price. Server menghitung nilai akhir. Middleware memeriksa role owner; label/jabatan pada tampilan tidak dapat menaikkan akses.', 'small')

# 5
heading('04 / Link ngrok tanpa edit kode')
p('Dialog login menyimpan URL setelah GET server-info berhasil. /api ditambahkan otomatis. Input dengan kredensial, query string, atau fragmen ditolak. Probe tidak mengirim email, kata sandi, atau bearer token.')
excerpt('Flutter', 'lib/services/layanan_presensi.dart', 'static String normalisasiAlamat(', '.toString();')
excerpt('Flutter', 'lib/services/layanan_presensi.dart', 'Future<void> aturServer(', 'Map<String, dynamic> info;')
p('Respons harus berisi app=warkop-ckb, protocol=1, dan instance_id yang tidak kosong. Alamat disimpan pada warkop_api_url, identitas pada warkop_server_id. Perubahan server/alamat menghapus sesi token lama sebelum login baru.')
code('flutter run -d chrome --dart-define=API_BASE_URL=https://nama.ngrok-free.app/api', 'Default opsional untuk pengembang')
note('Pilihan <b>Alamat server</b> yang tersimpan mengalahkan default --dart-define. Jangan menempelkan authtoken ngrok. Laravel dan tunnel tetap harus berjalan; ngrok bukan pengganti backend atau database.')

# 6
heading('05 / Login, token, dan navigasi')
p('Setelah merge shoru, login tetap memakai email Laravel. Respons user dipakai untuk peran; data yang sama juga diberikan ke layanan presensi agar ID kasir dan hak Owner konsisten.')
excerpt('Flutter', 'lib/features/auth/data/repositories/auth_repository.dart', 'final response = requireApiSuccess(', 'final root = response is Map')
excerpt('Flutter', 'lib/features/auth/data/repositories/auth_repository.dart', 'final user = CurrentUser.fromApi(', 'return user;')
excerpt('Flutter', 'lib/core/storage/flutter_secure_token_storage.dart', "static const _tokenKey", 'final FlutterSecureStorage _storage;')
p('<b>Satu token:</b> HttpApiClient dan LayananPresensi menggunakan presensi_token. auth_user menyimpan identitas untuk restore sesi. Sesi dan navigator direset ketika akun keluar; status 401 membersihkan sesi. Password tidak disimpan oleh aplikasi.')
table(['Peran dari Laravel', 'Tujuan / akses aplikasi'], [
    ('owner', 'Dashboard/data Owner, presensi, POS, jadwal dan profil; pengaturan outlet/wajah.'),
    ('kasir / cashier', 'POS lebih dulu, presensi, tukar shift, profil.'),
    ('karyawan / employee', 'Presensi, jadwal, profil.'),
], [.28, .72])
p('Alias lama seperti /kasir dan /verifikasi_wajah diarahkan ke router baru. Pengecekan role juga berlaku pada alias, dan aturan server tetap menjadi penentu akses.', 'small')

# 7
heading('06 / Penjualan memotong bahan')
p('Web menyimpan takaran resep per satu porsi. Katalog Flutter mengambil ID produk dan ketersediaan dari Laravel. Checkout mengunci akun, produk, bahan, dan pengaturan pajak dalam transaksi database.')
excerpt('Laravel', 'app/Services/CheckoutService.php', 'return DB::transaction(', "$products = Post::whereIn")
excerpt('Laravel', 'app/Services/CheckoutService.php', 'foreach ($needed as $id => $amount)', '$settings = DB::table')
p('Jumlah bahan = takaran per porsi yang dikonversi ke satuan stok x jumlah porsi. Pemotongan, sales, sale_items, dan inventory_movements disimpan atomik. Bila satu bahan kurang, seluruh checkout ditolak.')
table(['Bahan', 'Awal', 'Resep / gelas', '2 gelas', 'Sisa'], [
    ('Teh seduh', '10 liter', '200 ml', '0,4 liter', '9,6 liter'),
    ('Gula', '2 kg', '20 gram', '0,04 kg', '1,96 kg'),
], [.21, .18, .23, .18, .20])
p('Angka di atas hanya contoh uji. Konversi ml/liter dan gram/kg tersedia; massa tidak otomatis diubah menjadi volume. Stok memakai presisi enam desimal.')
note('<b>Retry aman:</b> aplikasi menyimpan request_id dan isi pesanan sebelum mengirim. Respons putus memakai snapshot yang sama. Backend mengecek ID dan hash payload agar retry tidak memotong stok dua kali. Jangan membuat pesanan baru untuk mengganti transaksi yang belum terkonfirmasi.')

# 8
heading('07 / Validasi lokasi yang sebenarnya')
p('GPS dibaca perangkat, lalu diperiksa ulang oleh Laravel. Titik outlet hanya dapat diubah Owner. Rumus Haversine menghitung jarak antara koordinat perangkat dengan titik outlet.')
excerpt('Laravel', 'app/Services/AttendanceLocation.php', 'public function validate(', 'return $distance;')
p('<b>Kriteria lolos:</b> akurasi harus lebih dari 0 dan maksimal 50 meter, serta <b>jarak + akurasi &lt;= radius outlet</b>. Contoh: jarak 70 m, akurasi 40 m, radius 100 m -> ditolak karena 110 m melewati batas.')
excerpt('Flutter', 'lib/services/layanan_lokasi.dart', 'final posisi = await Geolocator.getCurrentPosition(', 'if (posisi.isMocked)')
p('Pencarian posisi memiliki batas 10 detik, dengan deadline keseluruhan 12 detik. Pada web tidak ada requestPermission terpisah yang bisa menunggu tanpa batas. Lokasi dibaca lagi sebelum mengirim presensi; penanda isMocked dari OS ditolak.')
note('Izin lokasi yang sudah diberikan tidak menjamin perangkat memperoleh GPS akurat. Jika terlalu kasar, pindah ke area dengan sinyal lebih baik dan coba ulang; jangan mengganti lokasi dengan angka contoh atau melonggarkan validasi demi lolos.')

# 9
heading('08 / Pembuatan face recognition')
p('Kita memakai model pralatih OpenCV, bukan melatih model baru dari nol. YuNet mencari wajah; SFace membuat representasi numerik atau embedding. Pencocokan adalah <b>1:1 terhadap akun yang login</b>, bukan pencarian siapa orangnya di seluruh karyawan.')
excerpt('Laravel', 'tools/face/recognize.py', 'def embedding(', 'return recognizer.feature(')
p('Foto di-decode; ukuran maksimum kerja diperkecil ke sisi 1600 px. Foto harus berisi tepat satu wajah, lebar/tinggi wajah minimum 80 px, dan variansi Laplacian pada crop minimal 20. YuNet memakai score threshold 0.9 dan NMS 0.3. SFace melakukan alignment sebelum menghasilkan 128 nilai.')
note('<b>Pendaftaran:</b> foto karyawan -> deteksi dan crop -> embedding -> enkripsi di Laravel -> template akun.<br/><b>Presensi:</b> foto baru -> embedding -> cosine similarity dengan template akun -> bandingkan threshold -> simpan hanya jika wajah dan lokasi lolos.')
p('Model diunduh oleh setup_models.py dari revisi OpenCV Zoo yang dipatok. SHA-256 dibandingkan dengan pointer Git LFS sebelum file dipakai. Lisensi kedua model juga diunduh.', 'small')

# 10
heading('09 / Pencocokan dan perbaikan Windows')
p('Laravel menjalankan recognize.py melalui Symfony Process dengan timeout 30 detik. PHP menolak keluaran yang bukan 128 angka finite. Kesalahan mesin menjadi respons gagal, bukan presensi sukses.')
excerpt('Laravel', 'app/Services/AttendanceFaceVerifier.php', '$process = new Process(', '$process->run();')
excerpt('Laravel', 'app/Services/AttendanceFaceVerifier.php', '$dot = $a = $b = 0;', 'return $a > 0')
p('Cosine similarity = dot product dibagi hasil kali panjang kedua vektor. Nilai dibandingkan dengan ATTENDANCE_FACE_THRESHOLD, default <b>0.45</b>. Nilai ini bukan persentase keyakinan atau jaminan akurasi.')
excerpt('Laravel', 'app/Http/Controllers/AttendanceController.php', "DB::table('attendance_faces')->updateOrInsert", "'created_at' => now(), 'updated_at' => now(),")
p('Template dienkripsi memakai Crypt dan APP_KEY. Pendaftaran ulang mengganti template sebelumnya. Foto pendaftaran tidak disimpan permanen oleh alur enroll; yang disimpan adalah embedding terenkripsi.')
excerpt('Laravel', 'app/Services/AttendanceFaceVerifier.php', "$environment = ['SystemRoot'", "$environment = ['SystemRoot'")
note('Perbaikan error <b>mesin verifikasi wajah belum siap</b>: worker artisan di Windows pernah menghilangkan SystemRoot/WINDIR saat memanggil Python. Variabel ini sekarang diteruskan agar penyedia bilangan acak Windows dapat dimuat. stderr proses dicatat bila gagal; embedding tidak ditulis ke log.')

# 11
heading('10 / Database dan hak Owner')
table(['Data', 'Penyimpanan / tujuan'], [
    ('users', 'Akun Laravel, password hash dan role. Role owner menjadi syarat administrasi.'),
    ('attendance_outlets', 'Satu titik outlet bersama, nama, latitude, longitude dan radius.'),
    ('attendance_faces', 'Satu template terenkripsi per user_id, serta enrolled_by.'),
    ('attendances', 'UUID, tanggal WIB, masuk/pulang, koordinat, akurasi, jarak, skor, waktu dan path foto.'),
    ('product_recipes; posts; ingredients', 'Menu, takaran per porsi, satuan dan saldo bahan/stok produk.'),
    ('sales; sale_items; inventory_movements', 'Struk, rincian transaksi, pemakaian bahan dan saldo sebelum/sesudah.'),
    ('stock_purchases; pos_settings', 'Pembelian supplier dan pengaturan toko/pajak yang dibaca kasir.'),
    ('owner_web_tickets', 'Hash tiket login web, target, pengguna dan masa berlaku 60 detik.'),
], [.43, .57])
sub('Aturan yang sudah diterapkan')
p('Presensi masuk dan pulang masing-masing sekali per user per tanggal Asia/Jakarta. Pulang memerlukan presensi masuk pada tanggal yang sama. request_id yang sama mengembalikan hasil lama; penambahan record dilindungi transaksi dan constraint unik.')
p('Foto bukti presensi disimpan di storage/app/private/attendance, bukan folder publik. Template, foto, token, serta kredensial database tidak dikirim ke daftar umum Owner atau dimasukkan ke Git.')
p('Tombol kelola web dari aplikasi membuat tiket sekali pakai. Backend mengecek role lagi saat tiket digunakan. Token API tidak disisipkan ke URL web.')
note('APP_KEY diperlukan untuk membaca template terenkripsi. Simpan key bersama strategi backup; menggantinya begitu saja membuat template lama tidak terbaca. Setiap instalasi baru harus mengatur titik outlet dan mendaftarkan wajah kembali jika tidak memakai database/key yang sama.')

# 12
heading('11 / Setup setelah clone')
p('Perangkat pengembangan: Flutter SDK yang cocok dengan pubspec, PHP 8.3 beserta ekstensi Laravel, Composer, Node.js/npm, MySQL, dan Python 3.10. Versi Python tersebut yang dipakai pada pengujian lokal ini. Gunakan branch yang sama untuk kedua repository.')
code(r'''git clone -b update-ainul https://github.com/ainulhakimah270807-lab/warkop_ckb.git
git clone -b update-ainul https://github.com/ShoruSenpai/warkop-ckb-mobile.git''', 'Terminal PowerShell | folder kerja pilihanmu')
code(r'''cd warkop_ckb
composer install
Copy-Item .env.example .env
# Edit DB_* di .env dan buat database MySQL yang sesuai.
php artisan key:generate
php artisan migrate
npm ci
npm run build
php artisan presensi:owner owner-baru@contoh.id''', 'Terminal backend | instalasi baru, bukan database yang sudah berjalan')
p('Sesuaikan DB_HOST, DB_PORT, DB_DATABASE, DB_USERNAME dan DB_PASSWORD di .env milikmu. Untuk instalasi yang sudah ada, pertahankan .env dan APP_KEY; cukup instal dependensi dan jalankan migrasi yang belum diterapkan.')
p('Perintah presensi:owner menolak email yang sudah ada dan menampilkan kata sandi acak sekali saat berhasil. Simpan secara pribadi. Untuk memberikan peran Owner ke akun yang sudah ada, gunakan php artisan presensi:admin email@contoh.id.')
code(r'''cd ..\warkop-ckb-mobile
flutter pub get''', 'Terminal aplikasi')
note('Clone hanya mengambil kode. Database, akun lokal, model ONNX, virtual environment Python, .env dan foto tidak ikut dikirim ke repository. Siapkan langkah berikut sebelum mencoba presensi.')

# 13
heading('12 / Menyiapkan mesin wajah')
p('Jalankan perintah berikut dari folder Laravel. Contoh menggunakan Windows; python harus menunjuk ke Python 3.10 yang akan membuat virtual environment untuk dependensi terkunci ini.')
code(r'''python -m venv tools/face/.venv
.\tools\face\.venv\Scripts\python.exe -m pip install -r tools/face/requirements.txt
.\tools\face\.venv\Scripts\python.exe tools/face/setup_models.py
php artisan optimize:clear''', 'Terminal backend | pemasangan dependensi dan model')
code(r'''opencv-python-headless==4.10.0.84
numpy==1.26.4''', 'tools/face/requirements.txt')
table(['Yang harus tersedia', 'Lokasi default'], [
    ('Python virtual environment', 'tools/face/.venv/Scripts/python.exe'),
    ('Detektor YuNet', 'storage/app/private/face-models/yunet.onnx'),
    ('Pengenal SFace', 'storage/app/private/face-models/sface.onnx'),
    ('Konfigurasi Laravel', 'config/attendance.php'),
], [.40, .60])
p('Default Windows sudah menunjuk venv dan folder model tersebut. Jika berbeda, isi ATTENDANCE_PYTHON dan ATTENDANCE_MODELS di .env dengan path yang benar. Pada Linux, interpreter venv biasanya tools/face/.venv/bin/python.')
code(r'''ATTENDANCE_PYTHON="C:/lokasi/warkop_ckb/tools/face/.venv/Scripts/python.exe"
ATTENDANCE_MODELS="C:/lokasi/warkop_ckb/storage/app/private/face-models"
ATTENDANCE_FACE_THRESHOLD=0.45''', 'Contoh konfigurasi opsional | sesuaikan lokasi, bukan nilai wajib untuk semua komputer')
note('Jika Windows terpasang di lokasi khusus, atur ATTENDANCE_SYSTEM_ROOT ke folder Windows yang benar. Pastikan folder System32 ada di dalamnya. Jangan mengganti threshold hanya untuk memaksa wajah yang salah diterima.')

# 14
heading('13 / Menjalankan web dan ngrok')
p('Untuk setup ngrok pertama kali, ikuti pemasangan agent dan autentikasi pada panduan resmi https://ngrok.com/docs/getting-started. Authtoken dipasang di CLI milikmu, bukan di kolom Alamat server Flutter dan bukan di Git.', 'small')
code(r'''# Terminal 1, di folder Laravel; MySQL sudah menyala.
php artisan serve --host=0.0.0.0 --port=8000''', 'Backend Laravel')
code(r'''# Terminal 2; ngrok sudah terinstal dan akun ngrok sudah disiapkan.
ngrok http 8000''', 'Tunnel ke Laravel, bukan ke port Flutter')
code(r'''# Terminal 3, di folder Flutter.
flutter run -d chrome --dart-define=API_BASE_URL=http://127.0.0.1:8000/api
# Alternatif jika ingin membuka browser sendiri:
flutter run -d web-server --web-hostname=127.0.0.1 --web-port=8080''', 'Aplikasi dijalankan di browser, bukan emulator/HP')
sub('Hubungkan aplikasi')
p('1. Salin URL HTTPS pada bagian Forwarding ngrok, misalnya https://nama.ngrok-free.app.<br/>2. Buka login Flutter, ketuk <b>Alamat server</b>, tempel URL, lalu <b>Cek &amp; simpan</b>.<br/>3. Login menggunakan akun Laravel. Untuk web Owner, buka http://127.0.0.1:8000/login atau domain ngrok yang sama.')
p('Link ngrok berubah? Keluar akun, ganti Alamat server, lalu login lagi. URL tersimpan per perangkat/browser. Seluruh perangkat cukup punya internet; tidak harus berada pada Wi-Fi/hotspot yang sama.')
note('Kamera dan lokasi browser memerlukan konteks aman: localhost/127.0.0.1 pada komputer sendiri atau halaman HTTPS. Jika Flutter web dibuka di perangkat lain, halaman Flutter-nya juga perlu HTTPS; mengganti API menjadi HTTPS saja tidak membuat halaman frontend HTTP di IP LAN menjadi aman.')
p('Header ngrok-skip-browser-warning dipasang pada API dan gambar produk. config/cors.php mengizinkan preflight pada api/* dan menu-images/*. TrustProxies mempercayai proxy localhost agar URL gambar/tiket mengikuti HTTPS ngrok. Referensi ngrok ada di halaman 18.', 'small')

# 15
heading('14 / Coba presensi wajah + lokasi')
p('<b>1. Login Owner.</b> Buka tab Owner, lalu Atur presensi. Untuk uji sendiri, akun Owner yang sedang login dipilih otomatis; kamu juga bisa memilih karyawan yang memang sudah terdaftar.')
p('<b>2. Atur outlet.</b> Berdiri di lokasi uji yang akan dijadikan outlet. Isi nama, tentukan radius 50-1000 meter, tekan Gunakan lokasi saat ini, izinkan lokasi, lalu Simpan titik dan radius. Titik tidak berpindah otomatis mengikuti setiap orang yang absen.')
p('<b>3. Daftarkan wajah.</b> Pilih akun yang benar. Beri izin kamera. Pastikan preview webcam terlihat, satu wajah menghadap kamera, cukup terang, dekat, dan tidak buram. Ambil foto lalu kirim pendaftaran. Tunggu pesan berhasil.')
p('<b>4. Mulai presensi.</b> Gunakan Mulai presensi saya atau tab Absensi. Karyawan lain harus login dengan akun masing-masing. Ikuti verifikasi lokasi, ambil foto wajah baru, lalu kirim/tekan centang.')
p('<b>5. Periksa bukti.</b> Layar sukses harus berisi nomor presensi dan waktu server. Owner memeriksa data Presensi di Pusat Owner atau web. Izin kamera/GPS saja bukan bukti record tersimpan.')
table(['Skenario uji', 'Hasil yang diharapkan'], [
    ('Wajah terdaftar + lokasi lolos', 'Record tersimpan dan bukti server muncul.'),
    ('Wajah orang lain / tanpa enrollment', 'Ditolak, tidak membuat record sukses.'),
    ('Di luar radius / GPS akurasi > 50 m', 'Ditolak sebelum proses wajah.'),
    ('Tidak ada wajah / lebih dari satu / buram', 'Diminta mengambil foto ulang.'),
    ('Masuk dua kali hari yang sama', 'Record baru ditolak; retry ID yang sama tidak menduplikasi.'),
    ('Pulang tanpa masuk', 'Ditolak. Pulang baru boleh setelah masuk pada tanggal WIB yang sama.'),
], [.46, .54])
p('Untuk mengulang uji masuk/pulang pada hari yang sama, gunakan akun uji lain atau database uji terpisah. Jangan menghapus presensi operasional demi mengulang demo.', 'small')

# 16
heading('15 / Coba menu, resep, dan stok')
p('<b>1. Siapkan data uji.</b> Di web Owner, buat bahan Teh Seduh dengan stok 10 liter dan Gula dengan stok 2 kg. Gunakan data contoh pada database uji, atau bedakan nama bahan uji dari bahan operasional.')
p('<b>2. Buat menu Es Teh.</b> Pilih tipe Resep (BoM), isi harga dan status aktif. Masukkan resep satu gelas: 200 ml Teh Seduh dan 20 gram Gula. Simpan.')
p('<b>3. Buka POS Flutter.</b> Muat ulang katalog. Produk diperbarui saat layar dibuka, refresh, dan berkala sekitar 20 detik selama layar kasir aktif. Tambahkan 2 gelas, pilih tipe pesanan dan metode pembayaran.')
p('<b>4. Catat sesudah pembayaran diterima.</b> Periksa struk yang dikonfirmasi server. QRIS/EDC di fitur ini adalah pencatatan manual, belum integrasi payment gateway atau cetak printer otomatis.')
table(['Pemeriksaan di web / Owner', 'Hasil contoh'], [
    ('Penjualan dan rincian item', '2 Es Teh dengan harga/pajak dari server.'),
    ('Saldo Teh Seduh', '10 - (2 x 0,2) = 9,6 liter.'),
    ('Saldo Gula', '2 - (2 x 0,02) = 1,96 kg.'),
    ('Mutasi stok', 'Pemakaian, penjualan terkait, saldo sebelum dan sesudah.'),
], [.52, .48])
sub('Uji gagal yang perlu dicoba')
p('Buat bahan tidak cukup: seluruh checkout harus gagal dan bahan lain tidak ikut berkurang. Ubah harga/pajak setelah katalog dimuat: server meminta katalog/pesanan diperiksa ulang. Setelah koneksi terputus saat checkout, gunakan Cek penjualan belum terkonfirmasi agar ID yang sama dikirim ulang.')
note('Jangan langsung membuat transaksi baru jika transaksi lama belum terkonfirmasi. Catatan pending dipisahkan berdasarkan identitas backend dan akun, sehingga domain ngrok baru ke backend yang sama tetap dapat memulihkan transaksi lama.')

# 17
heading('16 / Jika percobaan belum berhasil')
table(['Gejala', 'Periksa / lakukan'], [
    ('Alamat server gagal dicek / 404 / HTML', 'Pastikan URL Forwarding HTTPS menuju Laravel port 8000; route /api/mobile/server-info ada; backend memakai branch update-ainul. Jangan tempel URL halaman /owner atau authtoken.'),
    ('Mesin verifikasi wajah belum siap (503)', 'Periksa storage/logs/laravel.log, path Python/model, paket OpenCV/numpy, izin baca model, dan SystemRoot/WINDIR pada worker Windows. Jalankan ulang setelah optimize:clear.'),
    ('Preview webcam hitam / tidak ada gambar', 'Izinkan kamera untuk origin Flutter, tutup aplikasi lain yang memakai kamera, pilih kamera yang tersedia, lalu buka ulang. Pastikan localhost atau HTTPS.'),
    ('GPS lama / tidak akurat', 'Izinkan lokasi browser dan OS, aktifkan lokasi presisi, coba area terbuka. Setelah deadline 12 detik, coba ulang. Akurasi harus <= 50 m dan jarak + akurasi masih di dalam radius.'),
    ('Wajah tidak cocok / buram / terlalu jauh', 'Pastikan akun login sesuai wajah yang didaftarkan. Hadapkan wajah, perbaiki cahaya, dekatkan kamera, dan ambil ulang foto. Enroll ulang hanya oleh Owner dengan identitas yang benar.'),
    ('401 / akun tidak punya akses', 'Login kembali; gunakan akun Laravel dan role owner untuk pengaturan. Role di tampilan saja tidak cukup. Domain baru dapat meminta login ulang.'),
    ('409 atau pesanan belum terkonfirmasi', 'Periksa perubahan harga/pajak atau presensi ganda. Untuk checkout yang responsnya putus, pulihkan ID lama dan periksa riwayat; jangan menggandakan transaksi.'),
], [.36, .64])
code(r'''php artisan optimize:clear
php artisan route:list --path=api/mobile''', 'Diagnostik backend yang tidak mengubah data bisnis')
p('Jangan mengirim isi .env, access token, kata sandi, foto karyawan, atau template wajah ke issue publik. Untuk laporan masalah cukup sertakan pesan error, endpoint/status HTTP, dan log yang sudah disamarkan.', 'small')

# 18
heading('17 / Verifikasi dan batasan')
table(['Pemeriksaan', 'Hasil pada checkout yang didokumentasikan'], [
    ('Flutter setelah merge shoru', '37 tes lulus; build web berhasil. Termasuk role, runtime URL/token, retry kasir, GPS, login/dialog alamat, navigasi Owner dan logout.'),
    ('Backend Laravel (SQLite in-memory)', '52 tes lulus, 235 assertions. Database operasional tidak dipakai untuk suite ini.'),
    ('Runtime OpenCV lokal', 'OpenCV 4.10.0; YuNet dan SFace berhasil dimuat. Pemeriksaan terpisah dari mock inferensi di tes endpoint.'),
    ('Koneksi ngrok sungguhan', 'Belum diuji memakai domain ngrok pengguna. Uji manual langkah 13-15 tetap diperlukan.'),
], [.39, .61])
code(r'''# Flutter
flutter test --dart-define=API_BASE_URL=http://localhost/api
# Backend: terminal uji terpisah, gunakan PHP dengan pdo_sqlite dan gd.
$env:DB_CONNECTION='sqlite'
$env:DB_DATABASE=':memory:'
php artisan test''', 'Menjalankan ulang pengujian | jangan memakai database operasional untuk tes')
p('<b>Batasan penting:</b> belum ada liveness/anti-foto, attestation perangkat, atau perlindungan penuh terhadap klien API yang dimodifikasi. Pencocokan wajah dan GPS bukan jaminan anti-kecurangan. Threshold 0.45 perlu dievaluasi dengan karyawan dan pencahayaan outlet. Hasil uji unit bukan bukti seluruh perangkat/kamera berhasil.')
p('Sistem saat ini memakai satu outlet/persediaan bersama, membutuhkan koneksi, serta belum menangani shift lintas tengah malam, retur/refund otomatis atau pembayaran online. Jadwal dan tukar shift dari shoru masih berisi data contoh. Tetapkan persetujuan serta kebijakan retensi/penghapusan biometrik sebelum pemakaian operasional.')
sub('Sumber dan versi kode')
p('Flutter: merge 45b2166 mencakup shoru 2047080 dan integrasi lokal sebelumnya. Branch distribusi berikutnya membawa PDF ini. Backend: implementasi Attendance, POS, Owner, dan migrasi yang dibaca langsung saat penyusunan.', 'small')
for label, url in [
    ('Kode Flutter', 'https://github.com/ShoruSenpai/warkop-ckb-mobile/tree/update-ainul'),
    ('Kode Laravel', 'https://github.com/ainulhakimah270807-lab/warkop_ckb/tree/update-ainul'),
    ('OpenCV: deteksi dan pengenalan wajah', 'https://docs.opencv.org/4.10.0/d0/dd4/tutorial_dnn_face.html'),
    ('ngrok: HTTP/S Agent Endpoints', 'https://ngrok.com/docs/gateway/endpoints/http'),
]:
    p(f'<b>{label}</b><br/><link href="{url}" color="#2563EB">{url}</link>', 'small')

pages.append(current)

def footer(canvas, doc):
    canvas.saveState()
    canvas.setStrokeColor(LINE)
    canvas.line(MARGIN, H - 38, W - MARGIN, H - 38)
    canvas.setFont('Bold', 8)
    canvas.setFillColor(MUTED)
    canvas.drawString(MARGIN, H - 27, 'WARKOP CKB  /  INTEGRASI & PRESENSI')
    canvas.setFont('Body', 8)
    canvas.drawRightString(W - MARGIN, H - 27, '25 November 2026')
    canvas.line(MARGIN, 39, W - MARGIN, 39)
    canvas.drawString(MARGIN, 26, 'update-ainul  |  Panduan kode dan percobaan')
    canvas.drawRightString(W - MARGIN, 26, f'{doc.page} / {len(pages)}')
    canvas.restoreState()

story = []
for i, contents in enumerate(pages, 1):
    measured = sum(item.wrap(WIDTH, 10000)[1] + item.getSpaceBefore() + item.getSpaceAfter() for item in contents)
    if measured > BODY_H - 12:
        raise ValueError(f'Page {i} too tall: {measured:.1f} > {BODY_H - 12:.1f}')
    print(f'page {i}: {measured:.1f} pt')
    if i > 1:
        story.append(PageBreak())
    story.extend(contents)
doc = SimpleDocTemplate(str(OUT), pagesize=A4, leftMargin=MARGIN, rightMargin=MARGIN,
                        topMargin=58, bottomMargin=55, title='Integrasi Web, Aplikasi dan Presensi Wajah - Warkop CKB',
                        author='Warkop CKB', subject='Kode Laravel-Flutter, face recognition, dan panduan pengujian')
doc.build(story, onFirstPage=footer, onLaterPages=footer)
print(f'PDF: {OUT}')
