import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/session.dart';

class PesananBerhasilPage extends StatelessWidget {
  const PesananBerhasilPage({Key? key}) : super(key: key);

  static const Color primaryColor = Color(0xFF006194);
  static const Color primaryContainer = Color(0xFF007BB9);
  static const Color secondaryContainer = Color(0xFFBAE6FD);
  static const Color surfaceLow = Color(0xFFEFF4FF);
  static const Color onSurface = Color(0xFF0B1C30);
  static const Color onSurfaceVariant = Color(0xFF3F4850);

  @override
  Widget build(BuildContext context) {
    // Data pesanan dikirim dari kasir_page lewat Navigator arguments
    final d = _OrderData.from(context);
    final code = d.code;
    final orderType = d.orderType;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.local_cafe, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cak Kebo',
                  style: GoogleFonts.montserrat(
                    color: const Color(0xFF0B1C30),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'POS TERMINAL',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: secondaryContainer.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(Icons.table_restaurant, color: primaryColor, size: 16),
                  SizedBox(width: 6),
                  Text(
                    orderType,
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.point_of_sale, color: primaryColor, size: 18),
                      SizedBox(width: 4),
                      Text(
                        'Kasir POS / $orderType / ',
                        style: TextStyle(color: onSurfaceVariant, fontSize: 13),
                      ),
                      Text(
                        'Konfirmasi Pembayaran',
                        style: TextStyle(
                          color: const Color(0xFF0B1C30),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.cloud_done, color: primaryColor, size: 14),
                        SizedBox(width: 4),
                        Text(
                          'Ref: $code',
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 800) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 7, child: _buildLeftColumn(context)),
                        const SizedBox(width: 20),
                        Expanded(flex: 5, child: _buildRightColumn(context)),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        _buildLeftColumn(context),
                        const SizedBox(height: 20),
                        _buildRightColumn(context),
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeftColumn(BuildContext context) {
    final d = _OrderData.from(context);
    final code = d.code;
    final orderType = d.orderType;
    final payment = d.payment;
    final total = d.total;
    final whenStr = d.whenStr;
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: secondaryContainer.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: secondaryContainer.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Pembayaran Lunas & Terverifikasi',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Pesanan Berhasil Dibuat!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0B1C30),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Nomor Pesanan $code • $orderType • $payment',
                textAlign: TextAlign.center,
                style: TextStyle(color: onSurfaceVariant, fontSize: 13),
              ),
              const SizedBox(height: 20),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: surfaceLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Text(
                      'TOTAL TRANSAKSI DITERIMA',
                      style: TextStyle(
                        color: onSurfaceVariant,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          'Rp ',
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          NumberFormat.decimalPattern('id_ID').format(total),
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.schedule, size: 14, color: primaryColor),
                        SizedBox(width: 4),
                        Text(
                          whenStr,
                          style: TextStyle(
                            fontSize: 11,
                            color: onSurfaceVariant,
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          '•',
                          style: TextStyle(color: onSurfaceVariant),
                        ),
                        SizedBox(width: 10),
                        Icon(Icons.qr_code_2, size: 14, color: primaryColor),
                        SizedBox(width: 4),
                        Text(
                          'Metode: $payment',
                          style: TextStyle(
                            fontSize: 11,
                            color: onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: surfaceLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.restaurant,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tiket Otomatis Terkirim ke Bar & Dapur',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: const Color(0xFF0B1C30),
                            ),
                          ),
                          Text(
                            '2 Antrean Minuman • 1 Makanan',
                            style: TextStyle(
                              fontSize: 11,
                              color: onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Cetak KOT OK',
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'AKSI CEPAT TERMINAL',
                style: TextStyle(
                  color: onSurfaceVariant,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        Navigator.popUntil(
                          context,
                          ModalRoute.withName('/home'),
                        );
                      },
                      icon: const Icon(
                        Icons.add_circle,
                        color: Colors.white,
                        size: 20,
                      ),
                      label: const Text(
                        'Pesanan Baru',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: surfaceLow,
                        side: BorderSide.none,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Mencetak struk thermal...'),
                          ),
                        );
                      },
                      child: const Column(
                        children: [
                          Icon(Icons.print, color: primaryColor, size: 20),
                          SizedBox(height: 2),
                          Text(
                            'Cetak Struk',
                            style: TextStyle(
                              color: const Color(0xFF0B1C30),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: surfaceLow,
                        side: BorderSide.none,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Struk terkirim ke WhatsApp!'),
                          ),
                        );
                      },
                      child: const Column(
                        children: [
                          Icon(
                            Icons.send_to_mobile,
                            color: primaryColor,
                            size: 20,
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Kirim WA',
                            style: TextStyle(
                              color: const Color(0xFF0B1C30),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRightColumn(BuildContext context) {
    final d = _OrderData.from(context);
    final code = d.code;
    final orderType = d.orderType;
    final payment = d.payment;
    final subtotal = d.subtotal;
    final tax = d.tax;
    final total = d.total;
    final items = d.items;
    final rp = d.rp;
    int n(dynamic v) => _OrderData.n(v);
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.receipt_long, color: primaryColor, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Rincian Nota',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0B1C30),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: secondaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'PAID $code',
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: surfaceLow,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    _MetaRow(label: 'Tipe Pesanan', value: orderType),
                    const SizedBox(height: 6),
                    _MetaRow(label: 'Pembayaran', value: payment),
                    const SizedBox(height: 6),
                    _MetaRow(label: 'Kasir', value: Session.name),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                'ITEM DIPESAN',
                style: TextStyle(
                  color: onSurfaceVariant,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              ...items.expand<Widget>((it) => [
                    _ItemTile(
                      qty: '${it['qty']}x',
                      title: (it['name'] ?? '').toString(),
                      variant: (it['variant'] ?? '').toString(),
                      price: rp.format(n(it['price']) * n(it['qty'])),
                    ),
                    const SizedBox(height: 8),
                  ]),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: surfaceLow,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    _PriceRow(
                      label: 'Subtotal Penjualan',
                      value: rp.format(subtotal),
                    ),
                    SizedBox(height: 6),
                    _PriceRow(
                      label: 'PB1 / Pajak Resto (10%)',
                      value: rp.format(tax),
                    ),
                    SizedBox(height: 6),
                    _PriceRow(
                      label: 'Diskon Promosi',
                      value: '- Rp 0',
                      isDiscount: true,
                    ),
                    Divider(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Pembayaran',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: const Color(0xFF0B1C30),
                          ),
                        ),
                        Text(
                          rp.format(total),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MetaRow extends StatelessWidget {
  final String label;
  final String value;
  const _MetaRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF3F4850), fontSize: 12),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF0B1C30),
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _ItemTile extends StatelessWidget {
  final String qty;
  final String title;
  final String variant;
  final String price;

  const _ItemTile({
    required this.qty,
    required this.title,
    required this.variant,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF4FF).withOpacity(0.7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFBAE6FD),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              qty,
              style: const TextStyle(
                color: Color(0xFF006194),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Color(0xFF0B1C30),
                  ),
                ),
                Text(
                  variant,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF3F4850),
                  ),
                ),
              ],
            ),
          ),
          Text(
            price,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Color(0xFF0B1C30),
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDiscount;

  const _PriceRow({
    required this.label,
    required this.value,
    this.isDiscount = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF3F4850), fontSize: 12),
        ),
        Text(
          value,
          style: TextStyle(
            color: isDiscount ? const Color(0xFF006194) : const Color(0xFF0B1C30),
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

/// Membaca data pesanan dari Navigator arguments (dikirim oleh kasir_page).
class _OrderData {
  final String code;
  final String orderType;
  final String payment;
  final String whenStr;
  final int subtotal;
  final int tax;
  final int total;
  final List<Map<String, dynamic>> items;
  final NumberFormat rp =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  _OrderData._({
    required this.code,
    required this.orderType,
    required this.payment,
    required this.whenStr,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.items,
  });

  static int n(dynamic v) =>
      v is num ? v.round() : (double.tryParse(v?.toString() ?? '') ?? 0).round();

  factory _OrderData.from(BuildContext context) {
    final o = (ModalRoute.of(context)?.settings.arguments as Map?)
            ?.cast<String, dynamic>() ??
        <String, dynamic>{};
    final when = DateTime.tryParse((o['created_at'] ?? '').toString())?.toLocal() ??
        DateTime.now();
    return _OrderData._(
      code: (o['code'] ?? '-').toString(),
      orderType: (o['order_type'] ?? '-').toString(),
      payment: (o['payment_method'] ?? '-').toString(),
      whenStr: '${DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(when)} WIB',
      subtotal: n(o['subtotal']),
      tax: n(o['tax']),
      total: n(o['total']),
      items: ((o['items'] as List?) ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
    );
  }
}
