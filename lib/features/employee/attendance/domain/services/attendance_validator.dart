import 'package:geolocator/geolocator.dart';

import '../../../../../core/config/app_config.dart';
import '../models/attendance_location.dart';

class AttendanceValidator {
  const AttendanceValidator();

  double distanceFromOutlet(AttendanceLocation location) =>
      Geolocator.distanceBetween(
        location.latitude,
        location.longitude,
        AppConfig.outletLatitude,
        AppConfig.outletLongitude,
      );

  bool isWithinOutletRadius(AttendanceLocation location) =>
      distanceFromOutlet(location) <= AppConfig.attendanceRadiusMeters;
}
