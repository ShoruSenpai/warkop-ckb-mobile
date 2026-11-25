import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/item_keranjang.dart';
import 'layanan_presensi.dart';

class LayananKasir {
  LayananKasir({LayananPresensi? api, FlutterSecureStorage? storage})
    : api = api ?? LayananPresensi.instance,
      storage = storage ?? const FlutterSecureStorage();
  final LayananPresensi api;
  final FlutterSecureStorage storage;
  Map<String, dynamic>? pending;
  Future<String> _key() async {
    final id = (api.statusTerakhir?['user'] as Map?)?['id'];
    if (id == null) {
      throw const PresensiException(
        'Silakan login kembali sebelum membuka kasir.',
      );
    }
    final server = base64Url.encode(utf8.encode(await api.identitasServer()));
    return 'pos_pending_${server}_$id';
  }

  Future<void> pulihkan() async {
    final value = await storage.read(key: await _key());
    final id = (api.statusTerakhir?['user'] as Map?)?['id'];
    if (value == null && await storage.read(key: 'pos_pending_$id') != null) {
      throw const PresensiException(
        'Ada pesanan tertunda dari versi lama. Periksa riwayat transaksi bersama Owner sebelum memakai server baru.',
      );
    }
    pending = value == null ? null : jsonDecode(value) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> bayar({
    required List<CartItem> items,
    required String orderType,
    required String paymentMethod,
    required double taxPercent,
  }) async {
    final key = await _key();
    if (pending == null) {
      if (items.isEmpty) {
        throw const PresensiException('Keranjang masih kosong.');
      }
      final snapshot = {
        'request_id': LayananPresensi.requestId(),
        'order_type': orderType,
        'payment_method': paymentMethod,
        'expected_tax_percent': taxPercent,
        'items': items
            .map(
              (e) => {
                'product_id': int.parse(e.productId),
                'quantity': e.quantity,
                'expected_price': e.price,
              },
            )
            .toList(),
      };
      await storage.write(key: key, value: jsonEncode(snapshot));
      pending = snapshot;
    }
    try {
      final response = await api.post('pos/checkout', pending!);
      await storage.delete(key: key);
      pending = null;
      return response['sale'] as Map<String, dynamic>;
    } on PresensiException catch (error) {
      if ([400, 409, 422].contains(error.statusCode)) {
        await storage.delete(key: key);
        pending = null;
      }
      rethrow;
    }
  }
}
