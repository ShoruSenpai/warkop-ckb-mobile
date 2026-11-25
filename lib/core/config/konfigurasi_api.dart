abstract final class ApiConfig {
  // Optional default: --dart-define=API_BASE_URL=https://domain-ngrok/api
  // The login screen can save another address without rebuilding the app.
  static const baseUrl = String.fromEnvironment('API_BASE_URL');
  static const connectTimeout = Duration(seconds: 15);
  static const receiveTimeout = Duration(seconds: 15);
}
