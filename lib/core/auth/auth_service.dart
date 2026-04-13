import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';

class AuthService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const _tokenKey = 'jwt_token';
  static const _userKey = 'current_user';
  static const _expiryKey = 'token_expiry';

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> saveUser(User user) async {
    await _storage.write(key: _userKey, value: jsonEncode(user.toJson()));
  }

  Future<User?> getUser() async {
    final userStr = await _storage.read(key: _userKey);
    if (userStr == null) return null;
    try {
      return User.fromJson(jsonDecode(userStr));
    } catch (_) {
      return null;
    }
  }

  Future<void> saveExpiry(DateTime expiry) async {
    await _storage.write(key: _expiryKey, value: expiry.toIso8601String());
  }

  Future<DateTime?> getExpiry() async {
    final expiryStr = await _storage.read(key: _expiryKey);
    if (expiryStr == null) return null;
    return DateTime.tryParse(expiryStr);
  }

  Future<void> clear() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
    await _storage.delete(key: _expiryKey);
  }

  Future<bool> isAuthenticated() async {
    final token = await getToken();
    final expiry = await getExpiry();
    final user = await getUser();

    if (token == null || expiry == null || user == null) return false;

    // Check if token is still valid
    return DateTime.now().isBefore(expiry);
  }
}
