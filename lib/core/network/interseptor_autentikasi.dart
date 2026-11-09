import '../storage/penyimpanan_token_aman.dart';

class AuthInterceptor {
  const AuthInterceptor(this._tokenStorage);

  final SecureTokenStorage _tokenStorage;

  Future<Map<String, String>> apply(Map<String, String> headers) async {
    final token = await _tokenStorage.readToken();
    return {
      ...headers,
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }
}