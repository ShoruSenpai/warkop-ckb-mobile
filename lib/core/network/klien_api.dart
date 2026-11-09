import 'hasil_api.dart';

abstract interface class ApiClient {
  Future<ApiResult<T>> get<T>(String path);
  Future<ApiResult<T>> post<T>(String path, {Object? body});
}