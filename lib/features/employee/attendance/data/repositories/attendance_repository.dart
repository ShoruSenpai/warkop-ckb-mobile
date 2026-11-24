import 'dart:typed_data';

import '../../../../../core/config/app_config.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/api_result.dart';

class AttendanceRepository {
  const AttendanceRepository(this._apiClient);
  final ApiClient _apiClient;

  Future<Map<String, dynamic>> checkIn({
    required Uint8List photo,
    required String fileName,
    required double latitude,
    required double longitude,
  }) async {
    final response = requireApiSuccess(
      await _apiClient.postMultipart(
        AppConfig.attendanceCheckInEndpoint,
        fields: {'latitude': '$latitude', 'longitude': '$longitude'},
        fileField: 'photo',
        fileName: fileName,
        fileBytes: photo,
      ),
    );
    final root = response is Map
        ? Map<String, dynamic>.from(response)
        : <String, dynamic>{};
    final data = root['data'];
    return data is Map ? Map<String, dynamic>.from(data) : root;
  }
}
