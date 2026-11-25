import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_ckb/app/session/session_manager.dart';
import 'package:mobile_ckb/core/network/api_client.dart';
import 'package:mobile_ckb/core/network/api_result.dart';
import 'package:mobile_ckb/core/storage/secure_token_storage.dart';
import 'package:mobile_ckb/features/auth/data/repositories/auth_repository.dart';
import 'package:mobile_ckb/features/cashier/pos/data/repositories/order_repository.dart';
import 'package:mobile_ckb/features/cashier/pos/domain/models/cart_item.dart';
import 'package:mobile_ckb/features/employee/attendance/data/repositories/attendance_repository.dart';

class FakeApiClient implements ApiClient {
  Object? getResponse;
  Object? postResponse;
  String? lastPath;
  Object? lastBody;
  Map<String, String>? lastFields;
  String? lastFileField;

  @override
  Future<ApiResult<Object?>> get(String path) async {
    lastPath = path;
    return ApiSuccess(getResponse);
  }

  @override
  Future<ApiResult<Object?>> post(String path, {Object? body}) async {
    lastPath = path;
    lastBody = body;
    return ApiSuccess(postResponse);
  }

  @override
  Future<ApiResult<Object?>> postMultipart(
    String path, {
    required Map<String, String> fields,
    required String fileField,
    required String fileName,
    required Uint8List fileBytes,
  }) async {
    lastPath = path;
    lastFields = fields;
    lastFileField = fileField;
    return ApiSuccess(postResponse);
  }
}

class FakeTokenStorage implements SecureTokenStorage {
  String? token;
  String? userData;
  @override
  Future<void> deleteToken() async => token = null;
  @override
  Future<void> deleteUserData() async => userData = null;
  @override
  Future<String?> readToken() async => token;
  @override
  Future<String?> readUserData() async => userData;
  @override
  Future<void> writeToken(String value) async => token = value;
  @override
  Future<void> writeUserData(String value) async => userData = value;
}

void main() {
  test(
    'login uses the Laravel email contract and stores the API token',
    () async {
      final api = FakeApiClient()
        ..postResponse = {
          'data': {
            'access_token': 'test-token',
            'user': {'id': 4, 'name': 'Rina', 'role': 'Barista Staff'},
          },
        };
      final tokenStorage = FakeTokenStorage();
      final repository = AuthRepository(
        apiClient: api,
        sessionManager: SessionManager(tokenStorage: tokenStorage),
      );

      final user = await repository.login(
        identifier: 'rina@example.test',
        password: 'secret',
      );

      expect(api.lastPath, '/mobile/login');
      expect(api.lastBody, {
        'email': 'rina@example.test',
        'password': 'secret',
      });
      expect(tokenStorage.token, 'test-token');
      expect(user.role.name, 'employee');
    },
  );

  test(
    'order requests retain backend field names and server response',
    () async {
      final api = FakeApiClient()
        ..postResponse = {
          'data': {'id': 10, 'total': 19800},
        };
      final repository = OrderRepository(api);
      const item = CartItem(
        productId: 'coffee-1',
        name: 'Kopi Susu',
        variant: 'Less sugar',
        price: 18000,
        quantity: 1,
      );

      final response = await repository.createOrder(
        orderType: 'Dine In',
        paymentMethod: 'QRIS',
        items: const [item],
      );

      expect(api.lastPath, '/orders');
      expect(api.lastBody, {
        'order_type': 'Dine In',
        'payment_method': 'QRIS',
        'items': [
          {
            'product_id': 'coffee-1',
            'name': 'Kopi Susu',
            'qty': 1,
            'price': 18000,
            'note': 'Less sugar',
          },
        ],
      });
      expect(response['total'], 19800);
    },
  );

  test('attendance submission uses the observed multipart fields', () async {
    final api = FakeApiClient()
      ..postResponse = {
        'data': {'status': 'accepted'},
      };
    final repository = AttendanceRepository(api);

    final result = await repository.checkIn(
      photo: Uint8List.fromList([1, 2, 3]),
      fileName: 'attendance.jpg',
      latitude: -7.2,
      longitude: 112.7,
    );

    expect(api.lastPath, '/attendance/check-in');
    expect(api.lastFields, {'latitude': '-7.2', 'longitude': '112.7'});
    expect(api.lastFileField, 'photo');
    expect(result['status'], 'accepted');
  });
}
