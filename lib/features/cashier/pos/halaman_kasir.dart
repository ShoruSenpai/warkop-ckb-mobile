import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/produk.dart';
import '../../../services/layanan_kasir.dart';
import '../../../services/layanan_keranjang.dart';
import '../../../services/layanan_presensi.dart';

class KasirScreen extends StatefulWidget {
  const KasirScreen({super.key});
  @override
  State<KasirScreen> createState() => _KasirScreenState();
}

class _KasirScreenState extends State<KasirScreen> {
  final _api = LayananPresensi.instance;
  final _kasir = LayananKasir();
  final _cart = CartService();
  List<Product> _products = [];
  Map<String, dynamic> _settings = {};
  String _category = 'Semua',
      _search = '',
      _orderType = 'Dine In',
      _paymentMethod = 'Tunai';
  String? _error;
  bool _loading = true, _paying = false;
  Timer? _timer;
  bool get _locked => _paying || _kasir.pending != null;
  String _rp(num value) => NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  ).format(value);

  @override
  void initState() {
    super.initState();
    _start();
    _timer = Timer.periodic(const Duration(seconds: 20), (_) {
      if (!_loading && !_paying) _load(silent: true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _start() async {
    try {
      if ((_api.statusTerakhir?['user'] as Map?)?['id'] == null) {
        await _api.status();
      }
      await _kasir.pulihkan();
      await _load();
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e is PresensiException
              ? e.pesan
              : 'Kasir gagal dibuka. Silakan login kembali.';
          _loading = false;
        });
      }
    }
  }

  Future<void> _load({bool silent = false}) async {
    if (!mounted) return;
    if (!silent) setState(() => _loading = true);
    try {
      final result = await _api.get('pos/catalog');
      final products = (result['products'] as List)
          .map((e) => Product.fromJson(e as Map<String, dynamic>))
          .toList();
      if (mounted) {
        setState(() {
          _products = products;
          _settings = result['settings'] as Map<String, dynamic>;
          if (!_paying) {
            _cart.taxRate =
                num.parse(_settings['tax_percent'].toString()).toDouble() / 100;
          }
          if (_category != 'Semua' &&
              !_products.any((e) => e.category == _category)) {
            _category = 'Semua';
          }
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(
          () => _error = e is PresensiException
              ? e.pesan
              : 'Katalog gagal diperbarui. Periksa koneksi server.',
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _message(String value) =>
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(value)));
  void _add(Product product) {
    if (_locked) return;
    final maximum = product.availableQuantity ?? 1000;
    if (_cart.quantityFor(product.id) >= maximum ||
        _cart.quantityFor(product.id) >= 1000) {
      _message('Stok ${product.name} tidak mencukupi.');
      return;
    }
    setState(() => _cart.addProduct(product));
  }

  Future<void> _checkout() async {
    if (_paying) return;
    if (_kasir.pending == null && (_error != null || _cart.items.isEmpty))
      return;
    setState(() => _paying = true);
    if (_kasir.pending == null) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Pembayaran sudah diterima?'),
          content: Text(
            'Catat pembayaran ${_rp(_cart.total)} melalui $_paymentMethod?\n\nUntuk QRIS/EDC, kasir memeriksa pembayaran terlebih dahulu. Aplikasi mencatat pembayaran secara manual.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Belum'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Sudah, catat penjualan'),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) {
        if (mounted) setState(() => _paying = false);
        return;
      }
    }
    setState(() => _paying = true);
    try {
      final sale = await _kasir.bayar(
        items: _cart.items,
        orderType: _orderType,
        paymentMethod: _paymentMethod,
        taxPercent: _cart.taxRate * 100,
      );
      if (!mounted) return;
      setState(() => _cart.clear());
      await Navigator.pushNamed(context, '/pesanan_berhasil', arguments: sale);
    } catch (e) {
      if (mounted) {
        _message(
          e is PresensiException ? e.pesan : 'Pencatatan belum terkonfirmasi. Ketuk cek/kirim ulang agar pesanan yang sama diproses tanpa transaksi ganda.',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _paying = false);
        _load(silent: true);
      }
    }
  }

  void _showCart() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, updateSheet) => Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Rincian pesanan',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _orderType,
                  decoration: const InputDecoration(labelText: 'Jenis pesanan'),
                  items: ['Dine In', 'Take Away']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: _locked
                      ? null
                      : (value) {
                          if (value != null) setState(() => _orderType = value);
                        },
                ),
                for (final item in _cart.items)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(item.name),
                    subtitle: Text(
                      '${_rp(item.price)} × ${item.quantity} = ${_rp(item.totalPrice)}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: _locked
                              ? null
                              : () {
                                  setState(
                                    () => _cart.decreaseItem(item.productId),
                                  );
                                  updateSheet(() {});
                                },
                          icon: const Icon(Icons.remove_circle_outline),
                        ),
                        Text('${item.quantity}'),
                        IconButton(
                          onPressed: _locked
                              ? null
                              : () {
                                  final product = _products
                                      .where((p) => p.id == item.productId)
                                      .firstOrNull;
                                  if (product != null) _add(product);
                                  updateSheet(() {});
                                },
                          icon: const Icon(Icons.add_circle_outline),
                        ),
                      ],
                    ),
                  ),
                const Divider(),
                Text('Subtotal: ${_rp(_cart.subtotal)}'),
                Text(
                  'Pajak ${(_cart.taxRate * 100).toStringAsFixed(2)}%: ${_rp(_cart.tax)}',
                ),
                Text(
                  'Total ${_rp(_cart.total)}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _paymentMethod,
                  decoration: const InputDecoration(
                    labelText: 'Metode pembayaran',
                  ),
                  items: ['Tunai', 'QRIS', 'Debit / EDC']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: _locked
                      ? null
                      : (value) {
                          if (value != null) {
                            setState(() => _paymentMethod = value);
                          }
                        },
                ),
                const SizedBox(height: 16),
                const Text(
                  'Catat setelah pembayaran diterima. Harga dan kecukupan seluruh bahan diperiksa kembali oleh server.',
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _locked || _error != null || _cart.items.isEmpty
                        ? null
                        : () {
                            Navigator.pop(ctx);
                            _checkout();
                          },
                    child: const Text('Konfirmasi pembayaran'),
                  ),
                ),
                TextButton(
                  onPressed: _locked
                      ? null
                      : () {
                          setState(() => _cart.clear());
                          Navigator.pop(ctx);
                        },
                  child: const Text('Kosongkan keranjang'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = ['Semua', ..._products.map((e) => e.category).toSet()];
    final products = _products
        .where(
          (e) =>
              (_category == 'Semua' || e.category == _category) &&
              e.name.toLowerCase().contains(_search.toLowerCase()),
        )
        .toList();
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        title: Text(_settings['store_name'] as String? ?? 'Kasir Warkop CKB'),
        actions: [
          if (_api.pengelola)
            IconButton(
              onPressed: () => Navigator.pushNamed(context, '/owner'),
              icon: const Icon(Icons.dashboard_outlined),
            ),
          IconButton(
            onPressed: _loading || _paying ? null : () => _load(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_loading || _paying) const LinearProgressIndicator(),
          if (_error != null)
            MaterialBanner(
              content: Text(_error!),
              actions: [
                TextButton(
                  onPressed: () => _load(),
                  child: const Text('Coba lagi'),
                ),
              ],
            ),
          if (_kasir.pending != null)
            MaterialBanner(
              content: const Text(
                'Ada penjualan yang belum terkonfirmasi. Periksa / kirim ulang pesanan yang sama sebelum membuat pesanan baru.',
              ),
              actions: [
                TextButton(
                  onPressed: _paying ? null : _checkout,
                  child: const Text('Cek / kirim ulang'),
                ),
              ],
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) => setState(() => _search = value),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Cari menu dari web',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(),
              ),
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: categories
                  .map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(e),
                        selected: _category == e,
                        onSelected: (_) => setState(() => _category = e),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => _load(),
              child: products.isEmpty
                  ? ListView(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(32),
                          child: Text(
                            _loading
                                ? 'Memuat katalog…'
                                : _error != null
                                ? 'Katalog belum dapat dimuat.'
                                : 'Belum ada menu aktif yang cocok. Owner dapat menambahkan menu dan resep di web.',
                          ),
                        ),
                      ],
                    )
                  : LayoutBuilder(
                      builder: (context, constraints) => GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: constraints.maxWidth > 700 ? 4 : 2,
                          mainAxisExtent: 260,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: products.length,
                        itemBuilder: (ctx, index) {
                          final product = products[index];
                          return Card(
                            clipBehavior: Clip.antiAlias,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 100,
                                  width: double.infinity,
                                  child: product.imageUrl.isEmpty
                                      ? const ColoredBox(
                                          color: Color(0xFFEFF6FF),
                                          child: Icon(
                                            Icons.local_cafe,
                                            size: 42,
                                            color: Color(0xFF2563EB),
                                          ),
                                        )
                                      : Image.network(
                                          product.imageUrl,
                                          headers: const {
                                            'ngrok-skip-browser-warning': '1',
                                          },
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, _, _) => const Icon(
                                            Icons.local_cafe,
                                            size: 42,
                                          ),
                                        ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product.name,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(_rp(product.price)),
                                        Text(
                                          product.availableQuantity == null
                                              ? 'Stok tidak dihitung'
                                              : 'Tersedia ${product.availableQuantity} porsi',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color:
                                                product.availableQuantity == 0
                                                ? Colors.red
                                                : Colors.grey,
                                          ),
                                        ),
                                        const Spacer(),
                                        SizedBox(
                                          width: double.infinity,
                                          child: FilledButton(
                                            onPressed:
                                                _locked ||
                                                    _error != null ||
                                                    product.availableQuantity ==
                                                        0
                                                ? null
                                                : () => _add(product),
                                            child: Text(
                                              _cart.quantityFor(product.id) > 0
                                                  ? 'Tambah (${_cart.quantityFor(product.id)})'
                                                  : 'Tambah',
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            onPressed: _paying
                ? null
                : _kasir.pending != null
                ? _checkout
                : _cart.items.isEmpty
                ? null
                : _showCart,
            icon: const Icon(Icons.shopping_bag_outlined),
            label: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                _paying
                    ? 'Mencatat transaksi…'
                    : _kasir.pending != null
                    ? 'Cek penjualan belum terkonfirmasi'
                    : '${_cart.itemCount} item · ${_rp(_cart.total)} · Lihat pesanan',
              ),
            ),
          ),
        ),
      ),
    );
  }
}
