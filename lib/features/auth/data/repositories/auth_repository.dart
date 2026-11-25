import '../../../../app/session/current_user.dart';
import '../../../../app/session/session_manager.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/api_result.dart';
import '../../../../services/layanan_presensi.dart';

class AuthRepository {
  const AuthRepository({
    required ApiClient apiClient,
    required SessionManager sessionManager,
  }) : _apiClient = apiClient,
       _sessionManager = sessionManager;

  final ApiClient _apiClient;
  final SessionManager _sessionManager;

  Future<CurrentUser> login({
    required String identifier,
    required String password,
  }) async {
    final response = requireApiSuccess(
      await _apiClient.post(
        AppConfig.loginEndpoint,
        body: {'email': identifier.trim(), 'password': password},
      ),
    );
    final root = response is Map
        ? Map<String, dynamic>.from(response)
        : <String, dynamic>{};
    final data = root['data'] is Map
        ? Map<String, dynamic>.from(root['data'] as Map)
        : root;
    final token = (data['token'] ?? data['access_token'] ?? root['token'])
        ?.toString();
    if (token == null || token.isEmpty) {
      throw const ApiException('Balasan login tidak berisi token.');
    }
    final rawUser = data['user'] ?? root['user'];
    if (rawUser is! Map)
      throw const ApiException('Balasan login tidak berisi data pengguna.');
    final user = CurrentUser.fromApi(Map<String, dynamic>.from(rawUser));
    LayananPresensi.instance.statusTerakhir = {
      'user': Map<String, dynamic>.from(rawUser),
    };
    await _sessionManager.start(token, user);
    return user;
  }

  Future<void> logout() async {
    try {
      await _apiClient.post('/mobile/logout');
    } finally {
      LayananPresensi.instance.statusTerakhir = null;
      await _sessionManager.clear();
    }
  }
}
