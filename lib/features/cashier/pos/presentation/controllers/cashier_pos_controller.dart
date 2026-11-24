import 'package:flutter/foundation.dart';

import '../../../../../core/config/app_config.dart';
import '../../data/repositories/order_repository.dart';
import '../../data/repositories/product_repository.dart';
import '../../domain/models/cart_item.dart';
import '../../domain/models/product.dart';
import '../../domain/services/cart_service.dart';

class CashierPosController extends ChangeNotifier {
  CashierPosController({
    required ProductRepository products,
    required OrderRepository orders,
  }) : _productsRepository = products,
       _ordersRepository = orders;

  final ProductRepository _productsRepository;
  final OrderRepository _ordersRepository;
  final CartService cart = CartService();
  List<Product> products = const [];
  bool isLoading = true;
  bool isSubmitting = false;
  String? errorMessage;

  List<String> get categories => [
    'Semua',
    ...products.map((p) => p.category).toSet(),
  ];
  int get subtotal => cart.subtotal;
  int get tax => (subtotal * AppConfig.taxRate).round();
  int get total => subtotal + tax;
  int get itemCount => cart.itemCount;
  List<CartItem> get items => cart.items;

  Future<void> loadProducts() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      products = await _productsRepository.getProducts();
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  int quantityFor(String productId) => cart.quantityFor(productId);
  void addProduct(Product product) {
    cart.addProduct(product);
    notifyListeners();
  }

  void increaseItem(CartItem item) {
    cart.increaseItem(item);
    notifyListeners();
  }

  void decreaseItem(String productId) {
    cart.decreaseItem(productId);
    notifyListeners();
  }

  Future<Map<String, dynamic>> submitOrder({
    required String orderType,
    required String paymentMethod,
  }) async {
    if (isSubmitting) throw StateError('Pesanan sedang dikirim.');
    if (items.isEmpty) throw StateError('Keranjang masih kosong.');
    isSubmitting = true;
    notifyListeners();
    try {
      final result = await _ordersRepository.createOrder(
        orderType: orderType,
        paymentMethod: paymentMethod,
        items: List<CartItem>.of(items),
      );
      cart.clear();
      return result;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }
}
