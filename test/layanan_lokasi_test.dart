import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile_ckb/services/layanan_lokasi.dart';

class FakeLocation extends GeolocatorPlatform {
  int permissionCalls = 0;
  Future<Position> Function()? lookup;
  @override
  Future<LocationPermission> checkPermission() async {
    permissionCalls++;
    return LocationPermission.denied;
  }

  @override
  Future<LocationPermission> requestPermission() {
    permissionCalls++;
    return Completer<LocationPermission>().future;
  }

  @override
  Future<bool> isLocationServiceEnabled() async => true;
  @override
  Future<Position> getCurrentPosition({LocationSettings? locationSettings}) {
    expect(locationSettings?.timeLimit, const Duration(seconds: 10));
    return lookup!();
  }
}

Position position({double accuracy = 10, bool mocked = false}) => Position(
  latitude: -7,
  longitude: 112,
  timestamp: DateTime.now(),
  accuracy: accuracy,
  altitude: 0,
  altitudeAccuracy: 0,
  heading: 0,
  headingAccuracy: 0,
  speed: 0,
  speedAccuracy: 0,
  isMocked: mocked,
);

void main() {
  late GeolocatorPlatform previous;
  late FakeLocation platform;
  setUp(() {
    previous = GeolocatorPlatform.instance;
    platform = FakeLocation();
    GeolocatorPlatform.instance = platform;
  });
  tearDown(() => GeolocatorPlatform.instance = previous);
  test(
    'web uses one bounded position request without unbounded permission lookup',
    () async {
      platform.lookup = () async => position();
      final result = await LayananLokasi(untukWeb: true).deteksiLokasi();
      expect(platform.permissionCalls, 0);
      expect(result.latitude, -7);
      expect(result.akurasiMeter, 10);
    },
  );
  testWidgets('unresponsive provider returns a useful error after 12 seconds', (
    tester,
  ) async {
    platform.lookup = () => Completer<Position>().future;
    final check = expectLater(
      LayananLokasi(untukWeb: true).deteksiLokasi(),
      throwsA(
        isA<LayananLokasiException>().having(
          (e) => e.pesan,
          'message',
          contains('12 detik'),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 13));
    await check;
  });
  test('coarse or simulated locations are still rejected', () async {
    platform.lookup = () async => position(accuracy: 500);
    await expectLater(
      LayananLokasi(untukWeb: true).deteksiLokasi(),
      throwsA(
        isA<LayananLokasiException>().having(
          (e) => e.pesan,
          'accuracy',
          contains('500'),
        ),
      ),
    );
    platform.lookup = () async => position(mocked: true);
    await expectLater(
      LayananLokasi(untukWeb: true).deteksiLokasi(),
      throwsA(isA<LayananLokasiException>()),
    );
  });
}
