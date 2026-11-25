import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PesananBerhasilPage extends StatelessWidget {
  const PesananBerhasilPage({super.key, required this.sale});
  final Map<String, dynamic> sale;
  String _rp(Object? value) => NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  ).format(num.parse(value.toString()));
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text('Transaksi #${sale['id']}'),
      automaticallyImplyLeading: false,
    ),
    body: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Icon(Icons.check_circle, size: 80, color: Colors.green),
        const SizedBox(height: 16),
        const Text(
          'Penjualan tersimpan',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const Text(
          'Stok bahan dan barang jadi telah diperbarui sesuai resep.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Text('Tanggal usaha: ${sale['business_date']} · WIB'),
        Text('Kasir: ${(sale['cashier'] as Map?)?['name'] ?? "—"}'),
        Text('${sale['order_type']} · ${sale['payment_method']}'),
        const Divider(),
        for (final item in sale['items'] as List)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(item['product_name'] as String),
            subtitle: Text('${item['quantity']} × ${_rp(item['unit_price'])}'),
            trailing: Text(_rp(item['total'])),
          ),
        const Divider(),
        Text('Subtotal ${_rp(sale['subtotal'])}'),
        Text('Pajak ${sale['tax_percent']}%: ${_rp(sale['tax'])}'),
        Text(
          'Total ${_rp(sale['total'])}',
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Pesanan berikutnya'),
        ),
        OutlinedButton(
          onPressed: () =>
              Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false),
          child: const Text('Kembali ke beranda'),
        ),
      ],
    ),
  );
}
