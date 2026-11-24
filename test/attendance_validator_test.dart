import 'package:flutter_test/flutter_test.dart';
import 'package:warkop_ckb_mobile/features/employee/attendance/domain/models/attendance_location.dart';
import 'package:warkop_ckb_mobile/features/employee/attendance/domain/services/attendance_validator.dart';

void main() {
  const validator = AttendanceValidator();

  test('accepts an outlet location inside the configured radius', () {
    const location = AttendanceLocation(
      latitude: -7.2654,
      longitude: 112.7483,
      accuracyMeters: 5,
    );

    expect(validator.isWithinOutletRadius(location), isTrue);
  });

  test('rejects locations outside the configured radius', () {
    const location = AttendanceLocation(
      latitude: -7.2600,
      longitude: 112.7483,
      accuracyMeters: 5,
    );

    expect(validator.isWithinOutletRadius(location), isFalse);
  });
}
