import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mobile_ckb/features/employee/attendance/halaman_pengaturan_presensi.dart';
import 'package:mobile_ckb/models/lokasi_absensi.dart';
import 'package:mobile_ckb/services/layanan_lokasi.dart';
import 'package:mobile_ckb/services/layanan_presensi.dart';

class PendingLocation extends LayananLokasi {
  final pending = Completer<LokasiAbsensi>();
  @override
  Future<LokasiAbsensi> deteksiLokasi() => pending.future;
}

void main() {
  testWidgets(
    'Owner is selected automatically and employee selection remains enabled during GPS lookup',
    (tester) async {
      tester.view.physicalSize = const Size(1000, 1800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      FlutterSecureStorage.setMockInitialValues({
        'presensi_token': 'test-token',
      });
      final api = LayananPresensi(
        client: MockClient(
          (request) async => http.Response(
            jsonEncode(
              request.url.path.endsWith('/employees')
                  ? {
                      'employees': [
                        {
                          'id': 1,
                          'name': 'Owner Uji',
                          'email': 'owner@example.com',
                        },
                      ],
                    }
                  : {
                      'user': {
                        'id': 1,
                        'name': 'Owner Uji',
                        'is_attendance_admin': true,
                      },
                      'outlet': null,
                      'face_enrolled': false,
                    },
            ),
            200,
          ),
        ),
      );
      final location = PendingLocation();
      await tester.pumpWidget(
        MaterialApp(
          home: PengaturanPresensiScreen(api: api, lokasiService: location),
        ),
      );
      await tester.pumpAndSettle();
      final dropdown = find.byType(DropdownButtonFormField<int>);
      expect(
        tester.widget<DropdownButtonFormField<int>>(dropdown).initialValue,
        1,
      );
      await tester.tap(find.text('Gunakan lokasi saat ini'));
      await tester.pump();
      expect(find.text('Mencari lokasi (maks. 12 detik)…'), findsOneWidget);
      expect(
        tester.widget<DropdownButtonFormField<int>>(dropdown).onChanged,
        isNotNull,
      );
      location.pending.completeError(
        const LayananLokasiException('Batas waktu lokasi tercapai.'),
      );
      await tester.pumpAndSettle();
      expect(find.text('Batas waktu lokasi tercapai.'), findsOneWidget);
      expect(
        tester.widget<DropdownButtonFormField<int>>(dropdown).onChanged,
        isNotNull,
      );
    },
  );
}
