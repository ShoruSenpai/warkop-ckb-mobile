import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mobile_ckb/services/layanan_presensi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  test(
    'normalizes ngrok addresses and rejects credentials and query strings',
    () {
      expect(
        LayananPresensi.normalisasiAlamat(' https://contoh.ngrok-free.app/ '),
        'https://contoh.ngrok-free.app/api',
      );
      expect(
        LayananPresensi.normalisasiAlamat('https://contoh.ngrok-free.app/api/'),
        'https://contoh.ngrok-free.app/api',
      );
      for (final address in [
        'contoh.ngrok-free.app',
        'ftp://server',
        'https://user:secret@server',
        'https://server?token=secret',
        'https://server/#fragment',
      ]) {
        expect(
          () => LayananPresensi.normalisasiAlamat(address),
          throwsA(isA<PresensiException>()),
        );
      }
    },
  );

  test(
    'verifies server without credentials, persists URL and uses ngrok header',
    () async {
      FlutterSecureStorage.setMockInitialValues({
        'presensi_token': 'old-secret',
      });
      final client = MockClient((request) async {
        expect(request.url.host, 'baru.ngrok-free.app');
        expect(request.headers['ngrok-skip-browser-warning'], '1');
        expect(request.headers['Authorization'], isNull);
        if (request.url.path.endsWith('server-info')) {
          expect(request.method, 'GET');
          return http.Response(
            '{"app":"warkop-ckb","protocol":1,"instance_id":"server-a"}',
            200,
          );
        }
        expect(request.url.path, '/api/mobile/login');
        return http.Response(
          '{"token":"new-token","user":{"name":"Owner"}}',
          200,
        );
      });
      final api = LayananPresensi(client: client);
      await api.aturServer('https://baru.ngrok-free.app');
      expect(
        await const FlutterSecureStorage().read(key: 'presensi_token'),
        isNull,
      );
      final restarted = LayananPresensi(client: client);
      expect(await restarted.alamatServer(), 'https://baru.ngrok-free.app/api');
      expect(await restarted.identitasServer(), 'server-a');
      await restarted.masuk('owner@example.com', 'secret');
    },
  );

  test('invalid server leaves saved URL and token unchanged', () async {
    FlutterSecureStorage.setMockInitialValues({
      'warkop_api_url': 'https://lama.ngrok-free.app/api',
      'presensi_token': 'old-token',
    });
    final api = LayananPresensi(
      client: MockClient(
        (_) async => http.Response('<html>Ngrok offline</html>', 200),
      ),
    );
    await expectLater(
      api.aturServer('https://salah.ngrok-free.app'),
      throwsA(isA<PresensiException>()),
    );
    expect(await api.alamatServer(), 'https://lama.ngrok-free.app/api');
    expect(
      await const FlutterSecureStorage().read(key: 'presensi_token'),
      'old-token',
    );
  });

  test('login stores bearer token and uses it for attendance status', () async {
    final api = LayananPresensi(
      client: MockClient((request) async {
        if (request.url.path.endsWith('/login')) {
          expect(jsonDecode(request.body)['email'], 'staf@example.com');
          return http.Response(
            jsonEncode({
              'token': 'test-token',
              'user': {'name': 'Staf', 'is_attendance_admin': false},
            }),
            200,
          );
        }
        expect(request.headers['Authorization'], 'Bearer test-token');
        return http.Response(
          jsonEncode({
            'user': {'name': 'Staf'},
            'face_enrolled': true,
            'next_type': 'masuk',
          }),
          200,
        );
      }),
    );
    await api.masuk(' staf@example.com ', 'password');
    expect((await api.status())['next_type'], 'masuk');
    expect(api.nama, 'Staf');
    expect(api.pengelola, false);
  });

  test('server rejection surfaces the face validation message', () async {
    FlutterSecureStorage.setMockInitialValues({'presensi_token': 'test-token'});
    final api = LayananPresensi(
      client: MockClient(
        (_) async => http.Response(
          jsonEncode({
            'message': 'Invalid',
            'errors': {
              'photo': ['Wajah tidak cocok.'],
            },
          }),
          422,
        ),
      ),
    );
    await expectLater(
      api.post('attendance', {}),
      throwsA(
        isA<PresensiException>().having(
          (e) => e.pesan,
          'message',
          'Wajah tidak cocok.',
        ),
      ),
    );
  });

  test(
    'expired session is removed and another request is blocked locally',
    () async {
      FlutterSecureStorage.setMockInitialValues({'presensi_token': 'expired'});
      var calls = 0;
      final api = LayananPresensi(
        client: MockClient((_) async {
          calls++;
          return http.Response('{"message":"Unauthenticated."}', 401);
        }),
      );
      await expectLater(api.status(), throwsA(isA<PresensiException>()));
      await expectLater(api.status(), throwsA(isA<PresensiException>()));
      expect(calls, 1);
    },
  );

  test('request identifiers are unique UUID v4 values', () {
    final ids = List.generate(100, (_) => LayananPresensi.requestId());
    expect(ids.toSet().length, 100);
    for (final id in ids) {
      expect(
        RegExp(
          r'^[a-f0-9]{8}-[a-f0-9]{4}-4[a-f0-9]{3}-[89ab][a-f0-9]{3}-[a-f0-9]{12}$',
        ).hasMatch(id),
        true,
      );
    }
  });
}
