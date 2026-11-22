/// Konfigurasi API dan lokasi outlet Warkop Cak Kebo.
class AppConfig {
  // Base URL backend API
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  // Timeout request network
  static const Duration timeout = Duration(seconds: 15);

  // Endpoint API
  static const String epLogin = '/login';
  static const String epProducts = '/products';
  static const String epOrders = '/orders';
  static const String epCheckIn = '/attendance/check-in';

  // Lokasi dan nama outlet
  static const String outletName = 'Warkop Cak Kebo';
  static const double outletLat = -8.1711139;
  static const double outletLng = 113.7275486;
  static const double maxRadiusMeter = 50.0;

  // Link navigasi Google Maps
  static const String outletMapsUrl =
      'https://www.google.com/maps/dir/?api=1&destination=-8.1711139,113.7275486&dir_action=navigate';
  static const String mapsDirectionUrl = outletMapsUrl;

  // Tarif PB1 (10%)
  static const double taxRate = 0.10;
  static const double pb1Rate = taxRate;
}
