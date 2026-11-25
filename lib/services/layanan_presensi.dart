import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../core/config/konfigurasi_api.dart';
import '../models/lokasi_absensi.dart';

class PresensiException implements Exception {
  const PresensiException(this.pesan, {this.statusCode});
  final String pesan;
  final int? statusCode;
  @override
  String toString() => pesan;
}

class LayananPresensi {
  LayananPresensi({http.Client? client, FlutterSecureStorage? storage})
    : _client = client ?? http.Client(),
      _storage = storage ?? const FlutterSecureStorage();

  static final instance = LayananPresensi();
  final http.Client _client;
  final FlutterSecureStorage _storage;
  String? _alamat;
  String? _instanceId;
  Map<String, dynamic>? statusTerakhir;
  String? get nama => (statusTerakhir?['user'] as Map?)?['name'] as String?;
  bool get pengelola =>
      (statusTerakhir?['user'] as Map?)?['is_attendance_admin'] == true;

  static String normalisasiAlamat(String input) {
    final text = input.trim().replaceAll(RegExp(r'/+$'), '');
    final uri = Uri.tryParse(text);
    if (uri == null ||
        !uri.hasAuthority ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty ||
        uri.hasQuery ||
        uri.hasFragment ||
        !['http', 'https'].contains(uri.scheme)) {
      throw const PresensiException(
        'Masukkan link HTTPS ngrok Laravel, misalnya https://nama.ngrok-free.app.',
      );
    }
    final path = uri.path.replaceAll(RegExp(r'/+$'), '');
    return uri
        .replace(path: path.endsWith('/api') ? path : '$path/api')
        .toString();
  }

  Future<String> alamatServer() async {
    if (_alamat != null) return _alamat!;
    _instanceId = await _storage.read(key: 'warkop_server_id');
    final saved = await _storage.read(key: 'warkop_api_url');
    final initial =
        saved ??
        (ApiConfig.baseUrl.isNotEmpty
            ? ApiConfig.baseUrl
            : kIsWeb
            ? Uri.base
                  .replace(
                    port: 8000,
                    path: '/api',
                    query: null,
                    fragment: null,
                  )
                  .toString()
            : '');
    if (initial.isEmpty) return '';
    return _alamat = normalisasiAlamat(initial);
  }

  Future<String> identitasServer() async {
    final address = await alamatServer();
    return _instanceId ?? address;
  }

  Future<void> aturServer(String input) async {
    final base = normalisasiAlamat(input);
    final response = await _client
        .get(
          Uri.parse('$base/mobile/server-info'),
          headers: {
            'Accept': 'application/json',
            'ngrok-skip-browser-warning': '1',
          },
        )
        .timeout(const Duration(seconds: 12));
    Map<String, dynamic> info;
    try {
      info = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw const PresensiException(
        'Link tidak mengembalikan API Laravel Warkop CKB. Periksa link dan pastikan ngrok mengarah ke port 8000.',
      );
    }
    if (response.statusCode != 200 ||
        info['app'] != 'warkop-ckb' ||
        info['protocol'] != 1 ||
        info['instance_id'] is! String ||
        (info['instance_id'] as String).isEmpty) {
      throw const PresensiException(
        'Server Warkop CKB tidak ditemukan pada link tersebut.',
      );
    }
    final previous = await alamatServer();
    if (previous != base || _instanceId != info['instance_id']) {
      await _storage.delete(key: 'presensi_token');
      statusTerakhir = null;
    }
    await _storage.write(key: 'warkop_api_url', value: base);
    await _storage.write(
      key: 'warkop_server_id',
      value: info['instance_id'] as String,
    );
    _alamat = base;
    _instanceId = info['instance_id'] as String;
  }

  Future<Uri> _uri(String path) async {
    final base = await alamatServer();
    if (base.isEmpty) {
      throw const PresensiException(
        'Alamat server belum diatur. Ketuk Alamat server pada halaman login lalu tempel link ngrok Laravel.',
      );
    }
    return Uri.parse('$base/mobile/$path');
  }

  Future<Map<String, String>> _headers({bool login = false}) async {
    final token = login ? null : await _storage.read(key: 'presensi_token');
    if (!login && token == null) {
      throw const PresensiException('Sesi berakhir. Silakan masuk kembali.');
    }
    return {
      'Accept': 'application/json',
      'ngrok-skip-browser-warning': '1',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> _decode(http.Response response) async {
    Map<String, dynamic> data;
    try {
      data = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw const PresensiException(
        'Respons server tidak valid. Periksa alamat API dan koneksi server.',
      );
    }
    if (response.statusCode == 401) {
      await _storage.delete(key: 'presensi_token');
      statusTerakhir = null;
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final errors = data['errors'];
      final message = errors is Map && errors.isNotEmpty
          ? (errors.values.first as List).first.toString()
          : data['message']?.toString();
      throw PresensiException(
        message ?? 'Permintaan gagal. Coba lagi.',
        statusCode: response.statusCode,
      );
    }
    return data;
  }

  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body, {
    bool login = false,
  }) async {
    final uri = await _uri(path);
    final headers = await _headers(login: login);
    final response = await _client
        .post(
          uri,
          headers: {...headers, 'Content-Type': 'application/json'},
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 45));
    return _decode(response);
  }

  Future<void> masuk(String email, String password) async {
    final data = await post('login', {
      'email': email.trim(),
      'password': password,
    }, login: true);
    await _storage.write(key: 'presensi_token', value: data['token'] as String);
    statusTerakhir = {'user': data['user']};
  }

  Future<void> keluar() async {
    try {
      await post('logout', {});
    } finally {
      await _storage.delete(key: 'presensi_token');
      statusTerakhir = null;
    }
  }

  Future<Map<String, dynamic>> get(String path) async {
    final uri = await _uri(path);
    return _decode(
      await _client
          .get(uri, headers: await _headers())
          .timeout(const Duration(seconds: 20)),
    );
  }

  Future<Map<String, dynamic>> status() async {
    final data = await get('attendance/status');
    statusTerakhir = data;
    return data;
  }

  Map<String, dynamic> lokasiBody(LokasiAbsensi lokasi) => {
    'latitude': lokasi.latitude,
    'longitude': lokasi.longitude,
    'accuracy': lokasi.akurasiMeter,
  };

  Future<Map<String, dynamic>> cekLokasi(LokasiAbsensi lokasi) =>
      post('attendance/location', lokasiBody(lokasi));

  Future<Map<String, dynamic>> unggah(
    String path,
    Uint8List foto,
    Map<String, String> fields,
  ) async {
    final request = http.MultipartRequest('POST', await _uri(path));
    request.headers.addAll(await _headers());
    request.fields.addAll(fields);
    request.files.add(
      http.MultipartFile.fromBytes('photo', foto, filename: 'wajah.jpg'),
    );
    final response = await http.Response.fromStream(
      await _client.send(request).timeout(const Duration(seconds: 60)),
    ).timeout(const Duration(seconds: 20));
    return _decode(response);
  }

  static String requestId() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex = bytes.map((v) => v.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
  }
}
