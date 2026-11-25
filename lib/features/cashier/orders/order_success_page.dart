import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../app/session/current_user.dart';

class OrderSuccessPage extends StatelessWidget {
  const OrderSuccessPage({
    required this.currentUser,
    required this.orderData,
    super.key,
  });

  final CurrentUser currentUser;
  final Map<String, dynamic> orderData;

  String _formatAmount(Object? value) {
    final amount = value is num ? value.round() : int.tryParse('$value');
    return amount == null
        ? '—'
        : NumberFormat.currency(
            locale: 'id_ID',
            symbol: 'Rp ',
            decimalDigits: 0,
          ).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final orderCode =
        (orderData['code'] ??
                orderData['order_number'] ??
                orderData['id'] ??
                '—')
            .toString();
    final orderType = (orderData['order_type'] ?? '—').toString();
    final paymentMethod = (orderData['payment_method'] ?? '—').toString();
    final items =
        (orderData['items'] is List ? orderData['items'] as List : const [])
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
    final createdAt = DateTime.tryParse('${orderData['created_at'] ?? ''}');

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        title: const Text('Pesanan Berhasil'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Color(0xFF0D9488),
                    size: 56,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Pembayaran Diterima',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 6),
                  const Text('Pesanan telah dikonfirmasi oleh server.'),
                  const SizedBox(height: 20),
                  _ReceiptRow(label: 'Nomor Pesanan', value: orderCode),
                  _ReceiptRow(label: 'Tipe Pesanan', value: orderType),
                  _ReceiptRow(label: 'Metode Pembayaran', value: paymentMethod),
                  _ReceiptRow(label: 'Kasir', value: currentUser.displayName),
                  if (createdAt != null)
                    _ReceiptRow(
                      label: 'Waktu',
                      value: DateFormat(
                        'd MMM yyyy, HH:mm',
                        'id_ID',
                      ).format(createdAt),
                    ),
                  const Divider(height: 28),
                  if (items.isEmpty)
                    const Text(
                      'Rincian item tidak dikirim dalam respons server.',
                    )
                  else
                    for (final item in items)
                      _ReceiptRow(
                        label:
                            '${item['qty'] ?? item['quantity'] ?? 1} × ${item['name'] ?? 'Menu'}',
                        value: _formatAmount(item['subtotal'] ?? item['total']),
                      ),
                  const Divider(height: 28),
                  _ReceiptRow(
                    label: 'Subtotal',
                    value: _formatAmount(orderData['subtotal']),
                  ),
                  _ReceiptRow(
                    label: 'Pajak',
                    value: _formatAmount(orderData['tax']),
                  ),
                  _ReceiptRow(
                    label: 'Total',
                    value: _formatAmount(orderData['total']),
                    isTotal: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () =>
                  Navigator.of(context).popUntil((route) => route.isFirst),
              child: const Text('Kembali ke POS'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  const _ReceiptRow({
    required this.label,
    required this.value,
    this.isTotal = false,
  });
  final String label;
  final String value;
  final bool isTotal;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontWeight: isTotal ? FontWeight.bold : null),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          value,
          style: TextStyle(fontWeight: isTotal ? FontWeight.bold : null),
        ),
      ],
    ),
  );
}
