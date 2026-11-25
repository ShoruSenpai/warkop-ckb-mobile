import '../../../../../core/config/app_config.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/api_result.dart';
import '../../domain/models/cart_item.dart';

class OrderRepository {
  const OrderRepository(this._apiClient);
  final ApiClient _apiClient;

  Future<Map<String, dynamic>> createOrder({
    required String orderType,
    required String paymentMethod,
    required List<CartItem> items,
  }) async {
    final response = requireApiSuccess(
      await _apiClient.post(
        AppConfig.ordersEndpoint,
        body: {
          'order_type': orderType,
          'payment_method': paymentMethod,
          'items': items
              .map(
                (item) => {
                  'product_id': item.productId,
                  'name': item.name,
                  'qty': item.quantity,
                  'price': item.price,
                  'note': item.variant,
                },
              )
              .toList(),
        },
      ),
    );
    final root = response is Map
        ? Map<String, dynamic>.from(response)
        : <String, dynamic>{};
    final data = root['data'];
    return data is Map ? Map<String, dynamic>.from(data) : root;
  }
}
