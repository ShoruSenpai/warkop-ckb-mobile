import 'package:flutter_test/flutter_test.dart';
import 'package:warkop_ckb_mobile/core/utils/time_service.dart';

void main() {
  test('uses the system local time and time zone', () {
    final systemTime = DateTime.now();
    final serviceTime = TimeService.now();

    expect(serviceTime.isUtc, isFalse);
    expect(serviceTime.timeZoneOffset, systemTime.timeZoneOffset);
    expect(
      TimeService.formatTime(serviceTime),
      endsWith(TimeService.timeZoneLabel(serviceTime)),
    );
  });
}
