abstract final class AppConfig {
  static const baseUrl = String.fromEnvironment('API_BASE_URL');
  static const requestTimeout = Duration(seconds: 20);
  static const loginEndpoint = '/mobile/login';
  static const productsEndpoint = '/products';
  static const ordersEndpoint = '/orders';
  static const attendanceCheckInEndpoint = '/attendance/check-in';
  static const outletLatitude = -7.2654;
  static const outletLongitude = 112.7483;
  static const attendanceRadiusMeters = 50.0;
  static const taxRate = 0.10;
}
