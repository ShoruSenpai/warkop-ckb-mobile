import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mobile_ckb/core/network/http_api_client.dart';
import 'package:mobile_ckb/core/network/api_result.dart';
import 'package:mobile_ckb/core/storage/flutter_secure_token_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(
    () => FlutterSecureStorage.setMockInitialValues({
      'presensi_token': 'shared-token',
    }),
  );

  test(
    'Shoru HTTP layer uses the runtime server and shared Laravel bearer token',
    () async {
      var domain = 'awal.ngrok-free.app';
      var unauthorized = false;
      final api = HttpApiClient(
        tokenStorage: FlutterSecureTokenStorage(),
        serverAddress: () async => 'https://$domain/api',
        onUnauthorized: () async {
          unauthorized = true;
        },
        client: MockClient((request) async {
          expect(request.url.host, domain);
          expect(request.headers['Authorization'], 'Bearer shared-token');
          expect(request.headers['ngrok-skip-browser-warning'], '1');
          if (request.url.path.endsWith('login')) {
            expect(request.url.path, '/api/mobile/login');
            expect(jsonDecode(request.body)['email'], 'uji@example.com');
            return http.Response('{"token":"ok"}', 200);
          }
          return http.Response('{"message":"Sesi berakhir"}', 401);
        }),
      );
      expect(
        await api.post('/mobile/login', body: {'email': 'uji@example.com'}),
        isA<ApiSuccess>(),
      );
      domain = 'baru.ngrok-free.app';
      expect(await api.get('/mobile/attendance/status'), isA<ApiFailure>());
      expect(unauthorized, isTrue);
    },
  );
}
