import 'session/session_manager.dart';
import '../core/network/http_api_client.dart';
import '../core/storage/flutter_secure_token_storage.dart';
import '../features/auth/data/repositories/auth_repository.dart';
import '../features/cashier/pos/data/repositories/order_repository.dart';
import '../features/cashier/pos/data/repositories/product_repository.dart';
import '../features/employee/attendance/data/repositories/attendance_repository.dart';

class AppDependencies {
  AppDependencies() : tokenStorage = FlutterSecureTokenStorage() {
    sessionManager = SessionManager(tokenStorage: tokenStorage);
    apiClient = HttpApiClient(
      tokenStorage: tokenStorage,
      onUnauthorized: sessionManager.clear,
    );
    authRepository = AuthRepository(
      apiClient: apiClient,
      sessionManager: sessionManager,
    );
    productRepository = ProductRepository(apiClient);
    orderRepository = OrderRepository(apiClient);
    attendanceRepository = AttendanceRepository(apiClient);
  }

  final FlutterSecureTokenStorage tokenStorage;
  late final SessionManager sessionManager;
  late final HttpApiClient apiClient;
  late final AuthRepository authRepository;
  late final ProductRepository productRepository;
  late final OrderRepository orderRepository;
  late final AttendanceRepository attendanceRepository;
}
