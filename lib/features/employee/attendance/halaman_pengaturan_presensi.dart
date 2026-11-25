import 'package:flutter/material.dart';

import '../../../models/lokasi_absensi.dart';
import '../../../services/layanan_kamera.dart';
import '../../../services/layanan_lokasi.dart';
import '../../../services/layanan_presensi.dart';

class PengaturanPresensiScreen extends StatefulWidget {
  const PengaturanPresensiScreen({super.key, this.api, this.lokasiService});
  final LayananPresensi? api;
  final LayananLokasi? lokasiService;
  @override
  State<PengaturanPresensiScreen> createState() =>
      _PengaturanPresensiScreenState();
}

class _PengaturanPresensiScreenState extends State<PengaturanPresensiScreen> {
  LayananPresensi get _api => widget.api ?? LayananPresensi.instance;
  final _nama = TextEditingController();
  final _radius = TextEditingController(text: '100');
  LokasiAbsensi? _lokasi;
  List<dynamic> _karyawan = [];
  int? _idKaryawan;
  bool _loading = true, _locating = false, _saving = false, _enrolling = false;
  bool _faceReady = false, _outletReady = false;
  String? _pesanLokasi, _pesanWajah, _loadError;
  bool get _sayaDipilih =>
      _idKaryawan == (_api.statusTerakhir?['user'] as Map?)?['id'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nama.dispose();
    _radius.dispose();
    super.dispose();
  }

  String _error(Object error) =>
      error is PresensiException || error is LayananLokasiException
      ? error.toString()
      : 'Proses gagal. Periksa koneksi lalu coba lagi.';

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final results = await Future.wait([
        _api.status(),
        _api.get('attendance/employees'),
      ]);
      if (!mounted) return;
      final status = results[0];
      _karyawan = results[1]['employees'] as List;
      final userId = (status['user'] as Map?)?['id'];
      _idKaryawan = _karyawan.any((e) => e['id'] == userId)
          ? userId as int
          : null;
      _faceReady = status['face_enrolled'] == true;
      final outlet = status['outlet'] as Map?;
      _outletReady = outlet != null;
      _nama.text = outlet?['name'] as String? ?? 'Warkop CKB';
      if (outlet != null) {
        _radius.text = outlet['radius_meters'].toString();
        _lokasi = LokasiAbsensi(
          latitude: (outlet['latitude'] as num).toDouble(),
          longitude: (outlet['longitude'] as num).toDouble(),
          akurasiMeter: 0,
        );
      }
    } catch (e) {
      if (mounted) _loadError = _error(e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _ambilLokasi() async {
    if (_locating) return;
    setState(() {
      _locating = true;
      _pesanLokasi = 'Mencari lokasi, maksimal 12 detik. Izinkan Lokasi jika browser bertanya.';
    });
    try {
      final lokasi = await (widget.lokasiService ?? LayananLokasi())
          .deteksiLokasi();
      if (!mounted) return;
      setState(() {
        _lokasi = lokasi;
        _outletReady = false;
        _pesanLokasi =
            'Lokasi diterima. Akurasi ±${lokasi.akurasiMeter.toStringAsFixed(0)} m. Ketuk Simpan titik dan radius.';
      });
    } catch (e) {
      if (mounted) setState(() => _pesanLokasi = _error(e));
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  Future<void> _simpan() async {
    final radius = int.tryParse(_radius.text);
    if (_saving || _locating) return;
    if (_nama.text.trim().isEmpty ||
        radius == null ||
        radius < 50 ||
        radius > 1000 ||
        _lokasi == null) {
      setState(
        () => _pesanLokasi =
            'Isi nama, ambil lokasi saat ini, lalu isi radius 50–1000 meter.',
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final lokasi = _lokasi!;
      await _api.post('attendance/outlet', {
        ..._api.lokasiBody(lokasi),
        'accuracy': lokasi.akurasiMeter > 0 ? lokasi.akurasiMeter : 1,
        'name': _nama.text.trim(),
        'radius_meters': radius,
      });
      if (mounted)
        setState(() {
          _outletReady = true;
          _pesanLokasi = 'Titik outlet tersimpan. Lokasi ini akan dipakai untuk memeriksa presensi.';
        });
    } catch (e) {
      if (mounted) setState(() => _pesanLokasi = _error(e));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _daftarWajah() async {
    final id = _idKaryawan;
    if (id == null || _enrolling) return;
    final employee = _karyawan.firstWhere((e) => e['id'] == id);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Daftarkan wajah ${employee['name']}?'),
        content: const Text(
          'Pastikan orang yang dipilih hadir di depan kamera dan menyetujui pendaftaran. Foto ini mengganti data wajah sebelumnya.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Buka kamera'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() {
      _enrolling = true;
      _pesanWajah = null;
    });
    try {
      final photo = await LayananKamera().ambilFoto(
        kameraDepan: true,
        context: context,
      );
      if (photo == null) return;
      if (mounted) setState(() => _pesanWajah = 'Memeriksa wajah di server…');
      final result = await _api.unggah(
        'attendance/faces/$id',
        await photo.readAsBytes(),
        {},
      );
      if (mounted)
        setState(() {
          _pesanWajah = result['message'] as String;
          if (_sayaDipilih) _faceReady = true;
        });
    } catch (e) {
      if (mounted) setState(() => _pesanWajah = _error(e));
    } finally {
      if (mounted) setState(() => _enrolling = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Pengaturan presensi')),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Uji sendiri dengan akun Owner',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const Text(
          '1. Simpan lokasi saat ini sebagai titik outlet. 2. Daftarkan wajah pada akunmu. 3. Mulai presensi; ambil foto wajah baru untuk dicocokkan.',
        ),
        if (_loading) const LinearProgressIndicator(),
        if (_loadError != null) ...[
          Text(_loadError!, style: const TextStyle(color: Colors.red)),
          TextButton(onPressed: _load, child: const Text('Muat ulang data')),
        ],
        const Divider(height: 32),
        const Text(
          '1 · Lokasi outlet',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        TextField(
          controller: _nama,
          enabled: !_loading && !_saving,
          decoration: const InputDecoration(labelText: 'Nama outlet'),
        ),
        TextField(
          controller: _radius,
          enabled: !_loading && !_saving,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Radius (meter)',
            helperText: '50–1000 meter. Untuk uji di titik yang sama, mulai dari 100 meter.',
          ),
        ),
        const SizedBox(height: 12),
        Text(_lokasi?.koordinat ?? 'Titik belum dipilih'),
        OutlinedButton.icon(
          onPressed: _loading || _locating || _saving ? null : _ambilLokasi,
          icon: _locating
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.my_location),
          label: Text(
            _locating
                ? 'Mencari lokasi (maks. 12 detik)…'
                : 'Gunakan lokasi saat ini',
          ),
        ),
        FilledButton(
          onPressed: _loading || _saving || _locating || _lokasi == null
              ? null
              : _simpan,
          child: Text(_saving ? 'Menyimpan…' : 'Simpan titik dan radius'),
        ),
        if (_pesanLokasi != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(_pesanLokasi!),
          ),
        const Divider(height: 32),
        const Text(
          '2 · Daftar wajah karyawan',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const Text(
          'Akunmu dipilih otomatis untuk uji sendiri. Pilihan karyawan tetap bisa digunakan ketika lokasi sedang dicari.',
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<int>(
          key: ValueKey('employee-$_idKaryawan-${_karyawan.length}'),
          initialValue: _idKaryawan,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Pilih karyawan'),
          items: _karyawan
              .map(
                (e) => DropdownMenuItem<int>(
                  value: e['id'] as int,
                  child: Text(
                    '${e['name']} (${e['email']})',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          onChanged: _loading || _enrolling
              ? null
              : (id) => setState(() => _idKaryawan = id),
        ),
        FilledButton.icon(
          onPressed: _loading || _enrolling || _idKaryawan == null
              ? null
              : _daftarWajah,
          icon: const Icon(Icons.face),
          label: Text(
            _enrolling
                ? 'Memproses wajah…'
                : _sayaDipilih
                ? 'Buka webcam dan daftarkan wajah saya'
                : 'Buka kamera dan daftarkan wajah',
          ),
        ),
        if (_pesanWajah != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(_pesanWajah!),
          ),
        const Divider(height: 32),
        const Text(
          '3 · Coba presensi',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          'Lokasi: ${_outletReady ? "tersimpan" : "belum disimpan"} · Wajah akunmu: ${_faceReady ? "terdaftar" : "belum terdaftar"}',
        ),
        FilledButton.icon(
          onPressed:
              !_loading &&
                  !_locating &&
                  !_enrolling &&
                  _outletReady &&
                  _faceReady
              ? () => Navigator.pushNamed(context, '/verifikasi_lokasi')
              : null,
          icon: const Icon(Icons.how_to_reg),
          label: const Text('Mulai presensi saya'),
        ),
        const Text(
          'Presensi tetap memerlukan lokasi asli dan wajah yang cocok. Jika berhasil, presensi benar-benar tercatat pada akun yang login.',
        ),
      ],
    ),
  );
}
