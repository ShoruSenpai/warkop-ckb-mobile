import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../../services/layanan_presensi.dart';
import '../storage/secure_token_storage.dart';
import 'api_client.dart';
import 'api_exception.dart';
import 'api_result.dart';
import 'auth_interceptor.dart';

class HttpApiClient implements ApiClient {
  HttpApiClient({
    http.Client? client,
    required SecureTokenStorage tokenStorage,
    Future<void> Function()? onUnauthorized,
    Future<String> Function()? serverAddress,
  }) : _client = client ?? http.Client(),
       _authInterceptor = AuthInterceptor(tokenStorage),
       _serverAddress = serverAddress ?? LayananPresensi.instance.alamatServer,
       _onUnauthorized = onUnauthorized;

  final http.Client _client;
  final AuthInterceptor _authInterceptor;
  final Future<void> Function()? _onUnauthorized;
  final Future<String> Function() _serverAddress;

  Future<Uri> _uri(String path) async {
    final baseUrl = await _serverAddress();
    if (baseUrl.isEmpty) {
      throw const ApiException(
        'API belum dikonfigurasi. Jalankan dengan --dart-define=API_BASE_URL=https://server/api.',
      );
    }
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse(
      '${baseUrl.replaceFirst(RegExp(r'/+$'), '')}$normalizedPath',
    );
  }

  Future<Map<String, String>> _headers({bool json = false}) async => {
    'Accept': 'application/json',
    'ngrok-skip-browser-warning': '1',
    if (json) 'Content-Type': 'application/json',
    ...await _authInterceptor.apply(const {}),
  };

  @override
  Future<ApiResult<Object?>> get(String path) async {
    try {
      final response = await _client
          .get(await _uri(path), headers: await _headers())
          .timeout(AppConfig.requestTimeout);
      return await _decode(response.statusCode, response.body);
    } on ApiException catch (error) {
      return ApiFailure(error.message, statusCode: error.statusCode);
    } on SocketException {
      return const ApiFailure('Tidak ada koneksi ke server.');
    } on TimeoutException {
      return const ApiFailure('Server tidak merespons, coba lagi.');
    } on http.ClientException {
      return const ApiFailure('Tidak dapat terhubung ke server.');
    } catch (error) {
      return ApiFailure('Permintaan gagal: $error');
    }
  }

  @override
  Future<ApiResult<Object?>> post(String path, {Object? body}) async {
    try {
      final response = await _client
          .post(
            await _uri(path),
            headers: await _headers(json: true),
            body: jsonEncode(body),
          )
          .timeout(AppConfig.requestTimeout);
      return await _decode(response.statusCode, response.body);
    } on ApiException catch (error) {
      return ApiFailure(error.message, statusCode: error.statusCode);
    } on SocketException {
      return const ApiFailure('Tidak ada koneksi ke server.');
    } on TimeoutException {
      return const ApiFailure('Server tidak merespons, coba lagi.');
    } on http.ClientException {
      return const ApiFailure('Tidak dapat terhubung ke server.');
    } catch (error) {
      return ApiFailure('Permintaan gagal: $error');
    }
  }

  @override
  Future<ApiResult<Object?>> postMultipart(
    String path, {
    required Map<String, String> fields,
    required String fileField,
    required String fileName,
    required Uint8List fileBytes,
  }) async {
    try {
      final request = http.MultipartRequest('POST', await _uri(path))
        ..headers.addAll(await _headers())
        ..fields.addAll(fields)
        ..files.add(
          http.MultipartFile.fromBytes(
            fileField,
            fileBytes,
            filename: fileName,
          ),
        );
      final streamed = await _client
          .send(request)
          .timeout(AppConfig.requestTimeout);
      final response = await http.Response.fromStream(streamed);
      return await _decode(response.statusCode, response.body);
    } on ApiException catch (error) {
      return ApiFailure(error.message, statusCode: error.statusCode);
    } on SocketException {
      return const ApiFailure('Tidak ada koneksi ke server.');
    } on TimeoutException {
      return const ApiFailure('Server tidak merespons, coba lagi.');
    } on http.ClientException {
      return const ApiFailure('Tidak dapat terhubung ke server.');
    } catch (error) {
      return ApiFailure('Permintaan gagal: $error');
    }
  }

  Future<ApiResult<Object?>> _decode(
    int statusCode,
    String responseBody,
  ) async {
    Object? body;
    try {
      body = responseBody.isEmpty ? null : jsonDecode(responseBody);
    } on FormatException {
      body = null;
    }
    if (statusCode >= 200 && statusCode < 300) return ApiSuccess(body);
    if (statusCode == 401) await _onUnauthorized?.call();
    final message = body is Map
        ? (body['message'] ?? body['error'])?.toString()
        : null;
    return ApiFailure(
      message ?? 'Server error ($statusCode).',
      statusCode: statusCode,
    );
  }
}
