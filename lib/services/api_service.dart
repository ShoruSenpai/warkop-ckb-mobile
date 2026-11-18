import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import 'session.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

class ApiService {
  static Uri _uri(String path) => Uri.parse('${AppConfig.baseUrl}$path');

  static Map<String, String> get _authHeader => {
        'Accept': 'application/json',
        if (Session.isLoggedIn) 'Authorization': 'Bearer ${Session.token}',
      };

  static Map<String, String> get _jsonHeaders =>
      {..._authHeader, 'Content-Type': 'application/json'};

  static dynamic _decode(http.Response res) {
    dynamic body;
    try {
      body = res.body.isEmpty ? null : jsonDecode(res.body);
    } catch (_) {
      body = null;
    }
    if (res.statusCode == 401 && Session.isLoggedIn) {
      Session.clear();
      throw ApiException('Sesi berakhir, silakan login ulang');
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      String? msg;
      if (body is Map) {
        msg = (body['message'] ?? body['error'])?.toString();
      }
      throw ApiException(msg ?? 'Server error (${res.statusCode})');
    }
    return body;
  }

  static dynamic _data(dynamic body) =>
      (body is Map && body.containsKey('data')) ? body['data'] : body;

  static Future<T> _guard<T>(Future<T> Function() fn) async {
    try {
      return await fn();
    } on ApiException {
      rethrow;
    } on SocketException {
      throw ApiException('Tidak ada koneksi ke server');
    } on http.ClientException {
      throw ApiException('Tidak ada koneksi ke server');
    } on TimeoutException {
      throw ApiException('Server tidak merespons, coba lagi');
    } catch (e) {
      throw ApiException('Terjadi kesalahan: $e');
    }
  }

  static int _toInt(dynamic v) {
    if (v is num) return v.round();
    return (double.tryParse(v?.toString() ?? '') ?? 0).round();
  }

  static Future<void> login(String identifier, String password) => _guard(() async {
        final res = await http
            .post(_uri(AppConfig.epLogin),
                headers: _jsonHeaders,
                body: jsonEncode({'identifier': identifier, 'password': password}))
            .timeout(AppConfig.timeout);
        final body = _decode(res);
        final d = _data(body);
        final map = d is Map ? d : <String, dynamic>{};
        final token = (map['token'] ??
                map['access_token'] ??
                (body is Map ? body['token'] : null))
            ?.toString();
        if (token == null || token.isEmpty) {
          throw ApiException('Balasan login tidak berisi token');
        }
        final userRaw = map['user'] ?? (body is Map ? body['user'] : null);
        final user = userRaw is Map
            ? Map<String, dynamic>.from(userRaw)
            : <String, dynamic>{};
        await Session.save(token, user);
      });

  static Future<List<Map<String, dynamic>>> getProducts() => _guard(() async {
        final res = await http
            .get(_uri(AppConfig.epProducts), headers: _authHeader)
            .timeout(AppConfig.timeout);
        final list = _data(_decode(res));
        if (list is! List) throw ApiException('Format data menu tidak sesuai');
        return list.map<Map<String, dynamic>>((e) {
          final m = Map<String, dynamic>.from(e as Map);
          final catRaw = m['category'] ?? m['cat'];
          return {
            'id': m['id'],
            'cat': (catRaw is Map ? catRaw['name'] : catRaw ?? 'Lainnya').toString(),
            'name': (m['name'] ?? '').toString(),
            'desc': (m['description'] ?? m['desc'] ?? '').toString(),
            'price': _toInt(m['price']),
            'img': (m['image_url'] ?? m['image'] ?? m['img'] ?? '').toString(),
            'tag': m['tag'],
          };
        }).toList();
      });

  static Future<Map<String, dynamic>> createOrder({
    required String orderType,
    required String paymentMethod,
    required List<Map<String, dynamic>> items,
  }) =>
      _guard(() async {
        final payload = {
          'order_type': orderType,
          'payment_method': paymentMethod,
          'items': items
              .map((i) => {
                    'product_id': i['id'],
                    'name': i['name'],
                    'qty': i['qty'],
                    'price': i['price'],
                    'note': i['variant'],
                  })
              .toList(),
        };
        final res = await http
            .post(_uri(AppConfig.epOrders),
                headers: _jsonHeaders, body: jsonEncode(payload))
            .timeout(AppConfig.timeout);
        final d = _data(_decode(res));
        return d is Map ? Map<String, dynamic>.from(d) : <String, dynamic>{};
      });

  static Future<Map<String, dynamic>> checkIn({
    required String photoPath,
    required double lat,
    required double lng,
  }) =>
      _guard(() async {
        final req = http.MultipartRequest('POST', _uri(AppConfig.epCheckIn))
          ..headers.addAll(_authHeader)
          ..fields['latitude'] = lat.toString()
          ..fields['longitude'] = lng.toString()
          ..files.add(await http.MultipartFile.fromPath('photo', photoPath));
        final streamed = await req.send().timeout(AppConfig.timeout);
        final res = await http.Response.fromStream(streamed);
        final d = _data(_decode(res));
        return d is Map ? Map<String, dynamic>.from(d) : <String, dynamic>{};
      });
}
