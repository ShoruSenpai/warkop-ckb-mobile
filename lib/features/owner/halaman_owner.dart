import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/layanan_presensi.dart';

class OwnerScreen extends StatefulWidget {
  const OwnerScreen({super.key});
  @override
  State<OwnerScreen> createState() => _OwnerScreenState();
}

class _OwnerScreenState extends State<OwnerScreen> {
  final _api = LayananPresensi.instance;
  final _search = TextEditingController();
  Map<String, dynamic>? _summary;
  List<dynamic> _rows = [];
  String _section = 'sales';
  int _page = 1, _lastPage = 1;
  bool _busy = false;
  String? _error;
  static const _sections = {
    'sales': 'Penjualan',
    'movements': 'Pemakaian & mutasi stok',
    'products': 'Menu & resep',
    'ingredients': 'Bahan baku',
    'attendances': 'Presensi',
    'employees': 'Akun & jabatan',
    'suppliers': 'Supplier',
    'purchases': 'Pembelian',
  };
  static const _web = {
    'dashboard': 'Dashboard web',
    'products': 'Kelola menu & resep',
    'ingredients': 'Kelola bahan baku',
    'purchases': 'Pembelian supplier',
    'reports': 'Laporan & ekspor',
    'notifications': 'Notifikasi stok',
    'settings': 'Pengaturan toko',
    'owner': 'Semua data Owner',
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load({int page = 1}) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final summary = await _api.get('owner/overview');
      final result = await _api.get(
        'owner/data/$_section?page=$page&search=${Uri.encodeQueryComponent(_search.text.trim())}',
      );
      if (mounted)
        setState(() {
          _summary = summary;
          _rows = result['data'] as List;
          _page = result['current_page'] as int;
          _lastPage = result['last_page'] as int;
        });
    } catch (e) {
      if (mounted)
        setState(
          () => _error = e is PresensiException
              ? e.pesan
              : 'Data gagal dimuat. Periksa koneksi.',
        );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _openWeb(String target) async {
    try {
      final ticket = await _api.post('owner/web-ticket', {'target': target});
      final url = Uri.parse(ticket['url'] as String);
      if (!['http', 'https'].contains(url.scheme) ||
          !await launchUrl(url, mode: LaunchMode.externalApplication))
        throw const PresensiException('Browser tidak dapat dibuka.');
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e is PresensiException ? e.pesan : 'Halaman web gagal dibuka.',
            ),
          ),
        );
    }
  }

  Future<void> _saleDetails(int id) async {
    try {
      final data = await _api.get('pos/sales/$id');
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Pemakaian transaksi #$id'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final move in data['usage'] as List? ?? [])
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        '${move['item_name']}\nTerpakai: ${-(num.parse(move['quantity'].toString()))} ${move['unit']}\nStok: ${num.parse(move['balance_before'].toString())} → ${num.parse(move['balance_after'].toString())} ${move['unit']}',
                      ),
                    ),
                  if ((data['usage'] as List? ?? []).isEmpty)
                    const Text(
                      'Tidak ada bahan atau barang jadi yang dihitung pada transaksi ini.',
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Tutup'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e is PresensiException ? e.pesan : 'Rincian gagal dimuat.',
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Pusat Owner'),
      actions: [
        IconButton(
          onPressed: _busy ? null : () => _load(page: _page),
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
    body: RefreshIndicator(
      onRefresh: () => _load(page: _page),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_summary != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Operasional ${_summary!['business_date']} · WIB',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      NumberFormat.currency(
                        locale: 'id_ID',
                        symbol: 'Rp ',
                        decimalDigits: 0,
                      ).format(_summary!['revenue_today']),
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    Text(
                      '${_summary!['sales_today']} transaksi · ${_summary!['low_stock']} bahan menipis · ${_summary!['attendances_today']} presensi',
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/kasir'),
                icon: const Icon(Icons.point_of_sale),
                label: const Text('Kasir'),
              ),
              OutlinedButton.icon(
                onPressed: () =>
                    Navigator.pushNamed(context, '/pengaturan_presensi'),
                icon: const Icon(Icons.face),
                label: const Text('Atur presensi'),
              ),
              PopupMenuButton<String>(
                onSelected: _openWeb,
                itemBuilder: (_) => _web.entries
                    .map(
                      (e) => PopupMenuItem(value: e.key, child: Text(e.value)),
                    )
                    .toList(),
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text('Buka / kelola di web ↗'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _section,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Data operasional',
              border: OutlineInputBorder(),
            ),
            items: _sections.entries
                .map(
                  (e) => DropdownMenuItem(value: e.key, child: Text(e.value)),
                )
                .toList(),
            onChanged: _busy
                ? null
                : (value) {
                    if (value == null) return;
                    setState(() {
                      _section = value;
                      _rows = [];
                      _search.clear();
                    });
                    _load();
                  },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _search,
            enabled: !_busy,
            onSubmitted: (_) => _load(),
            decoration: InputDecoration(
              labelText: 'Cari nama / nomor',
              suffixIcon: IconButton(
                onPressed: _busy ? null : () => _load(),
                icon: const Icon(Icons.search),
              ),
            ),
          ),
          if (_busy) const LinearProgressIndicator(),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            ),
          if (!_busy && _error == null && _rows.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text('Belum ada data.'),
            ),
          for (final row in _rows)
            Card(
              child: ExpansionTile(
                title: Text(row['title'] as String),
                subtitle: Text(row['subtitle'] as String),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final detail in row['details'] as List)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(detail as String),
                    ),
                  if (_section == 'sales')
                    TextButton(
                      onPressed: () => _saleDetails(row['id'] as int),
                      child: const Text('Lihat bahan yang terpakai'),
                    ),
                ],
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: !_busy && _page > 1
                    ? () => _load(page: _page - 1)
                    : null,
                icon: const Icon(Icons.chevron_left),
              ),
              Text('Halaman $_page / $_lastPage'),
              IconButton(
                onPressed: !_busy && _page < _lastPage
                    ? () => _load(page: _page + 1)
                    : null,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          const Text(
            'Menu dan stok diperbarui dari server saat halaman dimuat. Tarik ke bawah untuk memperbarui.',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    ),
  );
}
