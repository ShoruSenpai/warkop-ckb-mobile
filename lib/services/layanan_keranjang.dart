import '../models/item_keranjang.dart';
import '../models/produk.dart';

class CartService {
  CartService({List<CartItem> initialItems = const []})
    : _items = List.of(initialItems);

  static const taxRate = 0.10;

  final List<CartItem> _items;

  List<CartItem> get items => List.unmodifiable(_items);
  int get subtotal => _items.fold(0, (sum, item) => sum + item.totalPrice);
  int get tax => (subtotal * taxRate).round();
  int get total => subtotal + tax;
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  int quantityFor(String productId) {
    for (final item in _items) {
      if (item.productId == productId) return item.quantity;
    }
    return 0;
  }

  void addProduct(Product product) {
    final index = _items.indexWhere((item) => item.productId == product.id);
    if (index >= 0) {
      _items[index] = _items[index].copyWith(
        quantity: _items[index].quantity + 1,
      );
      return;
    }

    _items.add(
      CartItem(
        productId: product.id,
        name: product.name,
        variant: product.description,
        price: product.price,
        quantity: 1,
      ),
    );
  }

  void increaseItem(CartItem cartItem) {
    final index = _items.indexWhere(
      (item) => item.productId == cartItem.productId,
    );
    if (index >= 0) {
      _items[index] = _items[index].copyWith(
        quantity: _items[index].quantity + 1,
      );
    } else {
      _items.add(cartItem.copyWith(quantity: 1));
    }
  }

  void decreaseItem(String productId) {
    final index = _items.indexWhere((item) => item.productId == productId);
    if (index < 0) return;

    if (_items[index].quantity > 1) {
      _items[index] = _items[index].copyWith(
        quantity: _items[index].quantity - 1,
      );
    } else {
      _items.removeAt(index);
    }
  }
}
