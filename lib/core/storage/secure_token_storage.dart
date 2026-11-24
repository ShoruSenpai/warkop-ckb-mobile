abstract interface class SecureTokenStorage {
  Future<String?> readToken();
  Future<void> writeToken(String token);
  Future<void> deleteToken();
  Future<String?> readUserData();
  Future<void> writeUserData(String userData);
  Future<void> deleteUserData();
}
