import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mobile_ckb/models/item_keranjang.dart';
import 'package:mobile_ckb/models/produk.dart';
import 'package:mobile_ckb/services/layanan_kasir.dart';
import 'package:mobile_ckb/services/layanan_keranjang.dart';
import 'package:mobile_ckb/services/layanan_presensi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const item = CartItem(
    productId: '5',
    name: 'Es teh',
    variant: '',
    price: 5000,
    quantity: 2,
  );
  setUp(
    () => FlutterSecureStorage.setMockInitialValues({
      'presensi_token': 'test-token',
    }),
  );
  LayananPresensi apiFor(http.Client client, {int user = 1}) {
    final api = LayananPresensi(client: client);
    api.statusTerakhir = {
      'user': {'id': user},
    };
    return api;
  }

  test(
    'uncertain checkout survives restart and retries the identical snapshot',
    () async {
      Map<String, dynamic>? first;
      final api = apiFor(
        MockClient((request) async {
          first = jsonDecode(request.body) as Map<String, dynamic>;
          throw TimeoutException('reply lost');
        }),
      );
      final cashier = LayananKasir(api: api);
      await expectLater(
        cashier.bayar(
          items: [item],
          orderType: 'Dine In',
          paymentMethod: 'Tunai',
          taxPercent: 0,
        ),
        throwsA(isA<TimeoutException>()),
      );
      expect(cashier.pending, isNotNull);
      final retryApi = apiFor(
        MockClient((request) async {
          expect(jsonDecode(request.body), first);
          return http.Response('{"sale":{"id":42,"total":10000}}', 201);
        }),
      );
      final restored = LayananKasir(api: retryApi);
      await restored.pulihkan();
      expect(restored.pending?['request_id'], first!['request_id']);
      // Even different UI inputs must not replace a possibly committed request.
      final sale = await restored.bayar(
        items: [],
        orderType: 'Take Away',
        paymentMethod: 'QRIS',
        taxPercent: 10,
      );
      expect(sale['id'], 42);
      expect(restored.pending, isNull);
      final clean = LayananKasir(api: retryApi);
      await clean.pulihkan();
      expect(clean.pending, isNull);
    },
  );

  test('definitive stock rejection clears pending request', () async {
    final api = apiFor(
      MockClient(
        (_) async => http.Response('{"message":"Bahan tidak cukup."}', 422),
      ),
    );
    final cashier = LayananKasir(api: api);
    await expectLater(
      cashier.bayar(
        items: [item],
        orderType: 'Dine In',
        paymentMethod: 'Tunai',
        taxPercent: 0,
      ),
      throwsA(
        isA<PresensiException>().having((e) => e.statusCode, 'status', 422),
      ),
    );
    expect(cashier.pending, isNull);
    await cashier.pulihkan();
    expect(cashier.pending, isNull);
  });

  test('pending checkout follows same server across domain changes and isolates another server', () async {
    var serverId = 'backend-a';
    final api = apiFor(
      MockClient((request) async {
        if (request.url.path.endsWith('server-info')) {
          return http.Response(
            jsonEncode({
              'app': 'warkop-ckb',
              'protocol': 1,
              'instance_id': serverId,
            }),
            200,
          );
        }
        throw TimeoutException('reply lost');
      }),
    );
    await api.aturServer('https://awal.ngrok-free.app');
    await const FlutterSecureStorage().write(
      key: 'presensi_token',
      value: 'test-token',
    );
    api.statusTerakhir = {
      'user': {'id': 1},
    };
    final cashier = LayananKasir(api: api);
    await expectLater(
      cashier.bayar(
        items: [item],
        orderType: 'Dine In',
        paymentMethod: 'Tunai',
        taxPercent: 0,
      ),
      throwsA(isA<TimeoutException>()),
    );
    final requestId = cashier.pending!['request_id'];
    await api.aturServer('https://baru.ngrok-free.app');
    api.statusTerakhir = {
      'user': {'id': 1},
    };
    final same = LayananKasir(api: api);
    await same.pulihkan();
    expect(same.pending!['request_id'], requestId);
    serverId = 'backend-b';
    await api.aturServer('https://lain.ngrok-free.app');
    api.statusTerakhir = {
      'user': {'id': 1},
    };
    final different = LayananKasir(api: api);
    await different.pulihkan();
    expect(different.pending, isNull);
  });

  test('pending requests are isolated between cashier accounts', () async {
    final firstApi = apiFor(
      MockClient((_) async => throw TimeoutException('reply lost')),
    );
    final first = LayananKasir(api: firstApi);
    await expectLater(
      first.bayar(
        items: [item],
        orderType: 'Dine In',
        paymentMethod: 'Tunai',
        taxPercent: 0,
      ),
      throwsA(isA<TimeoutException>()),
    );
    final second = LayananKasir(
      api: apiFor(MockClient((_) async => http.Response('{}', 200)), user: 2),
    );
    await second.pulihkan();
    expect(second.pending, isNull);
  });

  test(
    'catalog uses server IDs, prices and availability; tax comes from settings',
    () {
      final product = Product.fromJson({
        'id': 5,
        'name': 'Es teh',
        'category': 'Non-Kopi',
        'price': 5000,
        'available_quantity': 3,
      });
      final cart = CartService();
      cart.addProduct(product);
      expect(product.id, '5');
      expect(product.availableQuantity, 3);
      expect(cart.tax, 0);
      cart.taxRate = 0.10;
      expect(cart.total, 5500);
      cart.clear();
      expect(cart.total, 0);
    },
  );
}
