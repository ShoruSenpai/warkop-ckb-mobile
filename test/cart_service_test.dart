import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_ckb/models/produk.dart';
import 'package:mobile_ckb/services/layanan_keranjang.dart';

void main() {
  group('CartService', () {
    const product = Product(
      id: 'kopi-susu',
      category: 'Kopi Susu',
      name: 'Kopi Susu',
      description: 'Gula aren',
      price: 18000,
      imageUrl: '',
    );

    test('updates quantity and totals when items are added or removed', () {
      final cart = CartService();

      cart.addProduct(product);
      cart.addProduct(product);

      expect(cart.quantityFor(product.id), 2);
      expect(cart.subtotal, 36000);
      expect(cart.tax, 3600);
      expect(cart.total, 39600);
      expect(cart.itemCount, 2);

      cart.decreaseItem(product.id);
      expect(cart.quantityFor(product.id), 1);

      cart.decreaseItem(product.id);
      expect(cart.items, isEmpty);
      expect(cart.total, 0);
    });
  });
}
