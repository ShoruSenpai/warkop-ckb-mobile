import 'package:flutter_test/flutter_test.dart';
import 'package:warkop_ckb_mobile/features/cashier/pos/domain/models/product.dart';

void main() {
  test('maps CICIL product aliases without changing API field names', () {
    final product = Product.fromApi({
      'id': 7,
      'category': {'name': 'Kopi'},
      'name': 'Kopi Susu',
      'desc': 'Gula aren',
      'price': '18000.4',
      'image_url': 'https://example.test/kopi.jpg',
      'tag': 'Favorit',
    });

    expect(product.id, '7');
    expect(product.category, 'Kopi');
    expect(product.description, 'Gula aren');
    expect(product.price, 18000);
    expect(product.imageUrl, 'https://example.test/kopi.jpg');
  });
}
