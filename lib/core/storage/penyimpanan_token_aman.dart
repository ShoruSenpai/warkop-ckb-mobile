abstract interface class SecureTokenStorage {
  Future<String?> readToken();
  Future<void> writeToken(String token);
  Future<void> deleteToken();
}