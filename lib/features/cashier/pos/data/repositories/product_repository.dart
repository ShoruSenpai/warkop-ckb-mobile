import '../../../../../core/config/app_config.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/api_exception.dart';
import '../../../../../core/network/api_result.dart';
import '../../domain/models/product.dart';

class ProductRepository {
  const ProductRepository(this._apiClient);
  final ApiClient _apiClient;

  Future<List<Product>> getProducts() async {
    final response = requireApiSuccess(
      await _apiClient.get(AppConfig.productsEndpoint),
    );
    final rawList = response is Map && response['data'] != null
        ? response['data']
        : response;
    if (rawList is! List)
      throw const ApiException('Format data menu tidak sesuai.');
    return rawList
        .map((item) {
          if (item is! Map)
            throw const ApiException('Data produk tidak sesuai.');
          return Product.fromApi(Map<String, dynamic>.from(item));
        })
        .toList(growable: false);
  }
}
