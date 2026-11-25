import 'dart:typed_data';

import 'api_result.dart';

abstract interface class ApiClient {
  Future<ApiResult<Object?>> get(String path);
  Future<ApiResult<Object?>> post(String path, {Object? body});
  Future<ApiResult<Object?>> postMultipart(
    String path, {
    required Map<String, String> fields,
    required String fileField,
    required String fileName,
    required Uint8List fileBytes,
  });
}
