import '../../domain/models/attendance_location.dart';
import '../../domain/services/attendance_validator.dart';
import '../../domain/services/location_service.dart';

class LocationVerificationController {
  LocationVerificationController({
    LocationService? locationService,
    AttendanceValidator validator = const AttendanceValidator(),
  }) : _locationService = locationService ?? LocationService(),
       _validator = validator;

  final LocationService _locationService;
  final AttendanceValidator _validator;

  Future<AttendanceLocation> verifyLocation() async {
    final location = await _locationService.detectLocation();
    if (!_validator.isWithinOutletRadius(location)) {
      throw const LocationServiceException(
        'Kamu berada di luar radius outlet.',
      );
    }
    return location;
  }
}
